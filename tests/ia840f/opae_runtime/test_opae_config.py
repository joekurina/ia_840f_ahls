"""Inert config-parser checks; never loads libopae-c or a backend."""
import argparse
import json
import subprocess
from pathlib import Path


def parse(probe, config):
    result = subprocess.run([str(probe), str(config)], capture_output=True,
                            text=True, timeout=10, check=False)
    if result.returncode:
        raise RuntimeError(f"parser rc={result.returncode}: {result.stderr}")
    rows = [line.split(" ", 5) for line in result.stdout.splitlines()]
    if any(len(row) != 6 for row in rows):
        raise RuntimeError("invalid parser output")
    return {"rows": rows, "stderr": result.stderr, "rc": result.returncode}


def exact_candidate(rows):
    expected = [
        ["8086", "bcce", "8086", "1771", "/work/sdk-build/lib/libxfpga.so", "{}"],
        ["8086", "bccf", "8086", "1771", "/work/sdk-build/lib/libxfpga.so", "{}"],
    ]
    if rows != expected:
        raise ValueError(f"Expected exactly two DFL-only rows, observed {len(rows)}")


def main():
    args = argparse.ArgumentParser()
    args.add_argument("--probe", type=Path, required=True)
    args.add_argument("--config", type=Path, required=True)
    args.add_argument("--output", type=Path, required=True)
    opts = args.parse_args()
    result = parse(opts.probe, opts.config)
    try:
        exact_candidate(result["rows"])
    except ValueError as error:
        result.update(passed=False, error=str(error))
        opts.output.write_text(json.dumps(result, indent=2) + "\n")
        return 1
    result["passed"] = True
    opts.output.write_text(json.dumps(result, indent=2) + "\n")
    print("FPGA_TEST_OPAE_CONFIG_PASS rows=2 backend=xfpga no_backend_execution=true")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
