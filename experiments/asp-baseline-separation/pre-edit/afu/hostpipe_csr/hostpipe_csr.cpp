// Source-only oneAPI 2025.0 CSR host-pipe FPGA Test; not hardware-qualified.
#include <sycl/ext/intel/experimental/pipes.hpp>
#include <sycl/ext/intel/fpga_extensions.hpp>
#include <sycl/sycl.hpp>

#include <array>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <exception>
#include <iostream>
#include <thread>

namespace intel_exp = sycl::ext::intel::experimental;
namespace oneapi_exp = sycl::ext::oneapi::experimental;

class CsrInputID;
class CsrOutputID;
class CsrTransformID;

// Handbook 2025.0, Pipes: H2D uses avalon_mm plus the valid handshake.
// avalon_mm_uses_ready is documented for D2H ONLY; do not put it on H2D.
using InputProperties = decltype(oneapi_exp::properties(
    intel_exp::protocol<intel_exp::protocol_name::avalon_mm>,
    intel_exp::uses_valid<true>));
using OutputProperties = decltype(oneapi_exp::properties(
    intel_exp::protocol<intel_exp::protocol_name::avalon_mm_uses_ready>));
using InputPipe = intel_exp::pipe<CsrInputID, std::int32_t, 0, InputProperties>;
using OutputPipe = intel_exp::pipe<CsrOutputID, std::int32_t, 0, OutputProperties>;

constexpr std::size_t kCount = 256;
using Clock = std::chrono::steady_clock;

// Standalone diagnostic process: never unwind live queues on a timeout/error.
// Even successful teardown is outside the cooperative deadline contract, so
// terminate explicitly after flushing. This does NOT cancel/reset FPGA work.
[[noreturn]] void Finish(int code) {
  std::cout.flush();
  std::cerr.flush();
  std::_Exit(code);
}

int main() {
  std::size_t sent = 0;
  std::size_t received = 0;
  std::size_t send_retries = 0;
  std::size_t read_retries = 0;
  const auto deadline = Clock::now() + std::chrono::seconds(30);
  auto check_deadline = [&] {
    if (Clock::now() >= deadline) {
      std::cerr << "FPGA Test TIMEOUT: sent=" << sent
                << " received=" << received << " of " << kCount << '\n';
      Finish(EXIT_FAILURE);
    }
  };

  try {
    std::array<std::int32_t, kCount> input{};
    std::array<std::int32_t, kCount> output{};
    for (std::size_t i = 0; i < kCount; ++i) {
      const auto magnitude = static_cast<std::int32_t>(i + 1);
      input[i] = (i % 2 == 0) ? magnitude : -magnitude;
    }

    // Intentionally process-lifetime ownership. No queue destructor on failure,
    // no in_order property (host pipe operations must progress beside kernel).
    auto *queue = new sycl::queue(
        sycl::ext::intel::fpga_selector_v,
        [](sycl::exception_list exceptions) {
          for (const auto &exception : exceptions) {
            try {
              std::rethrow_exception(exception);
            } catch (const std::exception &e) {
              std::cerr << "Asynchronous SYCL error: " << e.what() << '\n';
            } catch (...) {
              std::cerr << "Unknown asynchronous SYCL error\n";
            }
          }
          Finish(EXIT_FAILURE);
        });
    auto &q = *queue;
    check_deadline();
    if (!q.get_device().has_extension("cl_intel_program_scope_host_pipe")) {
      std::cerr << "Required host-pipe extension is unavailable\n";
      Finish(EXIT_FAILURE);
    }
    std::cout << "CSR host-pipe FPGA Test on "
              << q.get_device().get_info<sycl::info::device::name>() << '\n';
    std::cout.flush();

    // Exactly one finite kernel invocation, with no global-memory payloads or
    // feeder/drainer kernels. Blocking device writes propagate backpressure.
    const sycl::event kernel = q.single_task<CsrTransformID>([] {
      for (std::size_t i = 0; i < kCount; ++i) {
        const std::int32_t value = InputPipe::read();
        OutputPipe::write(value * 3 + 7);
      }
    });

    // Deliberately postpone draining briefly after the first accepted send.
    // Retry failed sends without losing/advancing their payload. The delay is
    // time-based, NOT gated on filling an assumed pipe capacity, so it ends
    // even if backpressure prevents all further sends.
    bool drain_pause_started = false;
    auto resume_drain = Clock::now();
    while (sent < kCount || received < kCount) {
      check_deadline();
      bool progressed = false;
      if (received < kCount && Clock::now() >= resume_drain) {
        bool success = false;
        const auto value = OutputPipe::read(q, success);
        if (success) {
          output[received++] = value;
          progressed = true;
        } else {
          ++read_retries;
        }
      }
      check_deadline();
      if (sent < kCount) {
        bool success = false;
        InputPipe::write(q, input[sent], success);
        if (success) {
          ++sent;
          progressed = true;
          if (!drain_pause_started) {
            drain_pause_started = true;
            resume_drain = Clock::now() + std::chrono::milliseconds(10);
          }
        } else {
          ++send_retries;
        }
      }
      check_deadline();
      q.throw_asynchronous();
      if (!progressed) std::this_thread::yield();
    }

    // Receiving the last token alone is not a kernel-completion indication.
    // Poll only this finite event under the SAME overall deadline. No wait(),
    // wait_and_throw(), or queue-wide wait (including hidden teardown waits).
    for (;;) {
      check_deadline();
      const auto status =
          kernel.get_info<sycl::info::event::command_execution_status>();
      check_deadline();
      q.throw_asynchronous();
      if (status == sycl::info::event_command_status::complete) break;
      std::this_thread::yield();
    }

    std::size_t mismatches = 0;
    for (std::size_t i = 0; i < kCount; ++i) {
      // Independent wider host arithmetic; check every ordered output.
      const std::int64_t expected = std::int64_t{input[i]} * 3 + 7;
      if (std::int64_t{output[i]} != expected) {
        if (mismatches == 0) {
          std::cerr << "First mismatch at " << i << ": input=" << input[i]
                    << " expected=" << expected << " got=" << output[i]
                    << '\n';
        }
        ++mismatches;
      }
    }
    check_deadline();
    std::cout << "FPGA Test " << (mismatches == 0 ? "PASSED" : "FAILED")
              << ": checked=" << kCount << " mismatches=" << mismatches
              << " send_retries=" << send_retries
              << " empty_reads=" << read_retries << '\n';
    Finish(mismatches == 0 ? EXIT_SUCCESS : EXIT_FAILURE);
  } catch (const std::exception &e) {
    std::cerr << "FPGA Test error: " << e.what() << "; sent=" << sent
              << " received=" << received << '\n';
    Finish(EXIT_FAILURE);
  } catch (...) {
    std::cerr << "FPGA Test unknown error\n";
    Finish(EXIT_FAILURE);
  }
}
