# path01 — simulator library binding failure

All448HDL units compiled with native vlog0. Native vsim12/outer12 rejected loading with17missing altera_syncram module errors. No functional time-stepped result or scoreboard was produced. Preserve the full logs/result and all527source inputs. Installed altera_mf_ver was present; this run did not search the library that supplies altera_syncram. Next change is a source/tool-bound same-release library search addition, not an RTL/model replacement or error suppression.
