// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`default_nettype none

module sld_hub_ctrl_sld_node #(
    parameter ENABLE_JTAG_IO_SELECTION = 0,
    parameter USE_TCK_ENA = 0
  )
  (
    input wire  tck,
    input wire  tck_ena,
    input wire  tms,
    input wire  tdi,
    input wire  select_me,
    output wire tdo
  );

// synthesis read_comments_as_HDL on
//   altera_sld_host_endpoint #(
//     .ENABLE_JTAG_IO_SELECTION (ENABLE_JTAG_IO_SELECTION),
//     .CONTROL("hubctrl"),
//     .NAME("sldhub"),
//     .HOST_PRIORITY (200),
//     .USE_TCK_ENA(USE_TCK_ENA)
//   ) jtag_access (
//     .tck (tck),
//     .tck_ena(tck_ena),
//     .tms (tms),
//     .tdi (tdi),
//     .select_this (select_me),
//     .tdo (tdo)
//   );
// synthesis read_comments_as_HDL off

endmodule

`default_nettype wire

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "dfkEZ/hiGvUJkF8KbxOF7EaJUasRHyAcSeIdt20Ddzpo2sqBAHvNwvG9QYvoI3ytZ8zAxIGJ/UVd26a4kOtiAYHnu5ALjOQDenz9m4r4dwqS2IbFa9xZB3xxiM/ntMp8dmSDg8L1MdeggKM84bTq2c2FjeM4kPZYMEnCrm03kcolnE/odJeqvmffePW+eEj5NJMStK8EsXS6puh7ufNZHCwXr1UzXJK7r1us//K6qpQZr8LiCYfZSBUsyk93O75kWvoMabekgQfqUml7t9Bl0NOWcrqoWZPX88hyUkizSJsjiLxh/93r0vP7AJbCztulpBgIrlV0vbfqy6z4V4iJeFqrJDfGqT+3N/B7g0XjtYAch9s4GlvKQeFe7jMrHs+Rf4I/tPeFu9VvzJaKTzomFfeeKfK4cUXySFlrqGu8gQBkjc5FZgIFzs8cvphSU+4PjvkbXwNbA0z84qPoh+xZLwquY/KifjdIIyVIqwk8C3MYbwe75GF4qhZIVgHFq1CiK08jy7L+mB55R1A3M2msPbnAJN1FBEokDF4k+E7I/e3kmQ92g7AmWZlFLtf/ydJaW+RbojGyiuWi21hVMXam9UdEw6trfPWOcrLQrjNyEiK6qP1fVsvswB91Gvu9Aw5WqN1Rd0j59cjElPdB9t378XPGUApk0nOjFzPyws/v2YaRPIC4KHa0VhWUbp4oaEGL+z89hvgn/daYDFcOf2pM+aIGP0GjcAgfxk4v8OoP12DzFg4kId28lAs7wwwvbgQ020kkpUm8Fl/047Gdc9D8rFI+Fp05o+l8NMCZ1015Lr9AnHqnkfKhrUSZtgNp1ha+Q+3q9a/ucSGAjjJ9l2nRN3TvQmNk7tYZQis8aWGFGfCpshZU3cIUhcIzZbpRjQsmRa0K+rBKubXrcIJTssWByFCRNvqufkD68fOx9jsyybnvRxF+COv59ZHsLOy/Qo6XtcQ2m/b97i7WQZB//9uB/vgBstqaT00QXXgCVktxHKSFnMVZYIqujI5xPUldY87j"
`endif