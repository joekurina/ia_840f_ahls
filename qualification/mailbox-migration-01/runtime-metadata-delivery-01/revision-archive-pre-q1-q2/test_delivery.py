"""Synthetic only: never import or run sibling diagnostic code."""
import base64
import hashlib
import unittest
import delivery

TOKEN = 'a' * 32

def frame(channel, seq, data):
    return ('D1 ' + TOKEN + ' ' + channel + ' ' + str(seq) + ' ' + base64.b64encode(data).decode() + '\n').encode()

def transcript(data):
    # tmux control escaping, including backslash, CR, NUL, high bytes.
    esc = b''.join(('\\%03o' % b).encode() if b < 32 or b >= 127 or b == 92 else bytes([b]) for b in data)
    return b'%output %0 ' + esc + b'\n'

class DeliveryTests(unittest.TestCase):
    def good(self, out=b'a\x00\r\n\\\xff', err=b'err\n\x00'):
        data = frame('O', 0, out) + frame('O', 1, b'') + frame('E', 0, err) + frame('E', 1, b'')
        data += ('D1 ' + TOKEN + ' S 23 0 0 0\nD1 '+TOKEN+' R 0 0\r\n').encode()
        return transcript(data)

    def test_exact_separate_nonzero_status(self):
        r = delivery.decode(self.good(), '%0', TOKEN)
        self.assertEqual(r['stdout'], b'a\x00\r\n\\\xff')
        self.assertEqual(r['stderr'], b'err\n\x00')
        self.assertEqual(r['status'], 23)

    def test_large_encoded_channel(self):
        out = bytes(range(256)) * 12288
        records = b''.join(frame('O', i, out[j:j+384]) for i,j in enumerate(range(0,len(out),384)))
        records += frame('O', len(out)//384, b'') + frame('E',0,b'')
        records += ('D1 '+TOKEN+' S 0 0 0 0\nD1 '+TOKEN+' R 0 0\r\n').encode()
        raw = transcript(records)
        self.assertGreater(len(raw), 3*1024*1024)
        self.assertEqual(delivery.decode(raw,'%0',TOKEN)['stdout'], out)

    def test_bad_transcripts(self):
        good = self.good()
        for bad in [good[:-1], good.replace(b' S 23 0 0', b' S x 0 0'),
                    good.replace(b' S 23 0 0',b' S 23 1 0'),
                    good.replace(b' O 0 ',b' O 2 '), good+b'%exit lost\n',
                    good+b'%pause %0\n', good+b'%error 1 1 1\n',
                    b'%output %0 \\999\n', b'%output %0 \\01\n',
                    transcript(frame('O',0,b'x')), b'%end 1 1 1\n',
                    good.replace(b'\\012',b'\\015\\012',1)]:
            with self.subTest(bad=bad[-80:]):
                with self.assertRaises(delivery.Incomplete): delivery.decode(bad,'%0',TOKEN)

    def test_synthetic_command_short_lines(self):
        payload = b'# synthetic\n' + b'#'+ b'x'*41045 + b'\n'
        cmd = delivery.command(payload,TOKEN)
        self.assertLess(max(map(len,cmd.splitlines())), 1024)
        self.assertNotIn('exec /usr/bin/python3',cmd)
        self.assertIn('/usr/bin/python3 -I -B -S -',cmd)

    def test_prompt_echo_is_not_a_frame(self):
        echo = transcript(("> builtin printf 'D1 "+TOKEN+" S %s 0 0 0\\n'\r\n").encode())
        self.assertEqual(delivery.decode(echo+self.good(),'%0',TOKEN)['status'],23)

    def test_split_control_output_and_control_escapes(self):
        raw=self.good()
        pane_bytes=delivery.unescape(raw[len(b'%output %0 '):-1])
        fragmented=b''.join(transcript(bytes([b])) for b in pane_bytes)
        self.assertEqual(delivery.decode(fragmented,'%0',TOKEN)['stdout'],b'a\x00\r\n\\\xff')
        for b in range(256):
            self.assertEqual(delivery.unescape(('\\%03o'%b).encode()),bytes([b]))

    def test_caps_disconnect_and_truncation(self):
        from unittest.mock import patch
        with patch.object(delivery,'RAW_CAP',len(self.good())-1):
            with self.assertRaises(delivery.Incomplete): delivery.decode(self.good(),'%0',TOKEN)
        with patch.object(delivery,'STREAM_CAP',1):
            with self.assertRaises(delivery.Incomplete): delivery.decode(self.good(),'%0',TOKEN)
        for suffix in (b'%exit\n',b'%exit too far behind\n',b'%pause %0\n',
                       b'%begin 1 2 0\n',b'%end 1 2 0\n',b'%output malformed\n',b'garbage\n'):
            with self.assertRaises(delivery.Incomplete): delivery.decode(self.good()+suffix,'%0',TOKEN)
        for cut in range(1,70):
            with self.assertRaises(delivery.Incomplete): delivery.decode(self.good()[:-cut],'%0',TOKEN)

    def test_binding_refusal(self):
        with self.assertRaises(ValueError): delivery.proposed_command(b'synthetic',TOKEN)

if __name__ == '__main__': unittest.main()
