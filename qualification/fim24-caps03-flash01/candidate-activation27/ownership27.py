"""Root-readable ordinary OS evidence only; no device open, ioctl or MMIO."""
import datetime,json,os,re,socket,subprocess
from pathlib import Path
import hashlib,importlib.util
_guard_path=Path(__file__).parent/'activation_guards27.py'
assert hashlib.sha256(_guard_path.read_bytes()).hexdigest()=='4e63968f5cae892daf07e00399b475e085baf69ad0cdac00c79de7b60b12c44b'
_guard_spec=importlib.util.spec_from_file_location('retained_activation_owner_scope',_guard_path)
assert _guard_spec is not None and _guard_spec.loader is not None
_guard=importlib.util.module_from_spec(_guard_spec);_guard_spec.loader.exec_module(_guard)
_original_scope={'root':_guard.ROOT,'bdfs':sorted(_guard.CARD),'groups':sorted(_guard.GROUPS)}
assert os.getuid()==0 and socket.gethostname()=='Agilex7Workstation'
out={'scope':'ordinary cached PCI/sysfs identities and root-visible process/fd/maps only; no hardware API','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'boot_id':Path('/proc/sys/kernel/random/boot_id').read_text().strip(),'kernel':os.uname().release,'pci':[],'relevant_processes':[],'d_state':[],'holders':[],'maps':[],'errors':[]}
for p in Path('/sys/bus/pci/devices').iterdir():
    try:
        vendor=(p/'vendor').read_text().strip();device=(p/'device').read_text().strip()
        if (vendor,device) not in [('0x12ba','0x0070'),('0x8086','0xbcce'),('0x8086','0xbccf')]:continue
        row={'bdf':p.name,'vendor':vendor,'device':device,'driver':str((p/'driver').resolve()) if (p/'driver').exists() else None,'iommu_group':str((p/'iommu_group').resolve()) if (p/'iommu_group').exists() else None,'parent_path':str(p.resolve().parent)}
        if (p/'sriov_numvfs').is_file():row['sriov_numvfs']=(p/'sriov_numvfs').read_text().strip()
        if (p/'physfn').exists():row['physfn']=str((p/'physfn').resolve())
        if (p/'iommu_group/devices').is_dir():row['group_members']=sorted(n.name for n in (p/'iommu_group/devices').iterdir())
        row['virtfn_links']={n.name:str(n.resolve()) for n in p.glob('virtfn*') if n.is_symlink()}
        out['pci'].append(row)
    except OSError as exc:out['errors'].append({'pci':p.name,'error':repr(exc)})
out['retained_original_owner_scope']=_guard.retained_owner_scope(_original_scope)
for p in Path('/proc').iterdir():
    if not p.name.isdigit():continue
    try:
        fields=(p/'stat').read_text().rsplit(')',1)[1].split();argv=(p/'cmdline').read_bytes()[:65536].decode(errors='replace').rstrip('\0').split('\0');name=(p/'comm').read_text().strip()
        identity={'pid':int(p.name),'start_ticks':fields[19],'state':fields[0],'comm':name}
        if fields[0]=='D':out['d_state'].append(identity)
        relevant=any(any(token in Path(arg).name for token in ['bw_agilex_flash_programmer','bw_card_list','bw_card_monitor','bwvfiod','quartus_pgm','jtagconfig','opae','fpga_test','ia840f_']) for arg in argv[:3])
        if relevant:
            row=dict(identity);row['argv']=argv
            try:row['exe']=os.readlink(p/'exe');row['cwd']=os.readlink(p/'cwd')
            except OSError:pass
            out['relevant_processes'].append(row)
        for fd in (p/'fd').iterdir():
            try:target=os.readlink(fd)
            except FileNotFoundError:continue
            if _guard.card_target(target,_original_scope):out['holders'].append({**identity,'fd':fd.name,'target':target})
        for line in (p/'maps').read_text().splitlines():
            if _guard.card_mapping(line,_original_scope):out['maps'].append({**identity,'mapping':line})
        assert len(out['holders'])<=1000 and len(out['maps'])<=1000 and len(out['relevant_processes'])<=1000
    except (FileNotFoundError,ProcessLookupError):continue
    except OSError as exc:out['errors'].append({'pid':p.name,'error':repr(exc)})
z=subprocess.run(['/usr/bin/systemctl','show','bittware-vfiod','-p','ActiveState','-p','SubState','-p','MainPID','-p','ExecMainStatus','-p','ControlGroup'],capture_output=True,text=True,timeout=15)
out['sdk_service_readonly']={'rc':z.returncode,'stdout':z.stdout,'stderr':z.stderr}
print(json.dumps(out,sort_keys=True))
