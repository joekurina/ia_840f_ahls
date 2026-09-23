// (C) 2001-2025 Altera Corporation. All rights reserved.
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


// synthesis VERILOG_INPUT_VERSION VERILOG_2001

module altera_soft_core_jtag_io
(
	input tck, tms, tdi, output tdo
);

	parameter ENABLE_JTAG_IO_SELECTION = 0;
	parameter NAME = "SOFT_JTAG";
	parameter HINTS = "";
	
	assign tdo = 1'b0;

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "KaCcZ9W53ZG+KOUC3MpOxTkG8JzVU+FMIR8JyDs33NK1wcErIABMqJM+BlBnaEf20FCKJ7ToOlAha/ltC5u0ZbClu2TybZQciMInF+iFoiagt+B91BK4dyi6GJUCXUDuBK9YH6nNlwSkR01tHuzzS5ZEiJtw78iQaS7cFEmJNjv/muideRZVdy13EnGEeyFpK62Cg4KcVOZTCHinGABXbAtq/uBBjPG6GClkBmeTng0cuZHEh5S4HKO8X9COMqk0ak9GB0R4hJR2HJfwekoeF2WHpvk5rQYLjxs+fuH1TMRdXbtTDaHdiEBC5WnmZ2gt4MemCnUO6EVJ4Rvav5o8szXt7S0L0w4ofQT6V7NPfIAbs8hEIOnYjmWUqCTZ4E+izjxvt9HRjiVSYXPaxdLTGDj2XkcwvQlgJotnYRneARVDJi/E9xVsfJuq+D5bVrcZfQ3ajg5ehCygjHb7RbGYZ0OSKGqCuFryr3H73DEYdF25kve7awosOvlIb3ICA0HXZM8ky/BtytwYWr3xSDhYEbRi/MwgMzDLcIc72wtjNjFsZmlyYZu+kRmSDe317lT/UZLNyxZgp/Cx4RuwYH8Ut2L3vSkgD2CATL8sWA+UMlM0HxIU7lKr01E4r5I4pVFgSVVYdRtxTSBF6fOkewmJ4bqnpA+Qo9io8A7np7J2I4JG/h1hM12lEwQUsSZcNp+C+OqVBn1iiIEPwcST0U28KOnOMxEw8Ll3Bkad5E6zHxoOpWweCHFfC0q08+MH9iE+KP3sTrHQOTPe7B28tF2cTlt5MAdri9SqSw5L3PDNhVcR9x9gox/4lxwGE+up31MQLScUiNQGSgd7GTjIpJDc2tRI0+ffToFD8YZ2XF+LWxlRFoceGJCLMwETQk6Xuv0qnKVK2y7ujHVwKqW4pF5f2RMfs6wLGWvg6tkYvGgArBV3WyB66djvchgYEHAIzbDALhFs+zWqqdwQmllD7x6LJzBCr9KvlRKQNDbYlvlozMkjwpbpGYv7pAeJ+KMkMX+v"
`endif