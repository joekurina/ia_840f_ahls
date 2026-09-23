# Future native-run resource policy

Joe explicitly directed future runs to use **maximum available CPU cores and a 64 GiB limit**.

- Resolve the live allowed CPU set with `os.sched_getaffinity(0)` and use all of it.
- Set Quartus `NUM_PARALLEL_PROCESSORS` consistently to the available CPU count; CPU affinity alone does not remove an inherited two-thread QSF cap.
- Set per-process `RLIMIT_AS` soft/hard to `64 * 1024**3` bytes.
- Preserve current source/tool binding, free-memory/disk checks, no-competing-job checks, finite stage deadlines and owned-process supervision.
- Apply only in the next fresh run; record the exact resource and QSF delta. Do not edit frozen or running sources/settings.

The already-started CSR02 fitter retains its original two-CPU/32 GiB policy. Do not restart it just to apply this future-run instruction. The next justified native stage uses the new policy.
