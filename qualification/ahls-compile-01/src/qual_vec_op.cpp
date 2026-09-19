// AHLS qualification component — ahls-compile-01
// Purpose: smallest generic AHLS IP-generation exercise for IA-840F (AGFB027R25A2E2V)
// FIM integration. Element-wise vector op over a fixed 8-element vector with a
// mode select (3 CSR-mapped scalar args: a, b, mode) and an Avalon-MM CSR result
// register (pipe), plus the standard _di status/control block the generated IP
// provides (start/done/finish-counter). Dialect follows the pinned, currently
// supported HLS IP Gen 2026.1 authoring style as evidenced by:
//   hls-samples/Tutorials/Tools/platform_designer/add_oneapi/src/add.cpp
//   hls-samples/Tutorials/Tools/platform_designer/add_oneapi/CMakeLists.txt (report flow)
//
// out[i] = (mode == 0) ? (a + i) * b : (a - i) * b,  i = 0..7
// result CSR register <- XOR checksum of all 8 element results.

#include <stdlib.h>
#include <sycl/ext/altera/fpga_extensions.hpp>
#include <sycl/sycl.hpp>

namespace altera_exp = sycl::ext::altera::experimental;
namespace oneapi_exp = sycl::ext::oneapi::experimental;

// Result surfaces as a register in the CSR address space of the generated IP.
class ResultPipeID;
using ResultPipeProps = decltype(oneapi_exp::properties(
    altera_exp::uses_ready<false>,
    altera_exp::protocol<altera_exp::protocol_name::avalon_mm>));
using ResultPipe = altera_exp::pipe<ResultPipeID, int, 0, ResultPipeProps>;

// Forward-declared kernel name (global scope, best practice).
class IDQualVecOp;

struct QualVecOpKernel {
  // CSR-mapped arguments of the generated device interface.
  int a;
  int b;
  int mode;

  void operator()() const {
    int results[8];
#pragma unroll
    for (int i = 0; i < 8; ++i) {
      results[i] = (mode == 0) ? (a + i) * b : (a - i) * b;
    }
    int checksum = 0;
#pragma unroll
    for (int i = 0; i < 8; ++i) {
      checksum ^= results[i];
    }
    ResultPipe::write(checksum);
  }
};

int main() {
#if FPGA_SIMULATOR
  auto selector = sycl::ext::altera::fpga_simulator_selector_v;
#elif FPGA_HARDWARE
  auto selector = sycl::ext::altera::fpga_selector_v;
#else
  auto selector = sycl::ext::altera::fpga_emulator_selector_v;
#endif

  sycl::queue q(selector);

  q.single_task<IDQualVecOp>(QualVecOpKernel{3, 5, 0}).wait();

  return EXIT_SUCCESS;
}
