"""Exercise only the admission delta validator; no remote/native execution."""
import ast
import copy
import hashlib
import json
from pathlib import Path
from typing import Any

E=Path(__file__).resolve().parent
source=E/'admit04.py';out=E/'admission-delta-tests04.json'
assert not out.exists()
tree=ast.parse(source.read_text())
funcs: list[ast.stmt]=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='validate_delta']
assert len(funcs)==1
W=Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_24')
namespace: dict[str,Any]={'W':W,'J':W/'syn/board/ia840f/syn_top'}
exec(compile(ast.Module(body=funcs,type_ignores=[]),str(source)+'::delta-only','exec'),namespace)
validate=namespace['validate_delta']
old=json.loads((E/'prepared01-readback/compile-inputs.draft01.json').read_text())
plan=json.loads((E/'admission-plan03.json').read_text())
added={str(Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-24')/name):'f'*64 for name in plan['review_files']}
base=copy.deepcopy(old)
base.update(parent_execution_accepted=True,prerequisites=dict(old['prerequisites'],**added),authority_basis=plan['new_authority_basis'],validation_scope=plan['new_validation_scope'])
rows=[]

def trial(name,mutate=None,accept=False):
    candidate=copy.deepcopy(base)
    if mutate:mutate(candidate)
    error=None
    try:validate(old,candidate,added);passed=True
    except (AssertionError,KeyError) as exc:passed=False;error=type(exc).__name__
    assert passed is accept,(name,passed,accept)
    rows.append({'case':name,'expected_accept':accept,'observed_accept':passed,'error_type':error})

trial('exact reviewed metadata admission',accept=True)
trial('approval stays false',lambda m:m.update(parent_execution_accepted=False))
trial('integer is not boolean approval',lambda m:m.update(parent_execution_accepted=1))
trial('missing old prerequisite',lambda m:m['prerequisites'].pop(next(iter(old['prerequisites']))))
trial('unreviewed extra prerequisite',lambda m:m['prerequisites'].update({'/unexpected':'e'*64}))
trial('stale first-attempt wording',lambda m:m.update(validation_scope=old['validation_scope']))
trial('broader authority',lambda m:m.update(authority_basis='arbitrary native operation'))
trial('wrong native stage',lambda m:m.update(stage='ip_regeneration'))
trial('wrong work root',lambda m:m.update(work=str(W)+'x'))
trial('extra native argument',lambda m:m['contexts'][0]['argv'].append('--unreviewed'))
trial('changed executable hash',lambda m:m['runtime_hashes'].__setitem__(next(iter(m['runtime_hashes'])),'0'*64))
trial('changed immutable input',lambda m:m['critical_inputs'].__setitem__(next(iter(m['critical_inputs'])),'0'*64))
trial('removed mutable input checks',lambda m:m['preflight_only_inputs'].clear())
trial('changed mutable role',lambda m:m['runtime_output_roles'].__setitem__(next(iter(m['runtime_output_roles'])),'unrestricted'))
trial('changed affinity',lambda m:m.update(cpus=m['cpus'][:-1]))
trial('weakened acceptance',lambda m:m.update(acceptance_requirements=[]))
trial('changed runner',lambda m:m.update(runner_sha256='0'*64))
trial('changed CMake',lambda m:m.update(cmake_sha256='0'*64))
trial('missing toolchain field',lambda m:m.pop('toolchain'))
result={'success':True,'scope':'AST-extracted actual pure validate_delta helper only; not full admission or native integration','native_tool_execution':False,'remote_execution':False,'synthetic_added_review_hashes':True,'admission_script_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'count':len(rows),'cases':rows}
out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'success':True,'cases':len(rows),'native_tool_execution':False,'output':str(out)},indent=2))
