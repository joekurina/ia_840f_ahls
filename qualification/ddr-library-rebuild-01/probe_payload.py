from pathlib import Path
import json
P=Path('/home/uwb_student00/ahls/new_BSP/qualification');Q=P/'ddr-library-rebuild-01';Q.mkdir(exist_ok=False)
I=P/'ddr-library-import-01'
p=I/'imports/quartus-23.1/tennm_atoms.sv';t=p.read_text();a=t.index('module tennm_iossm');b=t.index('endmodule',a)+len('endmodule')
r={'wrapper':t[a:b],'recipe_evidence':json.loads((I/'compatibility-evidence.json').read_text())}
(Q/'source-inspection.json').write_text(json.dumps(r,indent=2))
print(t[a:b]);print('RECIPE',json.dumps(r['recipe_evidence'])[:16000])
