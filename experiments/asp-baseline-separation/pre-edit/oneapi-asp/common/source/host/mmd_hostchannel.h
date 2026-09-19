// SPDX-License-Identifier: MIT
#ifndef MMD_HOSTCHANNEL_H
#define MMD_HOSTCHANNEL_H
#include <opae/fpga.h>
#include <cstddef>
#include <cstdint>
#include <mutex>

// Serializes new exports with open/close/reprogram. Existing DDR API threading
// remains the runtime's responsibility. A returned buffer has one host owner;
// callers must not destroy/reprogram while using it outside the MMD call.
extern std::recursive_mutex mmd_hostchannel_lifecycle_mutex;

class DmaHostChannels final {
public:
  DmaHostChannels() = default;
  DmaHostChannels(const DmaHostChannels &) = delete;
  DmaHostChannels &operator=(const DmaHostChannels &) = delete;
  // Deliberately no implicit release: failed quiescence must retain DMA mappings.
  ~DmaHostChannels() = default;
  int create(fpga_handle device, const char *name, size_t bytes, int direction);
  int destroy(int channel);
  void *get_buffer(int channel, size_t *bytes, int *status);
  size_t ack_buffer(int channel, size_t bytes, int *status);
  bool shutdown();
  bool has_registrations();
private:
  struct Queue {
    fpga_handle device = nullptr;
    void *buffer = nullptr;
    uint64_t wsid = 0, iova = 0, position = 0, peer = 0;
    size_t capacity = 0, offered = 0;
    int handle = 0;
    bool registered = false, published = false, failed = false;
  } queues_[2];
  uint64_t next_handle_ = 1; // Never reuse a stale handle within a Device.
  std::mutex mutex_;
  bool read(unsigned slot, uint64_t reg, uint64_t &value);
  bool write(unsigned slot, uint64_t reg, uint64_t value);
  bool wait_status(unsigned slot, uint64_t required, uint64_t forbidden);
  bool release(unsigned slot);
  int lookup(int handle);
};
#endif
