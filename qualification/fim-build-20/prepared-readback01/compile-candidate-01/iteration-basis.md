# Work20: recover the offline Python callback failure

Same saved Work18 inputs, preserved original, new work tree and authorization. Work19 is failed/spent and retained. SOURCE baseline is Work19's issued source inventory; copied design baseline remains completed Work18's recorded precompile inputs. QSF/SDC byte-identical. This is still the toolchain-only design comparison, with an execution-environment compatibility fix, not an HDL/timing change.

Evidence: ../fim-build-19/python-env-diagnostic01.json.gz SHA256 3b7ca2a2b75ff3d2fc52a54134ef30b2106d471424af6efb41ce4d6fd76662f7; raw import failed, clean Python import/sha256/uuid5/ssl passed; no remaining native tools. Source inspection found precisely two Tcl Python call sites in the inspected native source subtrees. Work19 termination confirmed by pidfd-bound signals; native raw rc -15, outer143. No hardware access.
