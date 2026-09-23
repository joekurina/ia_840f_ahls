# path02 — strict SystemVerilog process ownership failure

Added only the installed same-release altera_lnsim_ver library to the search/bindings; native vdir confirms altera_syncram. All527DUT/test source inputs unchanged frompath01. All448HDL units compile (vlog0), but native vsim12/outer12 rejects loading withvopt7061 for kword_address_cpipe[1] andthread_count_inc_vpipe in generated read/writeLSUs, plus two2064back-end errors. No time-stepped numerical result. Preserve errors and244warnings. No diagnostic suppression, vendorinstall edit or fake model replacement.

Next step is to inspect actual process ownership/index ranges and native parameters before selecting any source correction or simulator-supported handling. Fullkernel function remains unproven.
