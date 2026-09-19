import pathlib,xml.etree.ElementTree as E,json,re,hashlib
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');ns={'i':'http://www.accellera.org/XMLSchema/IPXACT/1685-2014','a':'http://www.altera.com/XMLSchema/IPXact2014/extensions'}
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 def par(p):return {x.findtext('i:name',namespaces=ns):x.findtext('i:value',default='',namespaces=ns) for x in E.parse(p).findall('.//a:altera_module_parameters/i:parameters/i:parameter',ns)}
 a=par(r/'before'/(n+'.ip'));b=par(r/(n+'.ip'));u=json.loads((r/(n+'.approved-derived-refresh.json')).read_text());d={k:[a.get(k),b.get(k)] for k in a.keys()|b.keys() if a.get(k)!=b.get(k)}
 print(n,'DIFF',len(d),'UNEXPECTED', {k:v for k,v in d.items() if k not in u},'MISMATCHES',{k:[v,b.get(k)] for k,v in u.items() if b.get(k)!=v})
 for p in (r/n).rglob('*.v'):print('WRAPPER',p);print(p.read_text())
 print((r/n/'sim/common/modelsim_files.tcl').read_text()[:15000])
