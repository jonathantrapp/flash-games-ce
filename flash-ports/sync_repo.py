"""Copy only this port project into its separate GitHub checkout."""
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / 'flash-ports'
DST = ROOT / 'build/flash-games-ce-repo'
assert (DST / '.git').is_dir(), 'Clone the separate flash-games-ce repository first'
excluded = {'obj', 'obj_qa', '__pycache__', 'verification', 'bin', 'bin_qa', 'data'}
extensions = {'.py', '.c', '.h', '.s', '.S', '.ld', '.as', '.md', '.json', '.png', '.bin'}
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
         'scout-v4-map.png': 'scoutcamp/ui_map_final',
         'scout-v4-skills.png': 'scoutcamp/ui_skills_final',
         'scout-v4-ending.png': 'scoutcamp/ui_ending_final',
         'scout-v4-focus.png': 'scoutcamp/focus_selected_final',
         'scout-v4-speed.png': 'scoutcamp/speed_max_restore',
         'pedro-v4-tutorial.png': 'pedrofu/v4_tutorial',
         'pedro-v4-performance.png': 'pedrofu/v4_performance',
         'pedro-v3-opening.png': 'pedrofu/checkpoint_opening',
         'pedro-v3-tutorial.png': 'pedrofu/stage1_checkpoint',
         'scout-v3-gameplay.png': 'scoutcamp/checkpoint_play',
         'scout-v3-hungry.png': 'scoutcamp/checkpoint_hungry',
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
source=SRC/'pedrofu/tests/skill-native/screen.png'
if source.exists():
    shutil.copy2(source,DST/'docs/screenshots/pedro-v4-skills.png')
dest = DST / 'flash-ports/verification/CHECKPOINT-v3.md'
dest.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(SRC / 'verification/CHECKPOINT-v3.md', dest)
for name in ['CHECKPOINT-v4.md','STAGE-SMOKE-v4-pedrofu.md','STAGE-SMOKE-v4-scoutcamp.md']:
    shutil.copy2(SRC/'verification'/name,DST/'flash-ports/verification'/name)
source=SRC/'verification/pedrofu/v4_performance/performance.json'
dest=DST/'flash-ports/verification/pedrofu/v4_performance/performance.json'
dest.parent.mkdir(parents=True,exist_ok=True)
shutil.copy2(source,dest)
for game, scenarios in {
    'pedrofu': ['checkpoint_opening', 'intro_checkpoint', 'stage1_checkpoint', 'checkpoint_exit',
                'v4_tutorial','v4_stress','v4_exit','v4_performance']+[f'v4_stage{i:02d}' for i in range(1,16)],
    'scoutcamp': ['checkpoint_play', 'checkpoint_hungry', 'checkpoint_exit',
                 'ui_map_final','ui_skills_final','ui_play_final','ui_reset_final','ui_ending_final','ui_exit_final',
                 'focus_newstage','focus_selected_final','focus_cleared','focus_gameplay','speed_max_restore','controls_exit']
                +[f'v4_stage{i:02d}' for i in range(1,18)]
                +['controls_'+name for name in ['freeze_short','freeze_long','resume_1x','resume_1x_setting','freeze_4x','resume_4x','resume_4x_setting','upper_bound','lower_bound']],
}.items():
    for scenario in scenarios:
        source = SRC / 'verification' / game / scenario / 'smoke.log'
        dest = DST / 'flash-ports/verification' / game / scenario / 'smoke.log'
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, dest)
print('Synced', count, 'project files and checkpoint evidence to', DST)
