"""Build blocked draft + verify staging. No authorization issue or vendor execution."""
from pathlib import Path
import base64,hashlib,json,os,sys,subprocess
N=Path('/home/uwb_student00/ahls/new_BSP');C=N/'ofs-agx7-pcie-attach';W=N/'work_ia840f_fim_10';OLD=N/'work_ia840f_ipgen_04';E=N/'qualification/fim-build-10'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for name,data in ARTIFACTS.items():
 p=E/name
 with p.open('xb') as f:f.write(base64.b64decode(data))
 assert sha(p)==hashlib.sha256(base64.b64decode(data)).hexdigest()
sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'));import ia840f_compile_gate as gate;common=gate.common
old=json.loads((C/common.RECORD_REL).read_text())
overlays=json.loads((E/'overlay-sha256.json').read_text())
source={t:common.inventory(C/t) for t in common.TREES}
for rel,digest in overlays.items():
 tree,rest=rel.split('/',1);source[tree][rest]=digest
commands=gate.allowed_commands();contexts=[];cache={}
for args in commands:
 exe='/opt/altera/26.1.1/quartus/linux64/'+args[0]
 if exe not in cache:cache[exe]=sha(Path(exe))
 contexts.append(dict(executable=exe,sha256=cache[exe],argv=args,cwd=str(gate.PROJECT)))
Q=Path('/opt/altera/26.1.1/quartus/common/tcl/internal')
deps={str(p):sha(p) for p in (Q/'flow').glob('*.tcl')}
for p in [Q/'qsh_flow.tcl',Q/'qsh_flowengine.tcl',E/'issue_authorization.py',E/'launch_native_compile.py',E/'overlay-sha256.json',E/'source-before.json',E/'staging-receipt.json']:
 deps[str(p)]=sha(p)
for p in [Path('/opt/altera/26.1.1/quartus/linux64/libda_flng.so'),Path('/opt/altera/26.1.1/quartus/linux64/libsys_flow.so'),N/'qualification/fim-build-05/consumed-reviews.json']:
 deps[str(p)]=sha(p)
record=dict(schema=1,approved=False,accepted_execution=False,source_review_consumed=False,gate_review_consumed=False,
 ready_for_build=False,target='ia840f',part=common.PART,toolchain=common.VERSION,source=str(C),work=str(W),pim=str(common.PIM),
 permissions=['native-full-compile'],source_sha256=source,pim_sha256=common.inventory(common.PIM),tools=old['tools'],quartus_tools=old['quartus_tools'],contexts=contexts,
 native_argv=gate.TOP_ARGS,native_cwd=str(C),work_inventory=gate.work_inventory(),dependency_sha256=deps)
with (E/'compile-authorization.draft.json').open('x') as f:json.dump(record,f,indent=2)
# Independent readback. Historical Work04 and maintained files unchanged.
for rel,entry in json.loads((E/'work04-before.json').read_text()).items():
 p=OLD/rel
 assert ({'symlink':os.readlink(p)} if p.is_symlink() else {'sha256':sha(p)})==entry
for rel,digest in json.loads((E/'source-before.json').read_text()).items():assert (sha(C/rel) if (C/rel).exists() else None)==digest
assert gate.work_inventory()==json.loads((E/'compile-authorization.draft.json').read_text())['work_inventory']
for rel,digest in overlays.items():assert sha(W/rel)==digest and sha(E/'source-overlay'/rel)==digest
# Maintained native shell still uses Work05 gate; fresh Work07 rejects before logs.
env=dict(os.environ,OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(common.PIM),QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PYTHONDONTWRITEBYTECODE='1')
log=C/'build_fim_work_ia840f_fim_10.log';assert not log.exists()
r=subprocess.run(['bash',str(W/'ofs-common/scripts/common/syn/build_top.sh'),'--stage=compile','-k','-p','ia840f',str(W)],cwd=C,env=env,capture_output=True,text=True)
(E/'missing-record-rejection.log').write_text(r.stdout+r.stderr);assert r.returncode!=0 and not log.exists() and not gate.CLAIM.exists()
summary=dict(draft_sha256=sha(E/'compile-authorization.draft.json'),overlay_sha256=overlays,
 contexts=len(contexts),runtime_tools=len(cache),work_inventory_entries=len(record['work_inventory']),
 dependency_pins=len(deps),work04_readback_unchanged=True,maintained_source_readback_unchanged=True,
 stage_rejection_rc=r.returncode,rejection=r.stderr.strip(),native_log_absent=True,claim_absent=True,
 ready_for_build=False,accepted_execution=False,quartus_started=False)
(E/'handoff-verification.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
