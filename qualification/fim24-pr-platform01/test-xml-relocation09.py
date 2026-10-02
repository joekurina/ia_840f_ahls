"""Exercise only the byte-preserving XML helper on owned inert fixtures."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import tempfile

E = Path(__file__).resolve().parent
OUT = E/'xml-relocation-inert09.json'
assert not OUT.exists()
source = E/'candidate03/xml_source_relocation.py'
spec = importlib.util.spec_from_file_location('xml_relocation_fixture', source)
assert spec is not None and spec.loader is not None
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
root = Path(tempfile.mkdtemp(prefix='pr24-xml-inert-', dir=os.environ['TMPDIR']))
dest = root/'copy'
dest.mkdir()
(dest/'src').mkdir()
(dest/'src/a.sv').write_text('INERT\n')
(dest/'src/a&b.sv').write_text('INERT\n')
outside = root/'outside.sv'
outside.write_text('INERT\n')
(dest/'src/escape.sv').symlink_to(outside)
old = '/home/uwb_student00/ahls/new_BSP/work_fixture'
rows = []


def trial(name, raw, expected=None, count=0, unmapped=0, reject=False):
    before = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in root.rglob('*') if p.is_file()}
    error = None
    try:
        result, edits, gaps = module.relocate(raw, dest)
    except (AssertionError, ValueError) as exc:
        assert reject, (name, repr(exc))
        error = type(exc).__name__
    else:
        assert not reject, name
        assert result == (raw if expected is None else expected), name
        assert len(edits) == count and len(gaps) == unmapped, (name, edits, gaps)
    after = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in root.rglob('*') if p.is_file()}
    assert before == after, name
    rows.append({'case': name, 'expected_reject': reject, 'error': error, 'fixture_files_unchanged': True})


for container in ('sourceFiles', 'childSourceFiles', 'generatedFiles', 'childGeneratedFiles'):
    raw=(f'<deploy><entity><{container}><file path="{old}/src/a.sv"/></{container}></entity></deploy>').encode()
    trial(container, raw, raw.replace(old.encode(), str(dest).encode()), count=1)
raw=(f'<deploy outputDirectory="{old}/src/"><entity/></deploy>').encode()
trial('deployment directory metadata', raw, raw.replace(old.encode(), str(dest).encode()), count=1)
raw=(f'<deploy><entity><parameter value="{old}/src/a.sv"/><messages><message>{old}/src/a.sv</message></messages></entity></deploy>').encode()
trial('parameter and message text untouched', raw)
raw=(f'<deploy><entity><sourceFiles><file path="{old}/src/missing.sv"/></sourceFiles></entity></deploy>').encode()
trial('missing source retained and reported', raw, unmapped=1)
raw=(f'<deploy><entity><sourceFiles><file path="{old}/src/escape.sv"/></sourceFiles></entity></deploy>').encode()
trial('outside symlink retained and reported', raw, unmapped=1)
raw=(f"<?xml version='1.0'?>\n<deploy><!-- unchanged > -->\n<entity><sourceFiles><file note='a>b' path='{old}/src/a.sv' /></sourceFiles></entity></deploy>\n").encode()
trial('single quotes and quoted greater-than preserved', raw, raw.replace(old.encode(),str(dest).encode()), count=1)
raw=(f'<deploy><entity><sourceFiles><file path="{old}/src/a&amp;b.sv"/></sourceFiles></entity></deploy>').encode()
trial('entity-encoded path rejected rather than normalized', raw, reject=True)
result={'success':True,'scope':'pure XML helper synthetic fixtures only; no project/vendor/native execution','count':len(rows),'cases':rows,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'scratch':str(root)}
OUT.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'success':True,'cases':len(rows),'native_tools_executed':False,'output':str(OUT)},indent=2))
