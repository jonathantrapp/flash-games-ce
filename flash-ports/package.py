"""Package compiled calculator games, their data, libraries, and instructions."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parent.parent
HERE = ROOT / 'flash-ports'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--name', default='FlashGamesCE-v2')
a = p.parse_args()
assert a.name and all(c.isalnum() or c in '-_' for c in a.name)
OUT = ROOT / 'release' / a.name
OUT.mkdir(parents=True, exist_ok=True)
inputs = [HERE / 'scoutcamp/bin/SCOUTCE.8xp', HERE / 'pedrofu/bin/PEDROCE.8xp']
inputs += sorted((HERE / 'scoutcamp/bin').glob('*.8xv'))
inputs += sorted((HERE / 'pedrofu/bin').glob('*.8xv'))
inputs += [ROOT / 'local-tools/cemu/clibs/clibs' / (n + '.8xv')
           for n in ['libload', 'graphx', 'keypadc', 'fileioc']]
for source in inputs:
    shutil.copy2(source, OUT / source.name)
for source, name in [(HERE / 'README.md', 'START-HERE.md'),
                     (HERE / 'scoutcamp/README.md', 'Scouts-Controls-and-Notes.md'),
                     (HERE / 'pedrofu/PORT-NOTES.md', 'Pedro-Controls-and-Notes.md'),
                     (HERE / 'verification/RESULTS.md', 'Verification.md')]:
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
