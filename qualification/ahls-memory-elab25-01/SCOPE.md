# Corrected memory-IP Quartus 25.1 elaboration

Execute the installed, now-help-confirmed `quartus_syn --analysis_and_elaboration` on a fresh standalone project. Copy and hash-verify the complete 222-member import02 generated inventory; retain four native QIPs and their library assignments. The finite QIP ledger resolves 177 file edges to 174 unique targets. Root and child QIPs must all be included; the system QIP alone does not include child HDL.

Preserve original import inputs, corrected source and completed FIM. Explicit family/device/top, two CPUs and 16 GiB per-process address-space limit; require at least 80 GB available RAM, 10 GB free disk and no observed competing Quartus stage process. Native child deadline is 600 seconds with the existing owned-group supervisor. This is not a sandbox or a global aggregate-memory guarantee.

This step does not fit, time, program, access a device, exercise DDR or run a numerical kernel test. No custom FIM hooks or IP-generation stage are part of this project. Quartus HDL elaboration is the result sought; full synthesis, DMA/PIM integration, clock/reset behavior and hardware remain separate. DDR simulation remains SKIPPED BY USER.

Probe01 completed both native help/version commands with effective rc0. Its outer pane closed before stdout readback; durable result bytes were recovered/hash-verified in a separate ordinary-file-only tmux window. The probe was not rerun. Its original shell exit code was not independently captured.
