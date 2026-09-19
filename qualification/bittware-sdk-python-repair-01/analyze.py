import pathlib,json,zipfile,importlib.metadata as m,collections
from packaging.requirements import Requirement
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01'); S=pathlib.Path('/usr/share/bittware-sdk')
(R/'bw_pip-python-source.txt').write_text((S/'scripts/bw_pip.py').read_text())
D=json.loads((R/'distributions-before.json').read_text());current={p.name.split('-')[0].replace('_','-') for p in (S/'python').glob('bw*.whl')};old=[d for d in D if d['name'].startswith('bw-') and d['name'] not in current];removed={d['name'] for d in old}|{'grpcio-tools'}
reverse={n:[] for n in removed}
for d in D:
 for s in d['requires']:
  q=Requirement(s)
  if q.name in removed and (q.marker is None or q.marker.evaluate({'extra':''})):reverse[q.name].append({'name':d['name'],'requirement':s})
print('REMOVE_CANDIDATES',[(d['name'],d['version']) for d in old], 'grpcio-tools');print('REVERSE',json.dumps(reverse))
assert not [x for v in reverse.values() for x in v if x['name'] not in removed]
sets={d['name']:{str(pathlib.Path(p).resolve()) for p in d['files']} for d in D};overlap=[]
for a in removed:
 for b in current:
  both=sets[a]&sets[b]
  if both:overlap.append(dict(old=a,new=b,count=len(both),files=sorted(both)))
(R/'repair-analysis.json').write_text(json.dumps(dict(remove=sorted(removed),reverse=reverse,overlap=overlap,current=sorted(current)),indent=2));print('OVERLAPS',[(r['old'],r['new'],r['count']) for r in overlap])
site=pathlib.Path.home()/'.local/lib/python3.9/site-packages'
paths=['bw_core_utils/bw_product.py','bw_core_utils/__init__.py','bw_core/__init__.py','bw_agilex/__init__.py','bw_agilex/products/__init__.py','bw_agilex/products/ia840f_product.py','bw_core_utils/bw_card_list.py']
for p in paths:
 f=site/p
 if f.exists():print('SOURCE',p);print(f.read_text());dest=R/'source'/p;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(f.read_bytes())
hits=[]
for d in D:
 if d['name'] in current:
  for f in d['files']:
   p=pathlib.Path(f)
   if p.suffix=='.py' and p.exists() and 'grpc_tools' in p.read_text(errors='replace'):hits.append(str(p))
print('CURRENT_GRPC_TOOLS_REFERENCES',hits);print('DONE')
