#!/usr/bin/env python3
"""Integrate the bounded source delta; assemble/test an UNAPPROVED compile draft.
No vendor executable, OPAE library, FPGA device, udev or service is invoked.
"""
import base64, copy, datetime, gzip, hashlib, importlib.util, json, os, shutil, socket, subprocess, sys, traceback
from pathlib import Path
sys.dont_write_bytecode=True
B=Path('/home/uwb_student00/ahls/new_BSP');C=B/'ofs-agx7-pcie-attach';E=B/'qualification/fim-build-14';P=E/'compile-candidate-01';W=B/'work_ia840f_fim_14';S=W/'syn/board/ia840f/syn_top'
OUTPUT='ia840f_fim14_compile03_output'
def require(ok,msg):
    if not ok:raise RuntimeError(msg)
def sha(p):
    p=Path(p);q=p.resolve(strict=True)
    require(q.is_file() and not str(q).startswith(('/dev/','/sys/','/proc/')), 'not ordinary file')
    h=hashlib.sha256()
    with q.open('rb') as f:
        for block in iter(lambda:f.read(1048576),b''):h.update(block)
    return h.hexdigest()
def save(p,data):
    p.parent.mkdir(parents=True,exist_ok=True)
    with p.open('xb') as f:f.write(data)
def savejson(p,obj):save(p,(json.dumps(obj,indent=2,sort_keys=True)+'\n').encode())
require(not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX'),'wrong context')
pane=os.environ['TMUX_PANE'];require(subprocess.check_output(['tmux','display-message','-p','-t',pane,'#S'],text=True).strip()=='ia840f_mailbox_monitored_01','wrong session')
claim=E/'compile-preparation03';claim.mkdir()
r:dict=dict(batch=OUTPUT,pane=pane,pid=os.getpid(),complete=False,native_tools_executed=False,source_modified=False)
try:
    raw=subprocess.check_output(['tmux','save-buffer','-b','ia840f_fim14_compile03_payload','-'])
    require(len(sys.argv)==2 and hashlib.sha256(raw).hexdigest()==sys.argv[1],'payload hash')
    supplied=json.loads(raw)
    require(set(supplied)=={'uart-acceptance.md','uart-spec-review.md','uart-quality-review.md'},'payload scope')
    for name,v in supplied.items():
        data=base64.b64decode(v['base64'],validate=True);require(hashlib.sha256(data).hexdigest()==v['sha256'],'member hash')
        save(P/'source-inputs'/name,data)
    old_record=B/'qualification/fim-build-13/compile-authorization.json'
    require(sha(old_record)=='204cd46e869b7d78ef8978ac01ac88b19cd99f5f7a6e6152de2a1d8fadc51df1','old record changed')
    old=json.loads(old_record.read_text());previous_preparation=json.loads((E/'preparation-result02.json').read_text())
    require(previous_preparation['complete'] is True and previous_preparation['source_unchanged'] is True,'preparation not complete')
    for path in (E/'compile-authorization.json',E/'native-compile.claim.json',E/'run',P/'consumed-reviews.json',P/'authorization-issuance.lock'):
        require(not path.exists() and not path.is_symlink(),'already consumed state '+str(path))
    procs=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
    require(not any(len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-')) for x in procs.splitlines()[1:]),'native task active')
    sys.path.insert(0,str(P/'gate-copy'))
    import ia840f_compile_gate as gate
    before={t:gate.common.inventory(C/t) for t in gate.common.TREES}
    require(before==old['source_sha256'],'SOURCE baseline drift')
    require(gate.common.inventory(gate.common.PIM)==old['pim_sha256'],'PIM drift')
    work=gate.work_inventory();require(work==json.loads((E/'work14-prepared-inventory.json').read_text()),'prepared WORK drift')
    delta=json.loads((P/'source-inputs/delta-report.json').read_text())['source_delta']
    overlays={'src/board/ia840f/afu_top.sv':P/'source-inputs/afu_top.sv',**{'ofs-common/tools/ofss_config/'+name:P/'gate-copy'/name for name in ('ia840f_experimental_gate.py','ia840f_compile_gate.py')}}
    require(set(delta)==set(overlays),'source delta scope')
    # Check every target before any SOURCE write; preserve original bytes first.
    for rel,candidate in overlays.items():
        require(not (C/rel).is_symlink() and sha(C/rel)==delta[rel]['old'],'target drift '+rel)
        require(sha(candidate)==delta[rel]['new'] and sha(W/rel)==delta[rel]['new'],'candidate mismatch '+rel)
        save(claim/'source-backup'/rel,(C/rel).read_bytes())
    for rel,candidate in overlays.items():
        require(sha(C/rel)==delta[rel]['old'],'target changed before integration')
        (C/rel).write_bytes(candidate.read_bytes());r['source_modified']=True
        require(sha(C/rel)==delta[rel]['new'],'integrated readback mismatch')
    after={t:gate.common.inventory(C/t) for t in gate.common.TREES}
    measured={t+'/'+k:{'old':before[t].get(k),'new':after[t].get(k)} for t in before for k in set(before[t])|set(after[t]) if before[t].get(k)!=after[t].get(k)}
    require(measured==delta,'unexpected entire SOURCE delta')
    require(gate.common.inventory(gate.common.PIM)==old['pim_sha256'],'PIM changed')
    savejson(P/'source-inputs/source-after.json',after)
    savejson(P/'source-inputs/integration-receipt.json',dict(delta=measured,source_inventory_verified=True,pim_unchanged=True,work_unchanged=gate.work_inventory()==work,native_tools_executed=False))
    # Clear inherited build options. No shell startup sourcing and no license reads.
    env=dict(os.environ)
    for k in list(env):
        if k.startswith('OFS_BUILD_TAG_') or k in ('SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_PRE_SETUP_SCRIPT','OFS_POST_SETUP_SCRIPT','OFS_PRE_COMPILE_SCRIPT','OFS_POST_COMPILE_SCRIPT','AFU_WITH_PIM','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL','BUILD_ROOT_REL_PRINTED'):env.pop(k,None)
    env.update(OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(gate.common.PIM),KEEP_WORK_ARG='-k',DO_PR_BUILD_TEMPLATE_GEN='1',QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',PYTHONDONTWRITEBYTECODE='1')
    os.environ.clear();os.environ.update(env)
    log=C/'build_fim_work_ia840f_fim_14.log';require(not log.exists(),'unexpected native top log')
    gate_path=C/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'
    tests=[('dispatcher',['python3','-B',str(gate_path),'quartus'],S),('native-top',gate.TOP_ARGS,C),('native-child',[str(gate.CHILD),'ia840f',str(W)],C)]
    tcl=shutil.which('tclsh');require(tcl is not None,'tclsh unavailable for inert helper test')
    tests.append(('tcl-helper',[tcl,str(W/'syn/board/ia840f/setup/build_gate.tcl')],S))
    results=[]
    for name,argv,cwd in tests:
        p=subprocess.run(argv,cwd=cwd,env=env,capture_output=True,text=True,timeout=20)
        item=dict(name=name,argv=argv,cwd=str(cwd),rc=p.returncode,stdout=p.stdout,stderr=p.stderr);results.append(item)
        savejson(claim/(name+'.json'),item)
        require(p.returncode!=0 and 'compile-authorization.json' in p.stdout+p.stderr and ('No such file or directory' in p.stdout+p.stderr),'not expected missing-record rejection '+name)
    require(not log.exists() and not gate.CLAIM.exists() and not (E/'run').exists(),'rejection created native side effects')
    require(gate.work_inventory()==work,'rejection modified WORK')
    require({t:gate.common.inventory(C/t) for t in gate.common.TREES}==after,'rejection modified SOURCE')
    savejson(P/'missing-record-checks.json',dict(results=results,work_unchanged=True,source_unchanged=True,no_native_log_claim_or_run=True))
    draft=copy.deepcopy(old)
    draft.update(approved=False,accepted_execution=False,source_review_consumed=False,gate_review_consumed=False,ready_for_build=False,work=str(W),native_argv=gate.TOP_ARGS,source_sha256=after,work_inventory=work)
    draft['contexts']=[dict(executable='/opt/altera/26.1.1/quartus/linux64/'+args[0],sha256=sha('/opt/altera/26.1.1/quartus/linux64/'+args[0]),argv=args,cwd=str(S)) for args in gate.allowed_commands()]
    # Retain historical source/generation pins and add the actual prepared-input identity.
    draft['dependency_sha256'][str(old_record)]=sha(old_record)
    for p in (E/'preparation-result02.json',E/'work14-prepared-inventory.json',P/'source-inputs/integration-receipt.json',P/'missing-record-checks.json',P/'issue_authorization.py',P/'launch_native_compile.py'):
        draft['dependency_sha256'][str(p)]=sha(p)
    savejson(P/'compile-authorization.draft.json',draft)
    manifest={str(p.relative_to(P)):sha(p) for p in sorted(P.rglob('*')) if p.is_file()}
    savejson(P/'review-package-sha256.json',manifest)
    spec=importlib.util.spec_from_file_location('issuer14',P/'issue_authorization.py');issuer=importlib.util.module_from_spec(spec);spec.loader.exec_module(issuer)
    verified,verified_manifest=issuer.preflight()
    require(verified==draft and verified_manifest==manifest,'issuer preflight mismatch')
    savejson(claim/'preflight.json',dict(status='PASS',nonconsuming=True,package_manifest_sha256=sha(P/'review-package-sha256.json'),files=len(manifest),native_contexts=len(draft['contexts']),authorization_issued=False,native_tools_executed=False))
    r.update(complete=True,source_delta=measured,inert_rejections_passed=len(results),package_manifest_sha256=sha(P/'review-package-sha256.json'),package_files=len(manifest),issuer_preflight='PASS',authorization_issued=False)
except BaseException as error:r.update(error=repr(error),traceback=traceback.format_exc())
finally:
    savejson(claim/'result.json',r)
    exports={}
    for root in (P,claim):
        for p in sorted(root.rglob('*')):
            if p.is_file():
                data=p.read_bytes();require(len(data)<2000000,'export member too large')
                exports[str(p.relative_to(E))]=dict(size=len(data),sha256=hashlib.sha256(data).hexdigest(),base64=base64.b64encode(data).decode())
    packet=json.dumps(dict(batch=OUTPUT,result=r,files=exports),sort_keys=True).encode();blob=gzip.compress(packet,mtime=0)
    subprocess.run(['tmux','load-buffer','-b',OUTPUT,'-'],input=blob,check=True)
    print('COMPILE_PREPARATION',OUTPUT,'JSON_SHA256',hashlib.sha256(packet).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),'COMPLETE',r['complete'],flush=True)
    print(json.dumps(r,indent=2),flush=True)
if not r['complete']:raise SystemExit(1)
