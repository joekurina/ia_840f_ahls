#!/usr/bin/env python3
"""Offline contract regression, NOT a UART/FIM fix or hardware test."""
import configparser, struct, unittest
from pathlib import Path
N=Path(__file__).resolve().parents[2]
W=N/'qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13'
D=N/'qualification/source-resume-01/remote/home/uwb_student00/linux-dfl-backport'

def find_param(words,param_id):
    """Bounded model of captured dfl.c find_param and dfh_find_param."""
    pos=0
    while pos<len(words):
        hdr=words[pos]; nxt=hdr>>35
        if (hdr&0xffff)==param_id:
            size=((nxt or 2)-1)*8
            if size!=8 or pos+1>=len(words):raise ValueError('malformed parameter size')
            return words[pos+1]
        if hdr&(1<<32) or not nxt:break
        pos+=nxt
    raise LookupError('missing parameter')

def uart_params(words):
    clk=find_param(words,2);fifo=find_param(words,3);layout=find_param(words,4)
    if fifo not in [32,64,128] or layout>>32 not in [2,4]:raise ValueError('unsupported parameter')
    return clk,fifo,layout>>32,layout&0xffffffff

def enabled_fixture():
    c=configparser.ConfigParser(inline_comment_prefixes=(';',));c.read(W/'ofs-common/src/fpga_family/agilex/uart/rtl/csrs/vuart_csrs.ini')
    def val(section):return int(c[section]['reset_value'],0)
    words=[]
    for prefix,ids,vers,nexts,data in [
        ('vuart_param_header_msix','header_param_id','header_version','header_next',(val('vuart_param_data_msix.num_interrupts')<<32)|val('vuart_param_data_msix.start_vector')),
        ('vuart_param_header_clock','clock_param_id','clock_version','clock_next',val('vuart_param_data_clock.input_clock')),
        ('uart_param_header_fifo','header_fifo_param_id','header_fifo_version','header_fifo_next',val('vuart_param_data_fifo.fifo_len')),
        ('param_header_layout','header_layout_param_id','header_layout_version','header_layout_next',(val('param_data_fifo.reg_io_width')<<32)|val('param_data_fifo.reg_shift'))]:
        words.extend([(val(prefix+'.'+nexts)<<32)|(val(prefix+'.'+vers)<<16)|val(prefix+'.'+ids),data])
    return words

class Contract(unittest.TestCase):
    def test_w13_uart_is_disabled(self):
        macros=(W/'syn/board/ia840f/syn_top/fim_project_macros.tcl').read_text()
        self.assertNotIn('"INCLUDE_UART"',macros)
        self.assertNotIn('"INCLUDE_HPS"',macros)
    def test_dummy_still_advertises_uart(self):
        text=(W/'src/board/ia840f/afu_top.sv').read_text()
        block=text.split('// vUART interface')[1].split('`endif')[0]
        self.assertIn(".FEAT_ID          (12'h24)",block.split('`else')[1])
        self.assertIn('uart_dummy_csr',block)
        dummy=(W/'src/afu_top/dummy_csr.sv').read_text()
        self.assertIn("{FEAT_TYPE, 8'h0, 4'h0, 7'h0, END_OF_LIST, NEXT_DFH_OFFSET, FEAT_VER, FEAT_ID}",dummy)
    def test_captured_driver_requires_clock(self):
        text=(D/'drivers/tty/serial/8250/8250_dfl.c').read_text()
        self.assertIn('DFHv1_PARAM_ID_CLK_FRQ    0x2',text)
        self.assertIn('psize != sizeof(*pval)',text)
        self.assertIn('missing CLK_FRQ param',text)
    def test_old_dummy_fails_missing_clock(self):
        # DFHv0 yields no generic parameter vector in the DFL core.
        with self.assertRaises(LookupError):uart_params([])
    def test_enabled_source_metadata_contract_only(self):
        self.assertEqual(uart_params(enabled_fixture()),(50_000_000,128,4,2))
    def test_missing_clock(self):
        x=enabled_fixture();x[2]=(x[2]&~0xffff)|7
        with self.assertRaises(LookupError):uart_params(x)
    def test_short_clock_payload(self):
        with self.assertRaises(ValueError):uart_params([(2<<35)|2])
    def test_oversized_clock_payload(self):
        with self.assertRaises(ValueError):uart_params([(3<<35)|2,50_000_000,0])
    def test_early_end_of_parameters(self):
        x=enabled_fixture();x[0]|=1<<32
        with self.assertRaises(LookupError):uart_params(x)
    def test_neighbor_parameter_integrity(self):
        x=enabled_fixture();before=struct.pack('<8Q',*x)
        self.assertEqual(find_param(x,1),(1<<32)|5)
        uart_params(x);self.assertEqual(before,struct.pack('<8Q',*x))
    def test_invalid_fifo(self):
        x=enabled_fixture();x[5]=1
        with self.assertRaises(ValueError):uart_params(x)
    def test_invalid_register_width(self):
        x=enabled_fixture();x[7]=(8<<32)|2
        with self.assertRaises(ValueError):uart_params(x)
if __name__=='__main__':unittest.main(verbosity=2)
