from pathlib import Path
import os,json,hashlib,datetime,subprocess,base64,zlib,difflib
N=Path('/home/uwb_student00/ahls/new_BSP');E=N/'qualification/fim-build-11';C=N/'ofs-agx7-pcie-attach';W=N/'work_ia840f_fim_11'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
now=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
processes=[]
for p in Path('/proc').glob('[0-9]*'):
 try:
  exe=os.readlink(p/'exe');argv=[x.decode(errors='replace') for x in (p/'cmdline').read_bytes().split(b'\0') if x];cwd=os.readlink(p/'cwd');stat=(p/'stat').read_text().rsplit(')',1)[1].split()
  if '/quartus/linux64/quartus_' in exe or any(Path(x).name in ['build_top.sh','launch_native_compile.py','build_fim_compile.sh'] for x in argv):processes.append(dict(pid=int(p.name),ppid=int(stat[1]),start_ticks=stat[19],utime=stat[11],stime=stat[12],exe=exe,argv=argv,cwd=cwd,exe_sha256=sha(p/'exe')))
 except OSError:pass
files={}
for name in ['execution-preflight.log','issuance-preflight.json','issuance.log','compile-authorization.json','native-compile.claim.json','consumed-reviews.json','spec-review.md','quality-review.md','run/status.json','run/invocation.json','runner-console.log']:
 p=E/name
 if p.exists():files[name]=p.read_bytes()
log=(E/'run/native.log').read_text(errors='replace') if (E/'run/native.log').exists() else ''
ov=json.loads((E/'overlay-sha256.json').read_text());source={p:sha(C/p) for p in ov};work={p:sha(W/p) for p in ov};q='syn/board/ia840f/syn_top/ofs_top.qsf'
diff=''.join(difflib.unified_diff((C/q).read_text().splitlines(True),(W/q).read_text().splitlines(True),fromfile='reviewed SOURCE',tofile='native WORK'))
obs={'observed_utc':now,'processes':processes,'source_overlay_match':source==ov,'source_hashes':source,'work_hashes':work,'native_log_tail':log[-16000:],'native_log_sha256':sha(E/'run/native.log') if log else None,'ready_for_build':False,'timing_acceptance':False,'functional_acceptance':False}
for name,data in [('launch-observation-'+now+'.json',json.dumps(obs,indent=2).encode()),('native-generated-qsf-'+now+'.diff',diff.encode())]:
 with (E/name).open('xb') as f:f.write(data)
 files[name]=data
payload={p:{'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()} for p,b in files.items()}
out=E/('issued-readback-'+now+'.json.zlib');out.write_bytes(zlib.compress(json.dumps(payload).encode()))
buffer='work11-readback-'+now
subprocess.run(['tmux','load-buffer','-b',buffer,str(out)],check=True)
print('EXPORT',buffer,sha(out),flush=True)
print(json.dumps(obs,indent=2),flush=True)
