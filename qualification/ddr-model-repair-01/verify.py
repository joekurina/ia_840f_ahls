import pathlib,json,hashlib,xml.etree.ElementTree as E,re,subprocess,shlex
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');ns={'i':'http://www.accellera.org/XMLSchema/IPXACT/1685-2014','a':'http://www.altera.com/XMLSchema/IPXact2014/extensions'}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def params(p):return {x.findtext('i:name',namespaces=ns):x.findtext('i:value',default='',namespaces=ns) for x in E.parse(p).findall('.//a:altera_module_parameters/i:parameters/i:parameter',ns)}
result={'ready_for_build':False,'simulation_run':False,'models':{}};closure={}
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 a=params(r/'before'/(n+'.ip'));b=params(r/(n+'.ip'));u=json.loads((r/(n+'.approved-derived-refresh.json')).read_text());diff={k:{'before':a.get(k),'after':b.get(k)} for k in a.keys()|b.keys() if a.get(k)!=b.get(k)}
 assert set(diff)==set(u)
 assert all(b[k]==v for k,v in u.items()),{k:[v,b.get(k)] for k,v in u.items() if b.get(k)!=v}
 d=json.loads((r/(n+'.controller-parameters.json')).read_text());assert all(b[k]==d['parameters'][k]['value'] for k in u)
 preserved=['MEM_DDR4_ROW_ADDR_WIDTH','MEM_DDR4_COL_ADDR_WIDTH','MEM_DDR4_BANK_ADDR_WIDTH','MEM_DDR4_BANK_GROUP_WIDTH','MEM_DDR4_DQ_WIDTH','MEM_DDR4_FORMAT_ENUM','MEM_FORMAT_ENUM','CTRL_DDR4_ECC_EN','CTRL_ECC_EN','DIAG_FAST_SIM','DIAG_USE_ABSTRACT_PHY','DIAG_DDR4_SIM_CAL_MODE_ENUM','PHY_DDR4_CALIBRATION_MODE_ENUM','PHY_DDR4_LOCATION']
 preserved=[k for k in preserved if k in a];assert all(a[k]==b[k] for k in preserved)
 top=r/n/'sim'/(n+'.v');leaf=next((r/n/'altera_emif_mem_model_191/sim').glob('*.v'));text=leaf.read_text();ports={k:{'direction':dr,'width':int(hi)-int(lo)+1} for dr,hi,lo,k in re.findall(r'\b(input|output|inout)\s+wire\s+\[(\d+):(\d+)\]\s+(mem_\w+)',text)}
 assert len(ports)==16 and ports['mem_dq']['width']==64 and ports['mem_a']['width']==17 and ports['mem_dqs']['width']==8
 assert 'altera_emif_ddrx_model #(' in text
 wp=dict(re.findall(r'\.([A-Z0-9_]+)\s*\(([^\n]*)\)',text.split(') core (')[0]));wp={k:v.strip().strip('"') for k,v in wp.items()}
 assert wp['MEM_FORMAT_ENUM']==a['MEM_FORMAT_ENUM'] and wp['MEM_ROW_ADDR_WIDTH']=='17' and wp['MEM_COL_ADDR_WIDTH']=='10' and wp['MEM_TRCD']=='20' and wp['MEM_TRTP']=='10'
 capacity=(2**int(wp['MEM_ROW_ADDR_WIDTH']))*(2**int(wp['MEM_COL_ADDR_WIDTH']))*(2**int(wp['PORT_MEM_BA_WIDTH']))*(2**int(wp['PORT_MEM_BG_WIDTH']))*(int(wp['PORT_MEM_DQ_WIDTH'])//8)*int(wp['PORT_MEM_CS_N_WIDTH']);assert capacity==16*1024**3
 report=E.parse(r/n/(n+'.qgsimc'));cores=[{k:m.findtext(k) for k in ['className','version','name','uniqueName']} for m in report.findall('.//instanceData') if m.findtext('className')=='altera_emif_mem_model_core_ddr4'];assert len(cores)==1
 allp=E.parse(r/(n+'.ip')).findall('.//i:parameter',ns);locked=next(x.findtext('i:value',namespaces=ns) for x in allp if x.findtext('i:name',namespaces=ns)=='lockedInterfaceDefinition');lockports={x.findtext('name'):int(x.findtext('width')) for x in E.fromstring(locked).findall('.//port')};assert lockports=={k:v['width'] for k,v in ports.items()}
 script=r/n/'sim/common/modelsim_files.tcl';tc='source {'+str(script)+'}\nforeach c ['+n+'::get_design_files {} {} {} {'+str(r/n/'sim')+'} {/opt/altera/26.1.1/quartus}] {puts $c}\n'
 proc=subprocess.run(['tclsh'],input=tc,text=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True);commands=proc.stdout.splitlines();assert len(commands)==9
 sources=[]
 for cmd in commands:
  tokens=shlex.split(cmd);p=pathlib.Path(next(x for x in tokens if x.endswith(('.v','.sv')))).resolve();assert p.exists();sources.append({'command':cmd,'path':str(p),'library':tokens[tokens.index('-work')+1],'sha256':sha(p),'bytes':p.stat().st_size})
 assert len({s['path'] for s in sources})==9
 for p in (r/n/'altera_emif_mem_model_core_ddr4_191/sim').glob('*.sv'):
  vendor=pathlib.Path('/opt/altera/26.1.1/ip/altera/emif/ip_mem_model/common/rtl')/p.name;assert sha(p)==sha(vendor)
 closure[n]=sources
 (r/(n+'.full-parameter-diff.json')).write_text(json.dumps({'before':a,'after':b,'changes':diff,'refresh_source':d['source'],'preserved_nonderived':{k:v for k,v in a.items() if k not in u},'controller_unmodified':True},indent=2))
 result['models'][n]={'ip_sha256':sha(r/(n+'.ip')),'input_sha256':sha(r/'before'/(n+'.ip')),'parameter_count':len(b),'changed_parameters':len(diff),'preserved':{k:b[k] for k in preserved},'capacity_bytes':capacity,'ports':ports,'core':cores,'top':str(top),'top_sha256':sha(top),'leaf':str(leaf),'leaf_sha256':sha(leaf),'leaf_bytes':leaf.stat().st_size,'wrapper_parameters':wp,'source_count':len(sources),'controller_sopcinfo_sha256':sha(pathlib.Path(d['source'])),'location_params':{k:v for k,v in b.items() if 'LOCATION' in k or 'BOT'==v}}
before=json.loads((r/'work04-before.json').read_text());after={p:sha(pathlib.Path(p)) for p in before};assert before==after
(r/'work04-after.json').write_text(json.dumps(after,indent=2));result['work04_unchanged_files']=len(after)
(r/'source-closure.json').write_text(json.dumps(closure,indent=2));(r/'verification.json').write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2))
