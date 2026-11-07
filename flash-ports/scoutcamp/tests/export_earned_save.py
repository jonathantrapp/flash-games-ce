"""Export SCTSV02 unchanged from a completed CEmu run's RAM/VAT.

This continues actual emulator play without rebuilding progress. The AppVar
stays local: never include it, the source RAM or ROM in a release package.
"""
from pathlib import Path
import argparse, hashlib, json

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('scenario',type=Path)
p.add_argument('output',type=Path)
p.add_argument('--wins',type=int,required=True)
a=p.parse_args()
ram=(a.scenario/'native-ram.bin').read_bytes()
meta=json.loads((a.scenario/'run-metadata.json').read_text())
assert 'Autotest passed' in (a.scenario/'smoke.log').read_text()
u24=lambda n:int.from_bytes(ram[n:n+3],'little')
program_end=0x1a881+u24(0x118c)
vat_low=u24(0x2590)-0xd00000
name=b'SCTSV02'
needle=name[::-1]+bytes([len(name)])
hits=[i for i in range(vat_low,0x40000-len(needle)) if ram.startswith(needle,i)]
assert len(hits)==1,hits
i=hits[0]
pointer=int.from_bytes(ram[i+len(needle):i+len(needle)+3],'big')-0xd00000
assert ram[i+len(needle)+5]==0x15 # AppVar type, descending CE VAT entry
assert program_end<=pointer<u24(0x258a)-0xd00000
size=int.from_bytes(ram[pointer:pointer+2],'little')
assert size==76,size
payload=ram[pointer+2:pointer+2+size]
assert payload[:4]==b'SCV2' and all(v<=5 for v in payload[4:52])
wins=list(payload[52:69])
assert wins==[1]*a.wins+[0]*(17-a.wins),wins
assert 1<=payload[69]<=99
length=(size+2).to_bytes(2,'little')
entry=(13).to_bytes(2,'little')+length+b'\x15'+name.ljust(8,b'\0')+b'\0\0'+length+size.to_bytes(2,'little')+payload
comment=b'Unmodified earned CEmu campaign save'.ljust(42,b'\0')
binary=b'**TI83F*\x1a\x0a\0'+comment+len(entry).to_bytes(2,'little')+entry+(sum(entry)&65535).to_bytes(2,'little')
a.output.parent.mkdir(parents=True,exist_ok=True)
a.output.write_bytes(binary)
report=dict(source_scenario=a.scenario.name,source_program_sha256=meta['program_sha256'],
            source_ram_sha256=hashlib.sha256(ram).hexdigest(),vat_address=hex(0xd00000+i),
            data_address=hex(0xd00000+pointer+2),payload_sha256=hashlib.sha256(payload).hexdigest(),
            appvar_sha256=hashlib.sha256(binary).hexdigest(),wins=wins,player_level=payload[69],
            skill_points=int.from_bytes(payload[70:72],'little'),xp=int.from_bytes(payload[72:76],'little'),
            archived=False,scope='Unmodified VAT-backed save earned by actual preceding CEmu play; emulator-only continuation, not fabricated progress or physical transfer.')
a.output.with_suffix('.provenance.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
