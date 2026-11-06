"""Copy only this port project into its separate GitHub checkout."""
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / 'flash-ports'
DST = ROOT / 'build/flash-games-ce-repo'
assert (DST / '.git').is_dir(), 'Clone the separate flash-games-ce repository first'
excluded = {'obj', 'obj_qa', '__pycache__', 'verification', 'bin', 'bin_qa', 'data'}
extensions = {'.py', '.c', '.h', '.as', '.md', '.json', '.png', '.bin'}
count = 0
for source in SRC.rglob('*'):
    rel = source.relative_to(SRC)
    if not source.is_file() or excluded.intersection(rel.parts) or any(part.startswith(('obj_', 'bin_')) for part in rel.parts):
        continue
    if source.suffix == '.bin' and 'assets' not in rel.parts:
        continue
    if source.name != 'makefile' and source.suffix not in extensions:
        continue
    dest = DST / 'flash-ports' / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, dest)
    count += 1
shots = {'scout-title.png': 'scoutcamp/new_menu',
         'scout-gameplay.png': 'scoutcamp/new_long',
         'scout-skills.png': 'scoutcamp/new_skills',
         'pedro-title.png': 'pedrofu/v2_title',
         'pedro-map.png': 'pedrofu/v2_map',
         'pedro-gameplay.png': 'pedrofu/v2_qa5'}
for name, scenario in shots.items():
    source = SRC / 'verification' / scenario / 'screen.png'
    if source.exists():
        dest = DST / 'docs/screenshots' / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, dest)
print('Synced', count, 'project files to', DST)
