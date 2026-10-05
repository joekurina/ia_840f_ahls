# clocks — build accepted, hardware unqualified

FINAL `deleg_e6797d57` accepts the recorded failure disposition, **not a clock pass**. [Disposition86](FINAL-DISPOSITION86.json), [failure83](failure-disposition83.json), [review83](review-manifest83.json).

## What actually ran

Native CMake PR flow under Quartus26.1.1 Build130 exited0/effective0, all21boundinputs preserved. Upstream auto-frequency target, no RTL edits. [Build readback](build-artifacts80-collection.json).

GBS SHA256 `d29b3c059316aac396fe76ed6cfeaf79698a35919e4c1bb1a4f5fdfacb18ee75`; interfacefc603c44-5c8f-5e94-bcbe-a5780030947c; AFUbd9ccef3-0b2c-4bb2-901f-6c7486821188. Packaged759/379.5MHz values are metadata, **not measured hardware frequencies**.

One normal-user `/usr/bin/fpgaconf 0000:4f:00.0 <GBS>` durably exited5 before successful PR, printing FailedtoopenUIO/Failedtosetuserclock. Rawsuccessfalse/hosts[] preserved. [Hardware receipts](hardware-result81-collection.json). **No host execution, clock measurement or successful PR qualification occurred.** Reviewed checked host built0 but was not run.

Ordinary [UIO metadata86](uio-metadata86.json) shows `/dev/uio0` UID0/GID0/mode0600, executionUID1000 cannotread/write. OPAE source lookup calls opae_uio_open. No permission/driver/system-forcepass changes or skip-userclock workaround; moveon under goal hardrule4. No postflight exists in this failed result, and none is inferred. Images/oversized log remain remote-only with hash references.

No active job. Overall campaign still has other pending targets; this example is disposed UNQUALIFIED with an honest access blocker.
