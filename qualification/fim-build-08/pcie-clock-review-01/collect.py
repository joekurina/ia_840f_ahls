import subprocess, shlex, json, hashlib, pathlib, time
OUT=pathlib.Path(__file__).parent
HOST='uwb_student00@100.101.227.97'
def run(code, name):
    payload='import pathlib,json,hashlib,subprocess,os,socket\nfiles={}\ndef save(p):\n p=pathlib.Path(p); b=p.read_bytes(); files[str(p)]={"sha256":hashlib.sha256(b).hexdigest(),"text":b.decode(errors="replace")}\n'+code+'\ndata=json.dumps(files).encode(); subprocess.run(["tmux","load-buffer","-b","pcie_review_payload","-"],input=data,check=True);print("PCIE_PAYLOAD_DONE")\n'
    payload=payload.replace('pcie_review_payload', 'pcie_review_'+name)
    cmd='python3 -c '+shlex.quote(payload)
    subprocess.run(['ssh',HOST,'tmux send-keys -t %345 -l '+shlex.quote(cmd)],check=True)
    subprocess.run(['ssh',HOST,'tmux send-keys -t %345 Enter'],check=True)
    time.sleep(3)
    r=subprocess.run(['ssh',HOST,'tmux save-buffer -b '+shlex.quote('pcie_review_'+name)+' -'],capture_output=True,check=True)
    d=json.loads(r.stdout)
    for p,v in d.items():
        if 'text' in v: assert hashlib.sha256(v['text'].encode()).hexdigest()==v['sha256'],p
    (OUT/name).write_bytes(r.stdout)
    return d
if __name__=='__main__':
 d=run('w=pathlib.Path("/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08")\ns=w/"ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth"\nsave(s/"pcie_ss.sdc")\nsave(s/"hip_if_adaptor/pciess_clock_divider.sv")\nfor p in s.glob("hip_if_adaptor/*.sv"):\n t=p.read_text(errors="replace")\n if "u_pciess_clock_divider" in t:save(p)\nfiles["inventory"]={"paths":[str(p) for p in s.glob("*.sv")]}\n','sources-01.json')
 for p,v in d.items():
  print(p,v.get('sha256',''))
  if 'clock_divider.sv' in p: print(v['text'])
  elif 'text' in v:
   ls=v['text'].splitlines(); indexes=set()
   for i,l in enumerate(ls):
    if (p.endswith('.sdc') and i<220) or 'u_pciess_clock_divider' in l:
     indexes.update(range(max(0,i-10),min(len(ls),i+25)))
   for i in sorted(indexes): print(f'{i+1}:{ls[i]}')
  else: print(v)
