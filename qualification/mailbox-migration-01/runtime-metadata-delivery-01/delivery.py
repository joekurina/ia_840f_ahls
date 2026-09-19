"""Local preparation only. No network, tmux invocation or diagnostic execution."""
import base64
import re
import shlex

TRANSPORT_LENGTH = 41045
TRANSPORT_SHA = '29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60'
STREAM_CAP = 3 * 1024 * 1024
RAW_CAP = 32 * 1024 * 1024

class Incomplete(ValueError):
    pass

# Each encoder writes <= 512 bytes in ONE blocking write to the SAME PIPE.
# Use 288-byte chunks so framing fits the POSIX minimum PIPE_BUF of 512.
# Oversized records or an unexpected short write fail the encoder.
ENCODER = '''import os,sys,base64
n=0
while True:
 b=os.read(0,288)
 r=('D1 '+sys.argv[1]+' '+sys.argv[2]+' '+str(n)+' ').encode()+base64.b64encode(b)+b'\\n'
 if len(r)>512 or os.write(1,r)!=len(r): sys.exit(91)
 n+=1
 if not b: break
'''
RELAY = '''import os
while True:
 b=os.read(0,4096)
 if not b: break
 while b:
  n=os.write(3,b)
  if n<=0: raise RuntimeError('short relay')
  b=b[n:]
'''
SAVE = '''import termios,json
s=termios.tcgetattr(3)
print(json.dumps([*s[:6],[x if isinstance(x,int) else x[0] for x in s[6]]],separators=(',',':')))
n=termios.tcgetattr(3)
n[1]&=~termios.OPOST
n[3]&=~termios.ECHO
termios.tcsetattr(3,termios.TCSANOW,n)
'''
RESTORE = '''import termios,json,sys
s=json.loads(sys.argv[1]);s[6]=[bytes([x]) for x in s[6]]
termios.tcsetattr(3,termios.TCSANOW,s)
'''

def py(code):
    # Break shell tokens into short physical lines, not long PTY canonical lines.
    encoded = base64.b64encode(code.encode()).decode()
    expr = "import base64;exec(base64.b64decode("
    # Adjacent quoted shell fragments concatenate to a single -c argument.
    value = expr + repr(encoded) + '))'
    return '/usr/bin/python3 -I -B -S -c ' + '\\\n'.join(shlex.quote(value[i:i+80]) for i in range(0,len(value),80))

def command(payload, token):
    """Generate inert text; caller must never execute non-synthetic locally."""
    if not re.fullmatch('[a-f0-9]{32}',token): raise ValueError('token')
    chunks = [''.join('\\%03o'%b for b in payload[i:i+128]) for i in range(0,len(payload),128)]
    source = 'builtin printf \'%b\' \\\n' + ' \\\n'.join(shlex.quote(c) for c in chunks or [''])
    # No subshell surrounds the diagnostic pipeline. Python is bash's direct child.
    return ('{\n'
        'exec 3>&1\n'
        'd_saved=$('+py(SAVE)+')\n'
        'if [[ $? == 0 ]]; then\n'
        'coproc DRELAY { '+py(RELAY)+'; }\n'
        'd_relay=$!; d_in=${DRELAY[1]}; d_out=${DRELAY[0]}\n'
        'exec 9>&"$d_in"; exec {d_in}>&-; exec {d_out}<&-\n'
        'exec 7> >('+py(ENCODER)+' '+token+' O >&9); d_o=$!\n'
        'exec 8> >('+py(ENCODER)+' '+token+' E >&9); d_e=$!\n'
        +source+' | /usr/bin/python3 -I -B -S - >&7 2>&8 3>&- 7>&- 8>&- 9>&-\n'
        'd_ps=("${PIPESTATUS[@]}")\n'
        'exec 7>&- 8>&-\n'
        'builtin wait "$d_o"; d_os=$?\n'
        'builtin wait "$d_e"; d_es=$?\n'
        "builtin printf 'D1 "+token+" S %s %s %s %s\\n' "
        '"${d_ps[1]}" "$d_os" "$d_es" "${d_ps[0]}" >&9\n'
        'exec 9>&-\n'
        'builtin wait "$d_relay"; d_rs=$?\n'
        +py(RESTORE)+' "$d_saved"; d_ts=$?\n'
        "builtin printf '\\nD1 "+token+" R %s %s\\n' \"$d_rs\" \"$d_ts\"\n"
        'fi\nexec 3>&-\n}\n')

def proposed_command(payload, token):
    import hashlib
    if len(payload)!=TRANSPORT_LENGTH or hashlib.sha256(payload).hexdigest()!=TRANSPORT_SHA:
        raise ValueError('transport binding')
    return command(payload,token)

def unescape(data):
    result=bytearray(); i=0
    while i<len(data):
        b=data[i]
        if b==92:
            octal=data[i+1:i+4]
            if len(octal)!=3 or any(x not in b'01234567' for x in octal): raise Incomplete('control escape')
            n=int(octal,8)
            if n>255: raise Incomplete('control octet')
            result.append(n); i+=4
        else:
            if b<32 or b>=127: raise Incomplete('unescaped control octet')
            result.append(b);i+=1
    return bytes(result)

def reserved_trailing_prefix(fragment, marker):
    """Reserve line-start D1 through this token's marker, not arbitrary prompts.

    D alone is too ambiguous. D1, D1-space, and matching token prefixes
    (including the complete marker) are reserved only after framing starts.
    """
    return len(fragment) >= 2 and (marker.startswith(fragment) or fragment.startswith(marker))


def decode(raw, pane, token):
    """Decode FINISHED capture. Disconnection before R is never accepted."""
    if len(raw)>RAW_CAP or not raw.endswith(b'\n'): raise Incomplete('raw cap/truncated')
    output=bytearray(); pending=None
    prefix=b'%output '+pane.encode()+b' '
    for line in raw.splitlines(keepends=True):
        if not line.endswith(b'\n'): raise Incomplete('truncated protocol')
        line=line[:-1]
        if line.startswith(prefix): output.extend(unescape(line[len(prefix):]))
        elif line.startswith(b'%output'):
            m=re.fullmatch(rb'%output %[0-9]+ (.*)',line)
            if not m: raise Incomplete('malformed output')
            unescape(m[1]) # validate even ignored other-pane data
        elif line.startswith((b'%exit',b'%pause',b'%extended-output',b'%error')) or b'too far behind' in line:
            raise Incomplete('disconnect/lag/error/unsupported mode')
        elif line.startswith((b'%begin ',b'%end ')):
            m=re.fullmatch(rb'%(begin|end) ([0-9]+ [0-9]+ [0-9]+)',line)
            if not m: raise Incomplete('malformed acknowledgement')
            if m[1]==b'begin':
                if pending is not None: raise Incomplete('nested acknowledgement')
                pending=m[2]
            else:
                if pending!=m[2]: raise Incomplete('unmatched acknowledgement')
                pending=None
        elif not re.fullmatch(rb'%(session-changed|sessions-changed|client-session-changed|window-add|window-close|window-renamed|layout-change|paste-buffer-changed|paste-buffer-deleted)( .*)?',line):
            raise Incomplete('unsupported control record')
        # Command acknowledgements and other-pane notifications are NOT status.
    if pending is not None: raise Incomplete('truncated acknowledgement')
    marker=('D1 '+token+' ').encode()
    streams={'O':bytearray(),'E':bytearray()}; seq={'O':0,'E':0}; ended=set(); status=None; restored=False
    if marker in bytes(output).split(b'\n')[-1]: raise Incomplete('truncated frame')
    started=False
    for line in bytes(output).split(b'\n'):
        if not line.startswith(marker):
            if started and marker in line: raise Incomplete('misaligned frame')
            continue # prompts/command echo are raw transcript only
        started=True
        fields=line[len(marker):].split(b' ')
        c=fields[0].decode('ascii',errors='replace')
        if c in streams:
            if status is not None or c in ended or len(fields)!=3 or fields[1]!=str(seq[c]).encode(): raise Incomplete('frame sequence')
            try: b=base64.b64decode(fields[2],validate=True)
            except Exception as exc: raise Incomplete('frame base64') from exc
            if base64.b64encode(b)!=fields[2] or len(b)>384: raise Incomplete('frame canonical/size')
            streams[c].extend(b); seq[c]+=1
            if len(streams[c])>STREAM_CAP: raise Incomplete('stream cap')
            if not b: ended.add(c)
        elif c=='S':
            if status is not None or ended!={'O','E'} or len(fields)!=5: raise Incomplete('status structure')
            if not re.fullmatch(b'[0-9]{1,3}',fields[1]) or int(fields[1])>255 or fields[2:]!=[b'0',b'0',b'0']: raise Incomplete('command/helper failure')
            status=int(fields[1])
        elif c=='R':
            if restored or status is None or b' '.join(fields[1:]).rstrip(b'\r')!=b'0 0': raise Incomplete('restoration/relay')
            restored=True
        else: raise Incomplete('unknown frame')
    if started and reserved_trailing_prefix(bytes(output).split(b'\n')[-1], marker):
        raise Incomplete('truncated reserved frame prefix')
    if status is None or not restored: raise Incomplete('missing status/restoration')
    return dict(stdout=bytes(streams['O']),stderr=bytes(streams['E']),status=status,
                authorization=False,ready_for_build=False,vendor_run=False)
