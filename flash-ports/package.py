"""Package compiled calculator games, their data, libraries, and instructions."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil
import zipfile

ROOT = Path(__file__).resolve().parent.parent
HERE = ROOT / 'flash-ports'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--name', default='FlashGamesCE-v6-preview')
a = p.parse_args()
assert a.name and all(c.isalnum() or c in '-_' for c in a.name)
OUT = ROOT / 'release' / a.name
OUT.mkdir(parents=True, exist_ok=True)
inputs = [HERE / 'scoutcamp/bin/SCOUTCE.8xp', HERE / 'pedrofu/bin/PEDROCE.8xp']
for program in inputs:
    maptext=program.with_suffix('.map').read_text()
    end=int(re.search(r'^\s*(0x[\da-fA-F]+)\s+___data_high\s*=',maptext,re.M)[1],16)
    assert end<=0xD40000, f'{program.name} overlaps LCD buffers'
scout_banks=int(re.search(r'#define ART_BANKS (\d+)',(HERE/'scoutcamp/src/art.h').read_text())[1])
pedro_banks=int(re.search(r'#define BUNDLE_BANKS (\d+)',(HERE/'pedrofu/src/bundle.h').read_text())[1])
assert {p.stem for p in (HERE/'scoutcamp/bin').glob('*.8xv')}=={f'SCA{i:02d}' for i in range(scout_banks)}
assert {p.stem for p in (HERE/'pedrofu/bin').glob('*.8xv')}==({f'PDB{i:02d}' for i in range(pedro_banks)}|{'PDCOLOR','PDTILE0','PDTILE1'}|{f'PDU{i}{h}' for i in range(3) for h in range(2)})
inputs += sorted((HERE / 'scoutcamp/bin').glob('*.8xv'))
inputs += sorted((HERE / 'pedrofu/bin').glob('*.8xv'))
inputs += [ROOT / 'local-tools/cemu/clibs/clibs' / (n + '.8xv')
           for n in ['libload', 'graphx', 'keypadc', 'fileioc']]
for source in inputs:
    shutil.copy2(source, OUT / source.name)
for source, name in [(HERE / 'README.md', 'START-HERE.md'), (HERE / 'CREDITS.md', 'CREDITS.md'),
                     (HERE / 'CONTINUATION-v6-2026-11-06.md', 'CHECKPOINT.md'),
                     (HERE / 'scoutcamp/README.md', 'Scouts-Controls-and-Notes.md'),
                     (HERE / 'pedrofu/PORT-NOTES.md', 'Pedro-Controls-and-Notes.md'),
                     (HERE / 'verification/CHECKPOINT-v6.md', 'Verification.md')]:
    shutil.copy2(source, OUT / name)
manifest = {f.name: {'bytes': f.stat().st_size, 'sha256': hashlib.sha256(f.read_bytes()).hexdigest()}
            for f in sorted(OUT.iterdir()) if f.is_file() and f.suffix in ['.8xp', '.8xv']}
(OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2))
archive = OUT.with_suffix('.zip')
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
    for f in sorted(OUT.iterdir()):
        if f.is_file():
            z.write(f, a.name + '/' + f.name)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    assert len([n for n in z.namelist() if n.endswith('.8xp')]) == 2
    assert len([n for n in z.namelist() if n.endswith('.8xv')]) == len(inputs) - 2
print(f'{archive}: {archive.stat().st_size} bytes; 2 games, {len(inputs)-6} data AppVars, 4 runtime AppVars')
