from pathlib import Path
import json,hashlib,os,datetime,re,subprocess
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-09'); B=E.parent.parent; C=B/'ofs-agx7-pcie-attach'; W=B/'work_ia840f_fim_09'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
r={'observed_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{}}
for n in ['run/status.json','run/invocation.json','native-compile.claim.json','consumed-reviews.json','issuance.log','runner-console.log']:
 p=E/n
 if p.exists():r['files'][n]={'sha256':sha(p),'text':p.read_text()}
r['authorization_sha256']=sha(E/'compile-authorization.json')
a=json.loads((E/'compile-authorization.json').read_text());r['authorization_flags']={k:a.get(k) for k in ['approved','accepted_execution','ready_for_build','source_review_consumed','gate_review_consumed']}
ov=json.loads((E/'overlay-sha256.json').read_text());r['overlay_readback']={k:{'expected':h,'source':sha(C/k),'work':sha(W/k)} for k,h in ov.items()};r['overlay_matches_after_native_start']=all(x['expected']==x['source']==x['work'] for x in r['overlay_readback'].values())
before=json.loads((E/'source-before.json').read_text());r['changed_overlay_files']=[k for k in ov if before[k]!=ov[k]]
r['qsf_optimization']=[s for s in (C/'syn/board/ia840f/syn_top/ofs_top.qsf').read_text().splitlines() if 'OPTIMIZATION_MODE' in s]
state=json.loads((E/'run/status.json').read_text()) if (E/'run/status.json').exists() else {}
procs={}
for d in Path('/proc').iterdir():
 if not d.name.isdigit():continue
 try:
  stat=(d/'stat').read_text().rsplit(')',1)[1].split();argv=(d/'cmdline').read_bytes().decode(errors='replace').strip('\0').split('\0');procs[int(d.name)]={'pid':int(d.name),'ppid':int(stat[1]),'start_ticks':stat[19],'argv':argv,'exe':os.readlink(d/'exe'),'cwd':os.readlink(d/'cwd')}
 except (OSError,ValueError):pass
owned={state.get('runner_pid'),state.get('native_pid')}-{None}
for _ in range(20):
 new=owned|{p for p,v in procs.items() if v['ppid'] in owned}
 if new==owned:break
 owned=new
r['processes']=[procs[p] for p in sorted(owned) if p in procs]
log=(E/'run/native.log'); text=log.read_text(errors='replace') if log.exists() else ''
r['native_log_bytes']=log.stat().st_size if log.exists() else 0;r['native_log_tail']=text.splitlines()[-70:]
r['diagnostics']=[s for s in text.splitlines() if re.search(r'(?i)\b(?:error|fatal)(?:\s*\([^)]*\))?\s*:|Error \(|Critical Warning \(125091\)|IA840F.*REJECT|GATE.*REJECT',s)]
r['ready_for_build']=False;r['timing_accepted']=False;r['functional_acceptance']=False
out=E/('launch-observation-'+datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'.json')
with out.open('x') as f:json.dump(r,f,indent=2)
print(out.name);print(json.dumps(r,indent=2))
subprocess.run(['tmux','load-buffer','-b',out.stem,str(out)],check=True)
