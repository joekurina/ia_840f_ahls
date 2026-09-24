"""FPGA Test: startup ordering with actual frontend and inert shared API."""
import argparse
import json
import os
import re
import subprocess
from pathlib import Path


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--launcher", type=Path, required=True)
    p.add_argument("--module", type=Path, required=True)
    p.add_argument("--missing-module", type=Path, required=True)
    p.add_argument("--config", type=Path, required=True)
    p.add_argument("--config-cases", type=Path, required=True)
    p.add_argument("--work", type=Path, required=True)
    opts = p.parse_args()
    opts.work.mkdir(exist_ok=False)
    original = opts.config.read_bytes()
    local_config = opts.work / "candidate.cfg"
    local_config.write_bytes(original)
    prefix = [str(opts.launcher), "--config", str(local_config),
              "--module", str(opts.module)]
    tail = ["--inspect-qualified-memory-afu", "0000:ab:1f.7"]
    records = []
    clean = {k: v for k, v in os.environ.items()
             if not k.startswith(("LD_", "STARTUP_", "MEMORY_", "LIBOPAE_"))
             and k not in ("WITH_ASE", "OPAE_EXPLICIT_INITIALIZE")}

    def run(name, rc, argv=None, environment=None, ctor=True, init=True, app=True, fini=True):
        env = dict(clean)
        env.update(environment or {})
        process = subprocess.run(argv or prefix + tail, env=env,
                                 capture_output=True, text=True, timeout=5)
        out = process.stdout
        records.append(dict(name=name, argv=argv or prefix + tail, rc=process.returncode,
                            stdout=out, stderr=process.stderr))
        require(process.returncode == rc, f"{name}: unexpected return {process.returncode}")
        require(out.count("STARTUP_CTOR") == int(ctor), f"{name}: constructor count")
        require(out.count("STARTUP_INIT ") == int(init), f"{name}: initialize count")
        require(out.count("STARTUP_FINALIZE") == int(fini), f"{name}: finalize count")
        require(bool(re.search(r"^API ", out, re.M)) == app, f"{name}: API activity")
        if ctor:
            require("STARTUP_CTOR explicit=1 ase=0 logfile=0" in out, f"{name}: environment")
        if init:
            require("STARTUP_CONFIG_SEALED" in out, f"{name}: configuration not sealed")
        if app:
            require(out.index("STARTUP_INIT") < out.index("API 1 "), f"{name}: ordering")
        if fini:
            require(out.rindex("API ") < out.index("STARTUP_FINALIZE"), f"{name}: finalization ordering")
        return out

    try:
        out = run("pass", 0)
        require("reads=7 opens=1 maps=1 failed=0 remaining=0 allowed_remaining=0" in out, "success scoreboard")
        api_count = len(re.findall(r"^API ", out, re.M))
        run("dirty-environment", 0, environment={"WITH_ASE": "1", "OPAE_EXPLICIT_INITIALIZE": "0",
             "LIBOPAE_CFGFILE": "/nonexistent/config", "LIBOPAE_LOGFILE": str(opts.work / "must-not-exist.log"), "LIBOPAE_LOG": "4"})
        require(not (opts.work / "must-not-exist.log").exists(), "constructor log-file effect")
        run("initialize-error", 1, environment={"STARTUP_FAIL_INIT": "1"}, app=False, fini=False)
        run("finalize-error", 1, environment={"STARTUP_FAIL_FINALIZE": "1"})
        run("sealed-original-replacement", 0, environment={"STARTUP_REPLACE_CONFIG": str(local_config)})
        require(local_config.read_bytes() == b"{", "replacement fixture did not mutate original")
        local_config.write_bytes(original)
        for case in ("zero", "multiple", "enum_partial_error"):
            run(case, 1, environment={"MEMORY_CASE": case})
        for index in range(1, api_count + 1):
            run(f"api-fault-{index}", 1, environment={"MEMORY_FAIL_AT": str(index)})
        for word in range(7):
            for bit in range(64):
                run(f"word-{word}-bit-{bit}", 1,
                    environment={"MEMORY_MUTATE_WORD": str(word), "MEMORY_MUTATE_BIT": str(bit)})
        bad = [[], ["--help"], ["--run-qualified-csr-test", "0000:ab:1f.7"], tail + ["extra"]]
        bad += [[tail[0], bdf] for bdf in ["0:ab:1f.7", "0000:ab:20.7", "0000:ab:1f.8", "0000:ab:1f.7x",
                "0000:ab:1f.7 ", "0000:ag:1f.7", "0000:ab:1f.-", "0000:ab:1f."]]
        for index, bad_tail in enumerate(bad):
            run(f"invalid-args-{index}", 2, argv=prefix + bad_tail, ctor=False, init=False, app=False, fini=False)
        for path in sorted(opts.config_cases.glob("*.json")):
            if path.name in ("candidate.json", "results.json"):
                continue
            argv = list(prefix + tail)
            argv[2] = str(path)
            run("reject-" + path.stem, 2, argv=argv, ctor=False, init=False, app=False, fini=False)
        for name, data in [("empty", b""), ("nul", original + b"\0"), ("oversized", b" " * 32769)]:
            path = opts.work / name
            path.write_bytes(data)
            argv = list(prefix + tail)
            argv[2] = str(path)
            run("reject-" + name, 2, argv=argv, ctor=False, init=False, app=False, fini=False)
        fifo = opts.work / "fifo"
        os.mkfifo(fifo)
        link = opts.work / "config-link"
        link.symlink_to(local_config)
        for name, path in [("fifo", fifo), ("symlink", link), ("directory", opts.work), ("absent", opts.work / "absent")]:
            argv = list(prefix + tail)
            argv[2] = str(path)
            run("reject-" + name, 2, argv=argv, ctor=False, init=False, app=False, fini=False)
        for name, module, rc, ctor in [("relative-module", Path("relative.so"), 2, False),
             ("absent-module", opts.work / "absent.so", 2, False),
             ("invalid-elf", local_config, 1, False),
             ("missing-entry", opts.missing_module, 1, True)]:
            argv = list(prefix + tail)
            argv[4] = str(module)
            run(name, rc, argv=argv, ctor=ctor, init=False, app=False, fini=False)
        print(f"FPGA_TEST_EXPLICIT_STARTUP_PASS processes={len(records)} api_faults={api_count} bit_faults=448")
        return 0
    finally:
        (opts.work / "results.json").write_text(json.dumps({"inert_only": True, "records": records}, indent=2) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
