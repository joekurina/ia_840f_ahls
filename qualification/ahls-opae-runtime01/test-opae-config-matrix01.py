"""Exercise only SDK JSON parsing, not initialization or plugin loading."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "config_checks", Path(__file__).with_name("test_opae_config.py"))
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--probe", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--work", type=Path, required=True)
    opts = parser.parse_args()
    opts.work.mkdir(exist_ok=False)
    original = json.loads(opts.candidate.read_text())
    default = checks.parse(opts.probe, "--null")
    cases = []

    def case(name, data, expected):
        path = opts.work / (name + ".json")
        path.write_text(data if isinstance(data, str) else json.dumps(data))
        result = checks.parse(opts.probe, path)
        rows = result["rows"]
        if expected == "fallback":
            ok = rows == default["rows"]
        elif expected == "empty":
            ok = rows == []
        elif expected == "exact":
            checks.exact_candidate(rows)
            ok = True
        elif expected == "different":
            try:
                checks.exact_candidate(rows)
            except ValueError:
                ok = bool(rows) and rows != default["rows"]
            else:
                ok = False
        else:
            raise ValueError(expected)
        cases.append(dict(name=name, expected=expected, passed=ok, **result))
        if not ok:
            raise RuntimeError(f"Unexpected SDK parser behavior in {name}")

    case("candidate", original, "exact")
    case("malformed-json", "{", "fallback")
    case("missing-configs", {"configurations": original["configurations"]}, "fallback")
    changed = copy.deepcopy(original)
    changed["configs"] = []
    case("empty-configs", changed, "fallback")
    changed = copy.deepcopy(original)
    changed["configs"] = ["not-present"]
    case("missing-selected-config", changed, "fallback")
    mutations = [
        ("disabled-config", lambda c: c.update(enabled=False), "fallback"),
        ("missing-devices", lambda c: c.pop("devices"), "fallback"),
        ("wrong-id-count", lambda c: c["devices"][0].update(id=["0x8086"]), "fallback"),
        ("invalid-id-string", lambda c: c["devices"][0]["id"].__setitem__(1, "0xbcZZ"), "fallback"),
        ("missing-opae", lambda c: c.pop("opae"), "fallback"),
        ("missing-plugin", lambda c: c["opae"].pop("plugin"), "fallback"),
        ("missing-module", lambda c: c["opae"]["plugin"][0].pop("module"), "fallback"),
        ("missing-plugin-configuration", lambda c: c["opae"]["plugin"][0].pop("configuration"), "fallback"),
        ("unknown-device-name", lambda c: c["opae"]["plugin"][0].update(devices=["absent"]), "fallback"),
        ("disabled-plugin", lambda c: c["opae"]["plugin"][0].update(enabled=False), "empty"),
        ("empty-plugin-devices", lambda c: c["opae"]["plugin"][0].update(devices=[]), "empty"),
        ("wrong-device-id", lambda c: c["devices"][1]["id"].__setitem__(1, "0xbcc0"), "different"),
        ("wrong-subsystem", lambda c: c["devices"][1]["id"].__setitem__(3, "0x1770"), "different"),
        ("vfio-substitution", lambda c: c["opae"]["plugin"][0].update(module="libopae-v.so"), "different"),
        ("missing-absolute-path", lambda c: c["opae"]["plugin"][0].update(module="libxfpga.so"), "different"),
        ("duplicate-plugin", lambda c: c["opae"]["plugin"].append(copy.deepcopy(c["opae"]["plugin"][0])), "different"),
        ("wildcard-subsystem", lambda c: c["devices"][1]["id"].__setitem__(3, "*"), "different"),
    ]
    for name, change, expected in mutations:
        changed = copy.deepcopy(original)
        change(changed["configurations"]["ia840f_caps01"])
        case(name, changed, expected)
    report = {"default": default, "cases": cases,
              "passed": all(c["passed"] for c in cases),
              "hardware_access": False, "backend_loaded": False}
    (opts.work / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"FPGA_TEST_OPAE_CONFIG_MATRIX_PASS cases={len(cases)} "
          f"default_rows={len(default['rows'])} backend_loaded=false")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
