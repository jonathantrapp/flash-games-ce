"""Launch one native fixture and assert its four-byte diagnostic result."""
from pathlib import Path
import argparse,json,re,subprocess
p=argparse.ArgumentParser();p.add_argument('name');p.add_argument('directory');p.add_argument('symbol');p.add_argument('hexbytes');a=p.parse_args()
root=Path(__file__).resolve().parents[1];out=root/'tests'/'native-runs'/a.name;out.mkdir(parents=True,exist_ok=True)
m=re.search(r'^\s*(0x[0-9a-f]+)\s+_'+a.symbol+r'\s*$',(root/a.directory/(a.name+'.map')).read_text(),re.M);assert m
crc=0xffffffff;data=bytes.fromhex(a.hexbytes)
for b in data:
 crc^=b
 for _ in range(8):crc=(crc>>1)^(0x82f63b78 if crc&1 else 0)
config={'rom':'C:/Users/jonat/Downloads/ti-84ce.rom','transfer_files':[str(root/a.directory/(a.name+'.8xp'))],'target':{'name':a.name,'isASM':True},'delay_after_step':0,'sequence':['action|launch','delay|5000','hashWait|pass'],'hashes':{'pass':{'description':a.symbol,'start':m[1],'size':len(data),'expected_CRCs':['%08X'%(crc^0xffffffff)],'timeout':3000}}}
f=out/'test.json';f.write_text(json.dumps(config));result=subprocess.run([str(root/'../../build/cemu-cli/cemu-autotester.exe'),'-d',str(f)],cwd=out,capture_output=True,text=True,timeout=120,creationflags=0x08000040);(out/'log.txt').write_text(result.stdout+result.stderr);print(result.stdout+result.stderr);raise SystemExit(result.returncode)
