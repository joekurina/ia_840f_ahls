"""Read-only remote export; all operational code runs in owned tmux window."""
import base64, hashlib, json, pathlib, shlex, subprocess, zlib
P = pathlib.Path(__file__).resolve().parent
S = P.parent / 'msa-next-supported-step-02'
HOST = 'uwb_student00@100.101.227.97'
SESSION = 'ia840f_mailbox_monitored_01'
BUFFER = 'msa-fix01-baseline-20260919-c'
roots = {'modern': '/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach',
         'vendor': '/home/uwb_student00/IA-840f/IOFS_BUILD_ROOT/ofs-ia840f',
         'evidence': '/home/uwb_student00/ahls/new_BSP/reference'}
files = {}
for label, digest in json.loads((S/'captured/05-preset_derivation.json').read_text())['inputs_sha256'].items():
    kind, rel = label.split('/',1)
    if kind == 'evidence':
        data = (P.parents[1]/'reference'/rel).read_bytes()
        assert hashlib.sha256(data).hexdigest() == digest
        target = P/'baseline'/label
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        continue
    files[label] = {'source': roots[kind]+'/'+rel, 'sha256': digest}
for e in json.loads((S/'source-manifest.json').read_text()):
    files['review/'+e['capture']] = {'source': e['source'], 'sha256': e['sha256']}
remote = '''import os,socket,pathlib,json,hashlib,base64,zlib,subprocess
assert socket.gethostname() == 'Agilex7Workstation'
assert os.getuid() == 1000
files = FILES
for label,e in files.items():
 d=pathlib.Path(e['source']).read_bytes()
 assert hashlib.sha256(d).hexdigest()==e['sha256'], (label,e['source'])
 e['bytes']=len(d); e['data']=base64.b64encode(d).decode()
payload=json.dumps({'batch':BUFFER,'hostname':socket.gethostname(),'uid':os.getuid(),'files':files},sort_keys=True).encode()
subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=zlib.compress(payload),check=True)
'''.replace('FILES',repr(files)).replace('BUFFER',repr(BUFFER))
(P/'remote-reader.py').write_text(remote)
command = 'python3 -c ' + shlex.quote(remote) + '; sleep 120'
args = ['ssh',HOST,'tmux new-window -d -P -F '+shlex.quote('#{pane_id}')+' -t '+SESSION+' -n msa-fix01-read '+shlex.quote(command)]
result=subprocess.run(args,capture_output=True,text=True,check=True)
(P/'transport.json').write_text(json.dumps({'argv':args,'stdout':result.stdout,'stderr':result.stderr,'buffer':BUFFER},indent=2)+'\n')
print(result.stdout)
