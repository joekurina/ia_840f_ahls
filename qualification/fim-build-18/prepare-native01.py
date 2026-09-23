#!/usr/bin/env python3
"""Work17 input-copy recipe reused for one exact-register retiming Work18 trial.
Ordinary files only; no vendor invocation or authorization issuance here.
"""
import base64, copy, datetime, gzip, hashlib, importlib.util, json, os, shutil, socket, stat, subprocess, sys, traceback
from pathlib import Path
sys.dont_write_bytecode=True
B=Path('/home/uwb_student00/ahls/new_BSP'); C=B/'ofs-agx7-pcie-attach'; OLD=B/'work_ia840f_fim_17'; W=B/'work_ia840f_fim_18'; E=B/'qualification/fim-build-18'; P=E/'compile-candidate-01'
INPUT='ia840f_fim18_prepare01_inputs'; OUTPUT='ia840f_fim18_prepare01_output'; OWNED=False
RECORD=B/'qualification/fim-build-17/compile-authorization.json'
GATES=('ia840f_compile_gate.py','ia840f_experimental_gate.py')
def require(ok,msg):
    if not ok: raise RuntimeError(msg)
def sha(p):
    p=Path(p).resolve(strict=True)
    require(stat.S_ISREG(p.stat().st_mode) and not str(p).startswith(('/dev/','/sys/','/proc/')),'not ordinary file')
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1048576),b''): h.update(b)
    return h.hexdigest()
def save(p,data):
    p.parent.mkdir(parents=True,exist_ok=True)
    with p.open('xb') as f: f.write(data)
def sj(p,obj): save(p,(json.dumps(obj,indent=2,sort_keys=True)+'\n').encode())
def full_inventory(root):
    out={}
    for p in sorted(root.rglob('*')):
        if p.is_symlink():
            require(p.resolve(strict=True).is_relative_to(root),'symlink escape')
            out[str(p.relative_to(root))]={'link':os.readlink(p)}
        elif p.is_file(): out[str(p.relative_to(root))]={'sha256':sha(p)}
    return out
r=dict(batch=OUTPUT,started=datetime.datetime.now(datetime.timezone.utc).isoformat(),complete=False,native_tools_executed=False,authorization_issued=False,source_modified=False)
try:
    require(not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX'),'wrong execution context')
    pane=os.environ['TMUX_PANE'];r['pane']=pane
    require(subprocess.check_output(['tmux','display-message','-p','-t',pane,'#S'],text=True).strip()=='ia840f_mailbox_monitored_01','wrong session')
    require(not E.exists() and not E.is_symlink() and not W.exists() and not W.is_symlink(),'successor path already exists')
    procs=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
    active=[x for x in procs.splitlines()[1:] if len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-'))]
    require(not active,'competing native process '+repr(active))
    mem={x.split(':')[0]:x.split(':')[1].strip() for x in Path('/proc/meminfo').read_text().splitlines()}
    r['mem_available_bytes']=int(mem['MemAvailable'].split()[0])*1024;r['free_disk_bytes']=shutil.disk_usage(B).free
    require(r['mem_available_bytes']>=80000000000 and r['free_disk_bytes']>=20000000000,'resource headroom')
    raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);require(len(sys.argv)==2 and hashlib.sha256(raw).hexdigest()==sys.argv[1],'payload hash')
    payload=json.loads(raw);expected={'ofs_top.qsf','top.sdc','ITERATION-AUTHORITY.md','iteration-basis.md','issue_authorization.py','launch_native_compile.py','prepare-native01.py'}|{'gate-copy/'+x for x in GATES}
    require(set(payload)==expected,'payload scope')
    blobs={}
    for name,item in payload.items():
        b=base64.b64decode(item['base64'],validate=True);require(len(b)==item['bytes'] and hashlib.sha256(b).hexdigest()==item['sha256'],'payload member mismatch');blobs[name]=b
    require(sha(RECORD)=='22cf3d1428e9a6de430bcad40f477374cf9e25a3a1de22f4b444306c701cbcce','issued Work17 record mismatch')
    old=json.loads(RECORD.read_text())
    sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'));import ia840f_experimental_gate as common
    before={t:common.inventory(C/t) for t in common.TREES};require(before==old['source_sha256'],'SOURCE drift');require(common.inventory(common.PIM)==old['pim_sha256'],'PIM drift')
    for group in ('tools','quartus_tools'):
        for item in old[group].values():require(sha(item['path'])==item['sha256'],'tool changed '+item['path'])
    original_full=full_inventory(OLD)
    actual={k:({'symlink':original_full[k]['link']} if 'link' in original_full[k] else original_full[k]) for k in old['work_inventory']}
    require(not any(set(Path(k).parts)&{'db','qdb','output_files','incremental_db'} for k in actual),'recorded outputs/databases')
    drift={k:{'old':v,'current':actual[k]} for k,v in old['work_inventory'].items() if v!=actual[k]}
    meta={'syn/board/ia840f/syn_top/build_env_db.txt': '9017e6f68b774f7f5280c1d37e44f176286ae8e63b606087bf2a9ca225011501', 'syn/board/ia840f/syn_top/fme_id.mif': '0ae0981eadd0933b476f061b9938eec735dd251f75aa080fad693ab82aa02c54'}
    require(set(drift)==set(meta) and all(drift[k]['current']=={'sha256':v} for k,v in meta.items()),'unexpected Work17 metadata delta')
    E.mkdir();OWNED=True;W.mkdir()
    for name,b in blobs.items():save(P/name,b)
    reloc={}
    for rel,item in actual.items():
        src=OLD/rel;dst=W/rel;dst.parent.mkdir(parents=True,exist_ok=True)
        if 'symlink' in item:
            target=item['symlink'].replace(str(OLD),str(W));os.symlink(target,dst)
            if target!=item['symlink']:reloc[rel]={'kind':'symlink','before':item['symlink'],'after':target}
        else:
            shutil.copy2(src,dst);require(sha(dst)==item['sha256'],'copy mismatch '+rel)
            b=dst.read_bytes()
            if str(OLD).encode() in b:
                b.decode('utf-8');changed=b.replace(str(OLD).encode(),str(W).encode());dst.write_bytes(changed);shutil.copystat(src,dst);reloc[rel]={'kind':'text-root-only','before':item['sha256'],'after':sha(dst)}
    overlays={'ofs-common/tools/ofss_config/'+n:'gate-copy/'+n for n in GATES}
    delta={}
    for rel,name in overlays.items():
        require((C/rel).is_file() and not (C/rel).is_symlink() and (W/rel).is_file() and not (W/rel).is_symlink(),'overlay target')
        delta[rel]={'old':sha(C/rel),'new':hashlib.sha256(blobs[name]).hexdigest()}
        save(E/'source-backup'/rel,(C/rel).read_bytes())
    require(sha(C/'syn/shared_config/top.sdc')==sha(W/'syn/shared_config/top.sdc')==hashlib.sha256(blobs['top.sdc']).hexdigest()=='3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814','SDC must remain unchanged')
    qrel='syn/board/ia840f/syn_top/ofs_top.qsf';qb=(W/qrel).read_bytes()
    require(hashlib.sha256(qb).hexdigest()=='502f55c2eca4441d221851af3dce4431a63f10426a7477b73ec94724e62d3daa','copied QSF baseline')
    require(blobs['ofs_top.qsf']==qb+b'\n# Work18: exact EMIF1 bit243 retiming restriction; original signoff retained.\nset_instance_assignment -name ALLOW_REGISTER_RETIMING OFF -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]}\n','one-setting QSF delta')
    require(hashlib.sha256(blobs['ofs_top.qsf']).hexdigest()=='e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f','QSF candidate')
    (W/qrel).write_bytes(blobs['ofs_top.qsf'])
    require(sha(W/qrel)=='e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f','QSF readback')
    sj(E/'work-qsf-delta.json',{'path':qrel,'old':'502f55c2eca4441d221851af3dce4431a63f10426a7477b73ec94724e62d3daa','new':'e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f','source_qsf_unchanged':True})
    for rel,name in overlays.items():
        require(sha(C/rel)==delta[rel]['old'],'source changed before write')
        (W/rel).write_bytes(blobs[name]);(C/rel).write_bytes(blobs[name]);r['source_modified']=True
        require(sha(C/rel)==sha(W/rel)==delta[rel]['new'],'overlay readback')
    after={t:common.inventory(C/t) for t in common.TREES}
    measured={t+'/'+k:{'old':before[t].get(k),'new':after[t].get(k)} for t in before for k in set(before[t])|set(after[t]) if before[t].get(k)!=after[t].get(k)}
    require(measured==delta,'entire SOURCE delta not exact');require(common.inventory(common.PIM)==old['pim_sha256'],'PIM changed');require(full_inventory(OLD)==original_full,'original Work17 changed')
    import ia840f_compile_gate as gate
    work=gate.work_inventory();require(set(work)==set(actual),'copied input membership changed')
    changed={k for k in work if work[k]!=actual[k]};require(changed==set(reloc)|set(overlays)|{qrel},'copied input delta not exact')
    sj(E/'metadata-delta.json',drift);sj(E/'relocations.json',reloc);sj(P/'source-inputs/delta-report.json',{'source_delta':delta});sj(P/'source-inputs/integration-receipt.json',{'source_delta':measured,'original_work17_unchanged':True,'pim_unchanged':True,'copied_inputs':len(work),'native_tools_executed':False});sj(P/'source-inputs/source-after.json',after)
    env=dict(os.environ)
    for k in list(env):
        if k.startswith('OFS_BUILD_TAG_') or k in ('SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_PRE_SETUP_SCRIPT','OFS_POST_SETUP_SCRIPT','OFS_PRE_COMPILE_SCRIPT','OFS_POST_COMPILE_SCRIPT','AFU_WITH_PIM','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL','BUILD_ROOT_REL_PRINTED','PYTHONOPTIMIZE','PYTHONPATH'):env.pop(k,None)
    env.update(OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(common.PIM),KEEP_WORK_ARG='-k',DO_PR_BUILD_TEMPLATE_GEN='1',QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',PYTHONDONTWRITEBYTECODE='1')
    os.environ.clear();os.environ.update(env)
    draft=copy.deepcopy(old);draft.update(approved=False,accepted_execution=False,source_review_consumed=False,gate_review_consumed=False,ready_for_build=False,work=str(W),source_sha256=after,work_inventory=work,native_argv=gate.TOP_ARGS)
    for path in list(draft['dependency_sha256']):
        if path in {str(C/x) for x in overlays}:draft['dependency_sha256'][path]=sha(path)
    for path in (RECORD,P/'ITERATION-AUTHORITY.md',P/'iteration-basis.md',P/'source-inputs/integration-receipt.json',P/'source-inputs/delta-report.json',P/'issue_authorization.py',P/'launch_native_compile.py',P/'prepare-native01.py',P/'ofs_top.qsf',P/'top.sdc'):draft['dependency_sha256'][str(path)]=sha(path)
    draft['contexts']=[dict(executable='/opt/altera/26.1.1/quartus/linux64/'+args[0],sha256=sha('/opt/altera/26.1.1/quartus/linux64/'+args[0]),argv=args,cwd=str(gate.PROJECT)) for args in gate.allowed_commands()]
    require(len(draft['contexts'])==135,'native context count')
    sj(P/'compile-authorization.draft.json',draft)
    manifest={str(p.relative_to(P)):sha(p) for p in sorted(P.rglob('*')) if p.is_file()};sj(P/'review-package-sha256.json',manifest)
    spec=importlib.util.spec_from_file_location('issuer16',P/'issue_authorization.py');issuer=importlib.util.module_from_spec(spec);spec.loader.exec_module(issuer)
    checked,checked_manifest=issuer.preflight();require(checked==draft and checked_manifest==manifest,'issuer preflight')
    r.update(complete=True,source_delta=delta,copied_inputs=len(work),original_work17_unchanged=True,pim_unchanged=True,native_contexts=135,package_manifest_sha256=sha(P/'review-package-sha256.json'),issuer_nonconsuming_preflight='PASS')
except BaseException as exc:r.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    r['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    if OWNED:sj(E/'preparation-result01.json',r)
    exports={}
    if OWNED:
        for p in sorted(E.rglob('*')):
            if p.is_file():
                b=p.read_bytes();require(len(b)<2000000,'export over cap');exports[str(p.relative_to(E))]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),base64=base64.b64encode(b).decode())
    blob=gzip.compress(json.dumps(dict(batch=OUTPUT,result=r,files=exports),sort_keys=True).encode(),mtime=0)
    subprocess.run(['tmux','load-buffer','-b',OUTPUT,'-'],input=blob,check=True)
    print('WORK18_PREPARATION_COMPLETE',r['complete'],hashlib.sha256(blob).hexdigest(),flush=True);print(json.dumps(r,indent=2),flush=True)
if not r['complete']:sys.exit(1)
