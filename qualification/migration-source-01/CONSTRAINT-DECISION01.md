# PCIe constraint decision — four-line baseline

Joe selected **“Four-line”** in response to the migration campaign's required choice. Use the proven Work15–Work21 divider declaration; do not integrate the parked 43-line guarded candidate or reopen its reviews as a prerequisite.

The maintained `ofs-agx7-pcie-attach/syn/shared_config/top.sdc` was rehashed after selection and remains `b706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc`. The Work21 fit-only 10 ps hold-margin overlay must still be carried into the fresh build with its `quartus_sta` signoff-skip guard, as separately required by Phase 3. Preserve the exact four-line divider block when carrying that overlay; do not confuse the maintained-source file hash with a copied WORK file containing the additional accepted margin overlay.

The choice removes the Phase 2 decision hold. It does not itself issue a native run authorization or accept generated IP, timing, a persona, deployment, or hardware. Continue under the already requested migration scope, with fresh run IDs, exact source/tool bindings, finite resource/deadline limits and owned tmux. All post-compile clock-table, invalid-clock, transfer/exception and net-delay gates still apply.
