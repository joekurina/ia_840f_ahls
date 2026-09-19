from pathlib import Path
import json,hashlib,re
from decimal import Decimal
P=Path(__file__).parent
Q=P.parent.parent/'fim-build-09/monitor-final-20260919T050111Z/verified'
R=P/'readback/snapshot/work_ia840f_fim_10/syn/board/ia840f/syn_top/output_files'
sha=lambda b:hashlib.sha256(b).hexdigest()
def parse(path):
 data=path.read_bytes(); lines=data.decode().splitlines(); tables={}; active=None
 for i,line in enumerate(lines):
  c=[x.strip() for x in line.split(';')[1:-1]]
  if len(c)==1:
   active=c[0]
   if active in ['Setup Summary','Hold Summary','Clocks','Unconstrained Paths Summary','Clock Status Summary','Unconstrained Input Ports','Unconstrained Output Ports']:
    tables.setdefault(active,[])
  elif active in tables and len(c)>1:
   tables[active].append({'line':i+1,'cells':c})
 timing={}
 for typ in ['Setup','Hold']:
  timing[typ]=[dict(line=r['line'],clock=r['cells'][0],wns=r['cells'][1],tns=r['cells'][2],endpoints=int(r['cells'][3]),corner=r['cells'][4]) for r in tables[typ+' Summary'] if re.fullmatch(r'-?\d+\.\d+',r['cells'][1])]
 warnings=[{'line':i+1,'text':s} for i,s in enumerate(lines) if re.match(r'(?:Critical )?Warning',s) and re.search(r'ignored|not met|unconstrained',s,re.I)]
 # Independently retain complete per-domain/corner data from native summary.
 summary=path.with_suffix('.summary').read_text()
 rows=[{'type':a,'clock':b,'wns':c,'tns':d,'corner':e} for a,b,c,d,e in re.findall(r"Type\s*: (Setup|Hold) '([^']+)'\s+Slack\s*: (\S+)\s+TNS\s*: (\S+)\s+Corner:\s*([^\n]+)",summary)]
 worst={}
 for typ in timing:
  for row in timing[typ]:
   if Decimal(row['wns'])>=0:continue
   key=typ+': '+row['clock']; found=[]
   for i,s in enumerate(lines):
    cells=[x.strip() for x in s.split(';')[1:-1]]
    if len(cells)>=5 and cells[0]==row['wns'] and row['clock'] in cells[3:5] and '|' in cells[1]:
     found.append({'line':i+1,'cells':cells})
   worst[key]=found
 return {'path':str(path),'size':len(data),'sha256':sha(data),'timing':timing,'tables':tables,'all_corner_worst_case_summary_rows':rows,'corners':sorted(set(r['corner'] for r in rows)),'constraint_warnings':warnings,'worst_paths':worst}
a=parse(next(Q.glob('latest/**/ofs_top.sta.rpt'))); b=parse(R/'ofs_top.sta.rpt')
manifest=json.loads((Q/'manifest.json').read_text()); m=manifest[str(Path(a['path']).relative_to(Q))]; assert (a['size'],a['sha256'])==(m['size'],m['sha256'])
v=json.loads((P/'transfer-verification.json').read_text()); m=next(x for x in v['verified_files'] if x['path'].endswith('/ofs_top.sta.rpt')); assert (b['size'],b['sha256'])==(m['size'],m['sha256'])
comparison=[]
for typ in ['Setup','Hold']:
 for rb in b['timing'][typ]:
  ra=next(x for x in a['timing'][typ] if x['clock']==rb['clock'])
  comparison.append({'type':typ,'clock':rb['clock'],'work09':ra,'work10':rb,'wns_delta':str(Decimal(rb['wns'])-Decimal(ra['wns'])),'tns_delta':str(Decimal(rb['tns'])-Decimal(ra['tns'])),'endpoints_delta':rb['endpoints']-ra['endpoints']})
out={'work09':a,'work10':b,'comparison':comparison,'ready_for_build':False,'timing_acceptance':False,'functional_acceptance':False}
(P/'timing-analysis.json').write_text(json.dumps(out,indent=2)+'\n')
(P/'constraint-warnings.txt').write_text('\n'.join(str(x['line'])+': '+x['text'] for x in b['constraint_warnings'])+'\n')
print(json.dumps({'corners':b['corners'],'all_corner_worst_case_row_count':len(b['all_corner_worst_case_summary_rows']),'comparison':[x for x in comparison if Decimal(x['work10']['wns'])<0],'unconstrained':b['tables']['Unconstrained Paths Summary'],'ports':{k:b['tables'][k] for k in ['Unconstrained Input Ports','Unconstrained Output Ports']},'worst_paths':{k:v[:2] for k,v in b['worst_paths'].items()}},indent=2))
