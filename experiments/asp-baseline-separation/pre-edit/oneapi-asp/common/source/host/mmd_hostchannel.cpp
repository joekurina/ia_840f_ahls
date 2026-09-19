// SPDX-License-Identifier: MIT
#include "mmd_hostchannel.h"
#include "dma_hostchannel_abi.h"
#include <algorithm>
#include <atomic>
#include <chrono>
#include <climits>
#include <cstring>
#include <cstdio>
#include <thread>

bool DmaHostChannels::read(unsigned s, uint64_t reg, uint64_t &v) {
  return fpgaReadMMIO64(queues_[s].device, 0, DHC_BASE + s * DHC_STRIDE + reg,
                        &v) == FPGA_OK;
}
bool DmaHostChannels::write(unsigned s, uint64_t reg, uint64_t v) {
  return fpgaWriteMMIO64(queues_[s].device, 0, DHC_BASE + s * DHC_STRIDE + reg,
                         v) == FPGA_OK;
}
bool DmaHostChannels::wait_status(unsigned s, uint64_t required,
                                  uint64_t forbidden) {
  const auto end = std::chrono::steady_clock::now() + std::chrono::seconds(1);
  do {
    uint64_t status = 0;
    if (!read(s, DHC_STATUS, status)) return false;
    if ((status & required) == required && !(status & forbidden)) return true;
    std::this_thread::sleep_for(std::chrono::microseconds(50));
  } while (std::chrono::steady_clock::now() < end);
  return false;
}

bool DmaHostChannels::release(unsigned s) {
  Queue &q = queues_[s];
  if (!q.registered) { q = Queue{}; return true; }
  q.failed = true; // No more offers, even if stop or release fails.
  q.offered = 0;
  if (q.published) {
    if (!write(s, DHC_CONTROL, DHC_QUIESCE) ||
        !wait_status(s, DHC_QUIESCED, DHC_RUNNING)) {
      std::fprintf(stderr, "MMD hostchannel %u: quiesce failed; retaining DMA mapping\n", s);
      return false;
    }
    // Remove device addresses while stopped before unmapping. A failed write
    // is ambiguous; retain registration rather than relying on presumed state.
    if (!write(s, DHC_RING_BYTES, 0) || !write(s, DHC_RING_IOVA, 0)) return false;
    q.published = false;
  }
  if (fpgaReleaseBuffer(q.device, q.wsid) != FPGA_OK) return false;
  q = Queue{};
  return true;
}

int DmaHostChannels::create(fpga_handle device, const char *name, size_t bytes,
                            int direction) {
  std::lock_guard<std::mutex> lock(mutex_);
#if !defined(__x86_64__)
  // No noncoherent cache-maintenance backend is implemented.
  return -1;
#endif
  if (!device || !name || bytes < DHC_ELEMENT_SIZE ||
      bytes > DHC_MAX_RING_BYTES || (bytes & (bytes - 1)) ||
      bytes % DHC_ELEMENT_SIZE || next_handle_ > INT_MAX) return -1;
  unsigned s;
  if (direction == 1 && !std::strcmp(name, DHC_H2D_NAME)) s = 0;
  else if (direction == 0 && !std::strcmp(name, DHC_D2H_NAME)) s = 1;
  else return -1;
  Queue &q = queues_[s];
  if (q.registered || q.handle) return -1;
  q.device = device;
  uint64_t ident = 0, element = 0, state = 0;
  // Read-only discovery: never write unknown or legacy hardware.
  if (!read(s, DHC_IDENT, ident) || ident != DHC_IDENT_VALUE ||
      !read(s, DHC_ELEMENT_BYTES, element) || element != DHC_ELEMENT_SIZE ||
      !read(s, DHC_STATUS, state) || !(state & DHC_QUIESCED) ||
      (state & DHC_RUNNING)) { q = Queue{}; return -1; }
  if (!write(s, DHC_CONTROL, DHC_RESET_POSITIONS) ||
      !wait_status(s, DHC_QUIESCED, DHC_RUNNING | DHC_FAILED) ||
      !read(s, DHC_HOST_POSITION, state) || state ||
      !read(s, DHC_DEVICE_POSITION, state) || state) {
    q = Queue{}; return -1;
  }
  // OPAE owns allocation AND registration (flags=0). No MPF virtual-address
  // assumption: only a successful fpgaGetIOAddress may supply the ring address.
  const size_t allocation_bytes = std::max(bytes, size_t(4096));
  if (fpgaPrepareBuffer(device, allocation_bytes, &q.buffer, &q.wsid, 0) != FPGA_OK) {
    q = Queue{}; return -1;
  }
  q.registered = true;
  if (!q.buffer || fpgaGetIOAddress(device, q.wsid, &q.iova) != FPGA_OK ||
      q.iova % DHC_ELEMENT_SIZE || q.iova > UINT64_MAX - allocation_bytes) {
    release(s); return -1;
  }
  q.capacity = bytes;
  std::memset(q.buffer, 0, allocation_bytes);
  std::atomic_thread_fence(std::memory_order_seq_cst);
  q.published = true; // Set BEFORE the first potentially effective MMIO write.
  if (!write(s, DHC_RING_IOVA, q.iova) || !write(s, DHC_RING_BYTES, bytes) ||
      !write(s, DHC_HOST_POSITION, 0) || !write(s, DHC_CONTROL, DHC_RUN) ||
      !wait_status(s, DHC_RUNNING, DHC_QUIESCED | DHC_FAILED)) {
    release(s); return -1;
  }
  q.handle = static_cast<int>(next_handle_++);
  return q.handle;
}

int DmaHostChannels::lookup(int handle) {
  if (handle <= 0) return -1;
  for (int s = 0; s != 2; ++s)
    if (queues_[s].handle == handle) return s;
  return -1;
}
int DmaHostChannels::destroy(int handle) {
  std::lock_guard<std::mutex> lock(mutex_);
  const int s = lookup(handle);
  return s >= 0 && release(static_cast<unsigned>(s)) ? 0 : -1;
}
bool DmaHostChannels::has_registrations() {
  std::lock_guard<std::mutex> lock(mutex_);
  return queues_[0].registered || queues_[1].registered;
}
bool DmaHostChannels::shutdown() {
  std::lock_guard<std::mutex> lock(mutex_);
  bool ok = true;
  for (unsigned s = 0; s != 2; ++s) if (!release(s)) ok = false;
  return ok;
}

void *DmaHostChannels::get_buffer(int handle, size_t *bytes, int *status) {
  if (status) *status = -1;
  if (bytes) *bytes = 0;
  if (!status || !bytes) return nullptr;
  std::lock_guard<std::mutex> lock(mutex_);
  const int s = lookup(handle);
  if (s < 0) return nullptr;
  Queue &q = queues_[s];
  if (q.failed) return nullptr;
  uint64_t state = 0, peer = 0;
  if (!read(s, DHC_STATUS, state) || !(state & DHC_RUNNING) ||
      (state & (DHC_FAILED | DHC_QUIESCED)) ||
      !read(s, DHC_DEVICE_POSITION, peer)) { q.failed = true; return nullptr; }
  const uint64_t used = s == 0 ? q.position - peer : peer - q.position;
  // Modulo subtraction supports uint64 wrap. Peer progress cannot exceed one
  // ring between observations because host credits have not advanced farther.
  if (used > q.capacity || peer - q.peer > q.capacity ||
      peer % DHC_ELEMENT_SIZE) { q.failed = true; return nullptr; }
  q.peer = peer;
  const size_t offset = q.position & (q.capacity - 1);
  const size_t available = s == 0 ? q.capacity - used : used;
  q.offered = std::min(available, q.capacity - offset);
  // The hardware contract, not this CPU fence alone, supplies DMA coherence.
  std::atomic_thread_fence(std::memory_order_seq_cst);
  *bytes = q.offered;
  *status = 0;
  return static_cast<unsigned char *>(q.buffer) + offset;
}

size_t DmaHostChannels::ack_buffer(int handle, size_t bytes, int *status) {
  if (!status) return 0;
  *status = -1;
  std::lock_guard<std::mutex> lock(mutex_);
  const int s = lookup(handle);
  if (s < 0) return 0;
  Queue &q = queues_[s];
  if (q.failed || bytes % DHC_ELEMENT_SIZE) return 0;
  uint64_t state = 0;
  if (!read(s, DHC_STATUS, state) || !(state & DHC_RUNNING) ||
      (state & (DHC_FAILED | DHC_QUIESCED))) { q.failed = true; return 0; }
  const size_t accepted = std::min(bytes, q.offered);
  if (accepted) {
    std::atomic_thread_fence(std::memory_order_seq_cst);
    if (!write(s, DHC_HOST_POSITION, q.position + accepted)) {
      // Publication may have occurred despite the failed MMIO response. Never
      // retry it against a guessed position; only destruction is now allowed.
      q.failed = true; q.offered = 0; return 0;
    }
    q.position += accepted;
    q.offered -= accepted;
  }
  *status = 0;
  return accepted;
}
