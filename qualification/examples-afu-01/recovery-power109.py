"""Authorized recovery only: card PCI quiescence then USB BMC Off/On. No flash/reboot here."""
from pathlib import Path
import datetime, hashlib, json, os, re, socket, subprocess, time, traceback
ROOT = Path('/home/uwb_student00/ahls/new_BSP/work_examples_afu01/recovery109')
PRE = Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/activation-pre43')
BOOT = '3e2d2060-d6c0-44b5-a269-1adf1e450041'
CARD = {'0000:4f:00.0', '0000:4f:00.1', '0000:4f:00.2'}
OWNER_SHA = 'c120062efd638824d05f4495faf7e63634576744e3cc13f26aa0d3a2d12faf8c'
PRE_SHA = '0fe6e7849705d50cb7050ea4cb0ba9d407d3324aeef1b6829108a0a73bb295ff'
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
out = {'scope': 'explicit user-authorized recovery; no flash', 'success': False, 'commands': [], 'boot_before': BOOT, 'authority': 'You have full authority to power-cycle and reboot for recovery.'}
owned = False

def durable(name, data):
    with (ROOT / name).open('x') as f:
        json.dump(data, f, indent=2); f.write('\n'); f.flush(); os.fsync(f.fileno())

def persist():
    (ROOT / 'status.json').write_text(json.dumps(out, indent=2) + '\n')

def run(label, argv, timeout=60):
    row = {'label': label, 'argv': argv, 'started': now()}
    out['commands'].append(row); persist()
    with (ROOT / (label + '.log')).open('xb') as f:
        p = subprocess.Popen(argv, stdout=f, stderr=subprocess.STDOUT, cwd=ROOT, start_new_session=True)
        row['pid'] = p.pid; row['start_ticks'] = Path('/proc/' + str(p.pid) + '/stat').read_text().rsplit(')', 1)[1].split()[19]; persist()
        try:
            row['native_rc'] = p.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            row['execution_state'] = 'UNKNOWN: original child retained; no repeated operation'; persist(); raise
    row['ended'] = now(); persist()
    b = (ROOT / (label + '.log')).read_bytes(); row['log_sha256'] = hashlib.sha256(b).hexdigest(); persist()
    assert row['native_rc'] == 0, row
    return b.decode(errors='replace')

def ownership():
    assert sha(PRE / 'runtime/ownership27.py') == OWNER_SHA
    z = subprocess.run(['sudo', '-n', '/usr/bin/python3', '-I', '-B', str(PRE / 'runtime/ownership27.py')], capture_output=True, timeout=60)
    assert z.returncode == 0, z.stderr
    s = json.loads(z.stdout)
    assert s['boot_id'] == BOOT and not any(s[k] for k in ['holders', 'maps', 'errors', 'relevant_processes']), s
    # Transient unrelated D observations are metadata; they are not card ownership or a hang diagnosis.
    return s

try:
    assert os.getuid() == 1000 and socket.gethostname() == 'Agilex7Workstation' and os.environ.get('TMUX')
    assert Path('/proc/sys/kernel/random/boot_id').read_text().strip() == BOOT
    assert not ROOT.exists()
    assert sha(PRE / 'result.json') == PRE_SHA
    pre = json.loads((PRE / 'result.json').read_text())
    for path, h in pre['source_bindings'].items():
        assert sha(path) == h, path
    first = ownership()
    entries = {r['bdf']: r for r in first['pci']}
    for bdf, vendor, device, driver, group in [
        ('0000:4f:00.0', '0x8086', '0xbcce', 'dfl-pci', '4'),
        ('0000:4f:00.1', '0x12ba', '0x0070', 'vfio-pci', '5'),
        ('0000:4f:00.2', '0x8086', '0xbccf', 'vfio-pci', '76')]:
        r = entries[bdf]
        assert (r['vendor'], r['device'], r['driver'], r['iommu_group'], r['group_members']) == (vendor, device, '/sys/bus/pci/drivers/' + driver, '/sys/kernel/iommu_groups/' + group, [bdf])
        assert r['parent_path'] == '/sys/devices/pci0000:4e/0000:4e:00.0'
    assert entries['0000:4f:00.0']['sriov_numvfs'] == '1'
    assert entries['0000:4f:00.2']['physfn'].endswith('/0000:4f:00.0')
    parent = Path('/sys/bus/pci/devices/0000:4e:00.0'); rp = parent.resolve(strict=True)
    names = lambda: {p.name for p in Path('/sys/bus/pci/devices').iterdir()}
    descendants = lambda: {p.name for p in Path('/sys/bus/pci/devices').iterdir() if rp in p.resolve().parents}
    assert descendants() == CARD
    usb = Path('/sys/bus/usb/devices/1-3.4')
    assert [(usb / n).read_text().strip() for n in ['idVendor', 'idProduct', 'serial']] == ['2528', '0005', '8110055']
    assert first['sdk_service_readonly']['rc'] == 0 and 'ActiveState=inactive' in first['sdk_service_readonly']['stdout']
    ROOT.mkdir(exist_ok=False); owned = True
    out.update(ownership_before=first, source_bindings=pre['source_bindings'], original_PCI=sorted(names()), started=now()); persist()
    env = ['sudo', '-n', '/usr/bin/env', 'PYTHONPATH=/home/uwb_student00/.local/lib/python3.9/site-packages', 'PATH=/home/uwb_student00/.local/bin:/usr/bin:/bin']
    listing = run('USB-target', env + ['/home/uwb_student00/.local/bin/bw_card_list', '-i', 'USB'])
    assert listing.count('IA-840F 8110055') == 1 and re.search(r'Index\s+: 0\b', listing) and 'Location            : 1-3.4' in listing
    before = names()
    aer = run('AER-before', ['sudo', '-n', '/usr/sbin/setpci', '-s', '0000:4e:00.0', 'ECAP_AER+0x04.L', 'ECAP_AER+0x08.L', 'ECAP_AER+0x14.L']).splitlines()
    assert len(aer) == 3 and all(re.fullmatch('[0-9a-f]{8}', x) for x in aer)
    out['original_AER'] = aer; persist()
    run('AER-Surprise-Down-clear', ['sudo', '-n', '/usr/sbin/setpci', '-s', '0000:4e:00.0', 'ECAP_AER+0x04.L=20:20'])
    run('AER-Surprise-Down-mask', ['sudo', '-n', '/usr/sbin/setpci', '-s', '0000:4e:00.0', 'ECAP_AER+0x08.L=20:20'])
    mask = run('AER-mask-readback', ['sudo', '-n', '/usr/sbin/setpci', '-s', '0000:4e:00.0', 'ECAP_AER+0x08.L', 'ECAP_AER+0x14.L']).splitlines()
    assert mask == [f'{int(aer[1], 16) | 0x20:08x}', aer[2]]
    ownership()
    run('remove-PF1', ['sudo', '-n', '/usr/bin/pci_device', '0000:4f:00.1', 'remove'])
    mid = names(); assert before - mid == {'0000:4f:00.1'} and not mid - before and descendants() == {'0000:4f:00.0', '0000:4f:00.2'}
    run('remove-PF0', ['sudo', '-n', '/usr/bin/pci_device', '0000:4f:00.0', 'remove'])
    final = names(); assert before - final == CARD and not final - before and not descendants() and parent.exists()
    out['PCI_after_removal'] = sorted(final); out['ownership_after_removal'] = ownership(); persist()
    bw = env + ['/home/uwb_student00/.local/bin/bw_bmc_configure', '-i', 'USB', '-d', 'USB:0', 'power']
    off = run('power-Off', bw + ['-p', 'Off']); off_read = run('Off-readback', bw)
    assert re.search(r'Power:\s+OFF\b', off) and re.search(r'Power:\s+OFF\b', off_read)
    out['off_confirmed'] = True; durable('Off-confirmed.json', {'at': now(), 'setter': off, 'readback': off_read}); persist()
    time.sleep(12)
    on = run('power-On', bw + ['-p', 'On']); on_read = run('On-readback', bw)
    assert re.search(r'Power:\s+ON\b', on) and re.search(r'Power:\s+ON\b', on_read)
    out['on_confirmed'] = True; durable('On-confirmed.json', {'at': now(), 'setter': on, 'readback': on_read}); persist()
    time.sleep(30)
    assert Path('/proc/sys/kernel/random/boot_id').read_text().strip() == BOOT
    out.update(success=True, ended=now(), quiescence_verified=True, card_cycle_verified=True, electrical_waveforms_measured=False, reboot=False)
except BaseException as exc:
    out.update(error=repr(exc), traceback=traceback.format_exc(), ended=now())
if owned:
    persist(); durable('result.json', out)
print(json.dumps({'success': out['success'], 'error': out.get('error'), 'root': str(ROOT), 'card_cycle_verified': out.get('card_cycle_verified')}), flush=True)
if not out['success']:
    raise SystemExit(1)
