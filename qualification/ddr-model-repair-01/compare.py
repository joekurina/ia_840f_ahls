import pathlib,xml.etree.ElementTree as E,json
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');w=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip/mem_ss');ns={'i':'http://www.accellera.org/XMLSchema/IPXACT/1685-2014','a':'http://www.altera.com/XMLSchema/IPXact2014/extensions'}
for i,n in enumerate(['ed_sim_mem','ed_sim_mem_group1']):
 p=next(p for p in w.rglob('*emif_'+str(i)+'.sopcinfo') if '/sim/' in str(p));m=next(m for m in E.parse(p).findall('.//module') if m.get('kind')=='altera_emif_fm')
 actual={x.get('name'):{'value':x.findtext('value') or '', 'derived':x.findtext('derived')} for x in m.findall('parameter')}
 old={x.findtext('i:name',namespaces=ns):x.findtext('i:value',default='',namespaces=ns) for x in E.parse(r/'before'/(n+'.ip')).findall('.//a:altera_module_parameters/i:parameters/i:parameter',ns)}
 diff={k:{'before':v,'actual':actual[k]} for k,v in old.items() if k in actual and v!=actual[k]['value']}
 (r/(n+'.controller-parameters.json')).write_text(json.dumps({'source':str(p),'parameters':actual,'diff':diff},indent=2))
 print(n,'MODEL_PARAMS',len(old),'ACTUAL',len(actual),'MISSING',set(old)-set(actual),'DIFF',len(diff));print(json.dumps(diff,indent=2))
