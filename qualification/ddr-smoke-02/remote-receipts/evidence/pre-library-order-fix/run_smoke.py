#!/usr/bin/env python3
"""Bounded Work04 DDR smoke. Default inert; --execute requires reviewed record.
Run ONLY inside ia840f_mailbox_monitored_01 on the authorized workstation.
"""
import argparse,hashlib,json,os,pathlib,re,shutil,signal,subprocess,sys,time
P=pathlib.Path(__file__).resolve().parent
TOOLS=pathlib.Path('/opt/altera/26.1.1/questa_fe/bin')
LICENSE='/home/uwb_student00/quartus_26/LR-191011_License.dat'
PASS='DDR_SMOKE_PASS channels=2 writes=4 reads=4 bits_checked=2048'
ERROR=re.compile(r'\b(?:error|fatal)\s*:|DDR_SMOKE_FAIL|Error loading design|License checkout failed',re.IGNORECASE)
def digest(p): return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def check_inputs(m):
    return [x['path'] for x in m['inputs']+m['hex_files'] if not pathlib.Path(x['path']).is_file() or digest(x['path'])!=x['sha256']]
def accepted(rc,text):
    lines=[re.sub(r'^#\s*','',l.strip()) for l in text.splitlines()]
    return rc==0 and not ERROR.search(text) and lines.count(PASS)==1 and all(lines.count('DDR_SMOKE_CHANNEL_DONE channel=%d writes=2 reads=2'%c)==1 for c in range(2))
def ini_text(m):
    return '[Library]\nothers = /opt/altera/26.1.1/questa_fe/modelsim.ini\n'+''.join(k+' = '+v+'\n' for k,v in m['device_libraries'].items())+''.join(k+' = libraries/'+k+'\n' for k in ['work']+m['design_libraries'])+'\n[vsim]\nVoptFlow = 1\n'
def run_child(argv,cwd,env,log,timeout):
    with log.open('x') as f:
        child=subprocess.Popen(argv,cwd=cwd,env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
        try: return child.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            os.killpg(child.pid,signal.SIGTERM)
            try: child.wait(timeout=3)
            except subprocess.TimeoutExpired: os.killpg(child.pid,signal.SIGKILL);child.wait()
            return 124

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--execute',action='store_true');ap.add_argument('--review-record',type=pathlib.Path);ap.add_argument('--output',type=pathlib.Path)
    args=ap.parse_args();m=json.loads((P/'manifest.json').read_text())
    assert m['ready_for_build'] is False
    if not args.execute:
        print(json.dumps({'mode':'inert','ready_for_build':False,'hdl_executed':False,'ordered_ip_commands':len(m['commands']),'hex_files':len(m['hex_files']),'design_libraries':len(m['design_libraries']),'elaboration_and_run_timeout_s':120,'compile_total_timeout_s':600,'review_required':True},indent=2));return 0
    # Reject BEFORE output creation, input access, or any vendor subprocess.
    if not args.review_record or not args.output: raise RuntimeError('review record and fresh output required')
    review=json.loads(args.review_record.read_text())
    if review.get('review_accepted') is not True or review.get('reset_sequence_source_accepted') is not True or review.get('ready_for_build') is not False: raise RuntimeError('unaccepted review/reset sequence')
    for name in ['tb_mem_ss_smoke.sv','run_smoke.py','manifest.json']:
        if review.get('sha256',{}).get(name)!=digest(P/name): raise RuntimeError('review hash mismatch '+name)
    if not os.environ.get('TMUX'): raise RuntimeError('required monitored tmux session absent')
    session=subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()
    if session!='ia840f_mailbox_monitored_01': raise RuntimeError('wrong tmux session')
    out=args.output.resolve();root=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02')
    if root not in out.parents: raise RuntimeError('output must be fresh child of owned remote smoke02 scratch')
    out.mkdir(parents=False,exist_ok=False)
    result={'ready_for_build':False,'pass':False,'hdl_executed':False,'started':time.time(),'steps':[]}
    rc=1
    def step(argv,name,limit):
        nonlocal rc
        log=out/(name+'.log');result['steps'].append({'argv':argv,'timeout_s':limit,'log':log.name})
        rc=run_child(argv,out,env,log,limit);result['steps'][-1]['rc']=rc
        if rc or ERROR.search(log.read_text(errors='replace')): raise RuntimeError('failed '+name+' rc='+str(rc))
    try:
        changed=check_inputs(m)
        if changed: raise RuntimeError('input mismatch '+str(changed))
        result['before_hashes_match']=True
        if not pathlib.Path(LICENSE).is_file(): raise RuntimeError('license file absent')
        for v in m['device_libraries'].values():
            if not pathlib.Path(v).is_dir(): raise RuntimeError('missing precompiled library '+v)
        result['tool_hashes']={t:digest(TOOLS/t) for t in ['vlib','vlog','vsim']}
        result['package_hashes']={n:digest(P/n) for n in ['tb_mem_ss_smoke.sv','manifest.json','run_smoke.py']}
        (out/'modelsim.ini').write_text(ini_text(m));(out/'libraries').mkdir()
        env=os.environ.copy();env.update({'MODELSIM':str(out/'modelsim.ini'),'SALT_LICENSE_SERVER':LICENSE,'LM_LICENSE_FILE':LICENSE,'MGLS_LICENSE_FILE':LICENSE,'PATH':str(TOOLS)+':'+os.environ.get('PATH','')})
        for x in m['hex_files']:
            dst=out/pathlib.Path(x['path']).name;shutil.copyfile(x['path'],dst)
            if digest(dst)!=x['sha256']: raise RuntimeError('HEX copy mismatch')
        step([str(TOOLS/'vlog'),'-version'],'vlog-version',15)
        step([str(TOOLS/'vsim'),'-version'],'vsim-version',15)
        for i,lib in enumerate(['work']+m['design_libraries']):step([str(TOOLS/'vlib'),'libraries/'+lib],'vlib-%02d'%i,15)
        deadline=time.monotonic()+600
        # Generated dev_com always includes simsf_dpi.cpp even with empty IP DPI list.
        commands=[['vlog','-sv','-work','work',m['dpi_source']]]+m['commands']+[['vlog','-sv','-work','work',str(P/'tb_mem_ss_smoke.sv')]]
        for i,cmd in enumerate(commands):
            remaining=deadline-time.monotonic()
            if remaining<=0:rc=124;raise RuntimeError('compile total timeout')
            result['hdl_executed']=True
            step([str(TOOLS/cmd[0])]+cmd[1:],'compile-%03d'%i,min(120,remaining))
        (out/'run.do').write_text('onerror {quit -force -code 1}\nonbreak {quit -force -code 1}\nrun -all\nquit -force -code 2\n')
        args_vsim=[str(TOOLS/'vsim'),'-c','-onfinish','exit','-t','1ps']
        for lib in ['work']+list(m['device_libraries'])+m['design_libraries']:args_vsim+=['-L',lib]
        args_vsim+=['work.tb_mem_ss_smoke','-do','run.do']
        step(args_vsim,'elaborate-run',120)
        result['pass']=accepted(rc,(out/'elaborate-run.log').read_text(errors='replace'))
        if not result['pass']:raise RuntimeError('missing exact two-channel scoreboard completion')
        rc=0
    except Exception as e:
        result['error']=str(e);rc=124 if rc==124 else 1
    finally:
        try:
            changed=check_inputs(m);result['after_input_mismatches']=changed
            if changed:result['pass']=False;rc=1
        except Exception as e:result['after_check_error']=str(e);result['pass']=False;rc=1
        result.update({'finished':time.time(),'exit_code':rc})
        (out/'result.json').write_text(json.dumps(result,indent=2)+'\n')
        (out/'output-hashes.json').write_text(json.dumps({str(x.relative_to(out)):digest(x) for x in out.iterdir() if x.is_file()},indent=2)+'\n')
    return rc
if __name__=='__main__':
    try:sys.exit(main())
    except Exception as e:print('DDR smoke rejected: '+str(e),file=sys.stderr);sys.exit(2)
