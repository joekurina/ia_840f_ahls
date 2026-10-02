"""Whole-record scoreboard regressions; no native tool execution."""
import copy,hashlib,importlib.util,json,sys
from pathlib import Path
from typing import Any
assert len(sys.argv)==3
source=Path(sys.argv[1]);output=Path(sys.argv[2]);assert not output.exists()
spec=importlib.util.spec_from_file_location('scoreboard_regression_subject',source);assert spec and spec.loader
module: Any=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
score=getattr(module,'scoreboards_exact',module.scoreboards)
expected={'cases':6,'elements':133,'copied_bytes':1600,'dma':30}
MAIN='AHLS_PATH_UNIT_PASS cases=6 elements=133 copied_bytes=1600 dma=30 checks=402470 mmio_reads=1012 mmio_writes=161 bank0_W=40 bank1_W=56'
RESET='BANK1_RESET_INVALIDATION_PASS checks=1'
SPLIT='PAGE_SPLIT_ERROR_PASS native_AW=2 native_W=4 native_B=2 upstream_B=1 observed_split_errors=1'
good={'vsim.log':'# '+RESET+'\n# '+MAIN+'\n','split_fault.log':'# '+SPLIT+'\n','vlog.log':'Errors: 0, Warnings: 2\n'}
cases=[('positive_questa_prefix',copy.deepcopy(good),True),('positive_plain',{k:v.replace('# ','') for k,v in good.items()},True)]
prior=source.parent.parent.parent/'caps03-completion01/sim05-capture'
real={'vsim.log':(prior/'vsim.log').read_text(),'split_fault.log':(prior/'split_fault.log').read_text()}
cases.append(('positive_retained_native_records',real,True))
def change(name,log,old,new):
 d=copy.deepcopy(good);assert old in d[log];d[log]=d[log].replace(old,new);cases.append((name,d,False))
def extra(name,log,line):
 d=copy.deepcopy(good);d[log]+='# '+line+'\n';cases.append((name,d,False))
change('split_numeric_extension','split_fault.log','observed_split_errors=1','observed_split_errors=10')
change('reset_numeric_extension','vsim.log','checks=1\n','checks=10\n')
change('split_text_extension','split_fault.log','observed_split_errors=1','observed_split_errors=1junk')
change('reset_text_extension','vsim.log','checks=1\n','checks=1junk\n')
change('main_numeric_text_extension','vsim.log','bank1_W=56','bank1_W=56junk')
change('main_extra_field','vsim.log','bank1_W=56','bank1_W=56 extra=1')
change('main_unexpected_prefix','vsim.log','# '+MAIN,'prefix '+MAIN)
change('split_extra_field','split_fault.log','observed_split_errors=1','observed_split_errors=1 extra=1')
extra('split_wrong_duplicate','split_fault.log',SPLIT.replace('observed_split_errors=1','observed_split_errors=0'))
extra('split_malformed_duplicate','split_fault.log','PAGE_SPLIT_ERROR_PASS malformed')
extra('reset_wrong_duplicate','vsim.log','BANK1_RESET_INVALIDATION_PASS checks=0')
extra('reset_malformed_duplicate','vsim.log','BANK1_RESET_INVALIDATION_PASS malformed')
extra('main_malformed_duplicate','vsim.log','AHLS_PATH_UNIT_PASS malformed')
extra('main_wrong_duplicate','vsim.log',MAIN.replace('elements=133','elements=132'))
extra('main_duplicate_other_log','vlog.log',MAIN)
extra('reset_duplicate_other_log','vlog.log',RESET)
extra('split_duplicate_other_log','vlog.log',SPLIT)
change('split_embedded_second_family','split_fault.log',SPLIT,SPLIT+' PAGE_SPLIT_ERROR_PASS malformed')
for field,old,new in [('cases','cases=6','cases=5'),('elements','elements=133','elements=132'),('copied_bytes','copied_bytes=1600','copied_bytes=1599'),('dma','dma=30','dma=29'),('checks','checks=402470','checks=0')]:change('wrong_main_'+field,'vsim.log',old,new)
for name,text in [('qualified_error','Error (suppressible): INERT'),('timestamp_error','100 ns DWR ERROR: INERT'),('internal_error','Internal Error: INERT'),('fatal','Fatal: INERT'),('error_summary','Errors: 1')]:extra(name,'vlog.log',text)
for name,log,marker in [('missing_reset','vsim.log','# '+RESET+'\n'),('missing_main','vsim.log','# '+MAIN+'\n'),('missing_split','split_fault.log','# '+SPLIT+'\n')]:change(name,log,marker,'')
rows=[]
for name,logs,want in cases:
 result=score(logs,expected);actual=bool(result['pass']);rows.append({'case':name,'expected_pass':want,'actual_pass':actual,'correct':actual==want,'result':result})
failures=[r['case'] for r in rows if not r['correct']]
record={'scope':'scoreboard parser only; retained native log records are inputs, no simulator invoked','source':str(source),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'function':score.__name__,'count':len(rows),'failures':failures,'success':not failures,'cases':rows}
output.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps({'success':not failures,'count':len(rows),'failures':failures,'output':str(output)}));raise SystemExit(0 if not failures else 1)
