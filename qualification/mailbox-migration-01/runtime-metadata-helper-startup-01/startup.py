"""Inert candidate generator. No execution, remote backend, or authority."""
import base64
from pathlib import Path
import re
import shlex

ROOT = Path(__file__).resolve().parent
SAVE = "import termios,json; s=termios.tcgetattr(3); print(json.dumps([*s[:6],[x if isinstance(x,int) else x[0] for x in s[6]]],separators=(',',':')))"
APPLY = "import termios; s=termios.tcgetattr(3); s[1]&=~termios.OPOST; s[3]&=~termios.ECHO; termios.tcsetattr(3,termios.TCSANOW,s)"
RESTORE = "import termios,json,sys; s=json.loads(sys.argv[1]); s[6]=[bytes([x]) for x in s[6]]; termios.tcsetattr(3,termios.TCSANOW,s); assert termios.tcgetattr(3)==s"


def py(code):
    value = "import base64;exec(base64.b64decode("+repr(base64.b64encode(code.encode()).decode())+"))"
    return '/usr/bin/python3 -I -B -S -c '+ '\\\n'.join(shlex.quote(value[i:i+80]) for i in range(0,len(value),80))


def command(payload, token, faults=None):
    """Return text only. faults are explicit LOCAL synthetic injection seams."""
    if not isinstance(payload, bytes): raise ValueError('payload bytes')
    if not re.fullmatch('[a-f0-9]{32}', token): raise ValueError('token')
    faults = faults or {}
    allowed = {'relay','O','E','cleanup_relay','cleanup_O','cleanup_E','apply','restore'}
    if set(faults)-allowed or any(v not in ('fail','timeout','fd') for v in faults.values()):
        raise ValueError('fault')
    helper = py((ROOT/'helper.py').read_text())
    lines = ['{', 'd_primary=none; d_cleanup=none; d_saved=; d_ts=99',
             'd_rpid=; d_opid=; d_epid=; d_rs=99; d_os=99; d_es=99',
             'd_fd7=0; d_fd8=0; d_fd9=0; d_saved_ok=0; d_dispatched=0',
             'if exec 3>&1; then',
             'if d_saved=$('+py(SAVE)+'); then d_saved_ok=1; else d_primary=save; fi',
             'if [[ $d_primary == none ]]; then',
             'if '+py(APPLY+('; raise RuntimeError("injected apply after mutation")' if faults.get('apply') else ''))+'; then :; else d_primary=apply; fi',
             'fi']
    for role, name, pid, fd in [('relay','HSRELAY','r',9),('O','HSOUT','o',7),('E','HSERR','e',8)]:
        close = ' 4>&- 5>&- 6>&- 7>&- 8>&-'
        if role != 'relay': close += ' 3>&- 9>&-'
        else: close += ' 9>&-'
        args = ' '.join(map(shlex.quote,[role, token, faults.get(role,'none'),faults.get('cleanup_'+role,'none')]))
        lines += ['if [[ $d_primary == none ]]; then',
                  'coproc '+name+' { exec '+helper+' '+args+close+'; }'+(' 2>&9' if role != 'relay' else ''),
                  'd_'+pid+'pid=$!; d_ci=${'+name+'[1]}; d_co=${'+name+'[0]}',
                  # Duplicate before the coproc disappears from bash's variables.
                  'if exec '+str(fd)+'>&"$d_ci"; then d_fd'+str(fd)+'=1; else d_primary='+role+'_descriptor; fi',
                  'if exec 4<&"$d_co"; then',
                  'exec {d_ci}>&-; exec {d_co}<&-',
                  'if IFS= read -r -t 0.4 d_ready <&4 && [[ $d_ready == '+shlex.quote('READY '+role)+' ]]; then :; else if [[ $d_primary == none ]]; then d_primary='+role+'_readiness; fi; fi',
                  'exec 4<&-',
                  'else d_primary='+role+'_control; exec {d_ci}>&-; exec {d_co}<&-; fi',
                  'fi']
    chunks = [''.join('\\%03o'%b for b in payload[i:i+128]) for i in range(0,len(payload),128)]
    source = "builtin printf '%b' \\\n"+' \\\n'.join(shlex.quote(c) for c in chunks or [''])
    lines += ['if [[ $d_primary == none && $d_close_error != 0 ]]; then d_primary=startup_close; fi',
              'if [[ $d_primary == none ]]; then',
              "builtin printf 'HS1 "+token+" DISPATCH\\n' >&3",
              'd_dispatched=1', '# PAYLOAD_BEGIN',
              source+' | /usr/bin/python3 -I -B -S - >&7 2>&8 3>&- 4>&- 5>&- 6>&- 7>&- 8>&- 9>&-',
              'd_ps=("${PIPESTATUS[@]}")', '# PAYLOAD_END', 'fi',
              'if [[ $d_fd7 == 1 ]]; then exec 7>&-; fi',
              'if [[ $d_fd8 == 1 ]]; then exec 8>&-; fi',
              'if [[ -n $d_opid ]]; then if builtin wait "$d_opid"; then d_os=0; else d_os=$?; d_cleanup+=,O:$d_os; fi; fi',
              'if [[ -n $d_epid ]]; then if builtin wait "$d_epid"; then d_es=0; else d_es=$?; d_cleanup+=,E:$d_es; fi; fi',
              'if [[ $d_dispatched == 1 ]]; then',
              "builtin printf 'D1 "+token+" S %s %s %s %s\\n' \"${d_ps[1]}\" \"$d_os\" \"$d_es\" \"${d_ps[0]}\" >&9", 'fi',
              'if [[ $d_fd9 == 1 ]]; then exec 9>&-; fi',
              'if [[ -n $d_rpid ]]; then if builtin wait "$d_rpid"; then d_rs=0; else d_rs=$?; d_cleanup+=,relay:$d_rs; fi; fi',
              'if [[ $d_saved_ok == 1 ]]; then',
              'if '+py('import sys; sys.exit(75)' if faults.get('restore') else RESTORE)+' "$d_saved"; then d_ts=0; else d_ts=$?; d_cleanup+=,restore:$d_ts; fi',
              'fi',
              'exec 3>&-',
              'if [[ $d_dispatched == 1 && $d_close_error == 0 ]]; then',
              "builtin printf '\\nD1 "+token+" R %s %s\\n' \"$d_rs\" \"$d_ts\"", 'fi',
              "builtin printf 'HS1 "+token+" P %s C %s T %s\\n' \"$d_primary\" \"$d_cleanup\" \"$d_ts\"",
              'else builtin printf "HS1 '+token+' P save_descriptor C none T 99\\n"; fi', '}']
    # Every owned close is attempted and retained. Suppress D1 completion on a
    # close failure rather than teaching the approved decoder to ignore it.
    text = '\n'.join(lines)+'\n'
    for fd in ('{d_ci}', '{d_co}', '4', '7', '8', '9', '3'):
        for direction in ('>', '<'):
            old = 'exec '+fd+direction+'&-'
            label = fd.strip('{}')
            replacement = ('if '+old+'; then :; else d_cleanup+=,close_'+label+':$?; d_close_error=1; fi')
            # Only standalone statements; helper/diagnostic redirections are
            # intentionally not rewritten (they do not contain exec here).
            text = text.replace(old, replacement)
    text = text.replace('d_primary=none;', 'd_close_error=0; d_primary=none;', 1)
    return text


def extract_payload(text):
    """Independent literal reconstruction, never execute supplied bytes."""
    segment = text.split('# PAYLOAD_BEGIN\n',1)[1].split(' | /usr/bin/python3',1)[0]
    return bytes(int(n,8) for n in re.findall(r'\\([0-7]{3})',segment))
