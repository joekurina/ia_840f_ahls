"""Byte-preserving relocation of five observed deployment-XML path roles."""
from pathlib import Path
import re
from xml.parsers import expat

# Observed Work24 deploy XML roles; parameters and message text are excluded.
FILE_ROLES = {
    ('deploy', 'entity', 'sourceFiles', 'file'),
    ('deploy', 'entity', 'childSourceFiles', 'file'),
    ('deploy', 'entity', 'generatedFiles', 'file'),
    ('deploy', 'entity', 'childGeneratedFiles', 'file'),
}
DIRECTORY_ROLE = ('deploy',)
PREFIX = re.compile(r'^/home/uwb_student00/ahls/new_BSP/work_[^/\s"<>]+(/[^"<>\s]*)$')
ATTR = re.compile(rb'''(?<![A-Za-z0-9_:.-])(path|outputDirectory)\s*=\s*(["'])(.*?)\2''', re.S)


def relocate(raw, destination):
    """Return new bytes, explicit edits and unmapped paths; write nothing."""
    destination = Path(destination).resolve(strict=True)
    parser = expat.ParserCreate(namespace_separator='}')
    stack = []
    edits = []
    unmapped = []

    def start(name, attrs):
        stack.append(name.rsplit('}', 1)[-1])
        role = tuple(stack)
        attr = 'path' if role in FILE_ROLES else ('outputDirectory' if role == DIRECTORY_ROLE else None)
        if attr is None or attr not in attrs:
            return
        value = attrs[attr]
        match = PREFIX.fullmatch(value)
        if match is None:
            return
        suffix = match.group(1)
        target = destination/suffix.lstrip('/')
        ok_type = target.is_dir() if attr == 'outputDirectory' else target.is_file()
        if not ok_type or not target.resolve(strict=True).is_relative_to(destination):
            unmapped.append({'role': '/'.join(role)+'/@'+attr, 'before': value,
                             'candidate': str(target), 'reason': 'missing, wrong kind or outside owned copy'})
            return
        begin = parser.CurrentByteIndex
        assert raw[begin:begin+1] == b'<'
        quote = None
        end = begin
        while end < len(raw):
            byte = raw[end]
            if quote is not None:
                if byte == quote:
                    quote = None
            elif byte in (34, 39):
                quote = byte
            elif byte == 62:
                break
            end += 1
        assert end < len(raw), 'unterminated start tag'
        tag = raw[begin:end+1]
        matches = [m for m in ATTR.finditer(tag) if m.group(1).decode() == attr]
        assert len(matches) == 1, ('ambiguous literal path attribute', role, attr)
        item = matches[0]
        assert item.group(3).decode() == value, 'entity-encoded path requires separate explicit handling'
        new_value = str(destination)+suffix
        if new_value == value:
            return
        edits.append({'role': '/'.join(role)+'/@'+attr, 'before': value,
                      'after': new_value, 'start': begin+item.start(3), 'end': begin+item.end(3)})

    def stop(_name):
        stack.pop()

    parser.StartElementHandler = start
    parser.EndElementHandler = stop
    parser.Parse(raw, True)
    assert not stack
    edits.sort(key=lambda e: e['start'])
    assert all(a['end'] <= b['start'] for a, b in zip(edits, edits[1:]))
    output = raw
    for edit in reversed(edits):
        output = output[:edit['start']]+edit['after'].encode()+output[edit['end']:]
    # Parser acceptance is checked separately from byte-level change scope.
    expat.ParserCreate(namespace_separator='}').Parse(output, True)
    return output, edits, unmapped
