"""Read-only local source verification. No launcher/collector imports or execution."""
import ast
import base64
import hashlib
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
DIAGNOSTIC = HERE.parent / 'runtime-metadata-diagnostic-01'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def literals(name, wanted):
    tree = ast.parse((HERE / name).read_bytes(), feature_version=(3, 9))
    return {n.targets[0].id: ast.literal_eval(n.value) for n in tree.body
            if isinstance(n, ast.Assign) and isinstance(n.targets[0], ast.Name)
            and n.targets[0].id in wanted}


def main():
    print('Local verification interpreter:', sys.version.replace('\n', ' '))
    for name in ('launcher.py', 'transport.py', 'test_launcher.py', 'validate_local.py'):
        data = (HERE / name).read_bytes()
        ast.parse(data, feature_version=(3, 9))
        print('Python 3.9 grammar PASS:', name)
        print('length=%d sha256=%s' % (len(data), sha(data)))
    t = literals('transport.py', {'LENGTH', 'SHA256', 'PAYLOAD'})
    launcher = (HERE / 'launcher.py').read_bytes()
    assert base64.b64decode(t['PAYLOAD'], validate=True) == launcher
    assert t['LENGTH'] == len(launcher) and t['SHA256'] == sha(launcher)
    print('Transport launcher binding: PASS (static only)')
    c = literals('launcher.py', {'COLLECTOR_LENGTH', 'COLLECTOR_SHA', 'COLLECTOR_B64'})
    collector = (DIAGNOSTIC / 'collector.py').read_bytes()
    assert base64.b64decode(c['COLLECTOR_B64'], validate=True) == collector
    assert c['COLLECTOR_LENGTH'] == len(collector) == 13851
    assert c['COLLECTOR_SHA'] == sha(collector) == '6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897'
    print('Original collector byte/hash/length binding: PASS (not executed)')
    for line in (DIAGNOSTIC / 'SHA256SUMS').read_text().splitlines():
        expected, name = line.split(maxsplit=1)
        assert '/' not in name and name not in ('.', '..')
        assert sha((DIAGNOSTIC / name).read_bytes()) == expected
        print('Original diagnostic manifest PASS:', name)
    print('No Python 3.9 runtime, remote host, or collector execution claimed.')


if __name__ == '__main__':
    main()
