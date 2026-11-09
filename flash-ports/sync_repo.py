"""Copy only this port project into its separate GitHub checkout."""
from pathlib import Path
import shutil
import re

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / 'flash-ports'
DST = ROOT / 'build/flash-games-ce-repo'
assert (DST / '.git').is_dir(), 'Clone the separate flash-games-ce repository first'
excluded = {'obj', 'obj_qa', '__pycache__', 'verification', 'bin', 'bin_qa', 'data', 'experiments', 'compiler-cache'}
extensions = {'.py', '.c', '.h', '.s', '.S', '.ld', '.as', '.md', '.json', '.png', '.bin'}
count = 0
for source in SRC.rglob('*'):
    rel = source.relative_to(SRC)
    if len(rel.parts)>=3 and rel.parts[:2]==('scoutcamp','tests') and rel.parts[2] in {'art-native','render-native','food-native','physics-native','route-native','movement-native','format-render-native','standing-native','gc-native','native-runs','qa_archive_gc'}:
        continue
    if rel.name in {'NEXT-DEV-PROMPT.md','CONTINUATION-v9-WIP-2026-11-07.md','check_native_formatter_render.py','check_archive_gc.py','verify_gc_capture.py'}:
        continue
    if not source.is_file() or excluded.intersection(rel.parts) or any(part.startswith(('obj_', 'bin_')) or re.fullmatch(r'(?:obj|bin)[0-9]+',part) for part in rel.parts):
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
         'pedro-v6-stationary.png': 'pedrofu/v6_final_production_pair_10s',
         'pedro-v6-moving.png': 'pedrofu/v6_final_production_motion_9s',
         'pedro-v6-tutorial.png': 'pedrofu/v6_arrow_tutorial',
         'pedro-v5-kick.png': 'pedrofu/v5_arrow_tutorial',
         'pedro-v5-arrows.png': 'pedrofu/v5_arrow_continuation',
         'pedro-v5-performance.png': 'pedrofu/v5_actor_trial',
         'scout-v5-rapid.png': 'scoutcamp/v5_combat_rapid40',
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
for name in ['CHECKPOINT-v5.md','STAGE-SMOKE-v5-pedrofu-scoutcamp.md']:
    shutil.copy2(SRC/'verification'/name,DST/'flash-ports/verification'/name)
# Publish only logs, small timing reports and non-sensitive build metadata.
# Captures retain ROM/configuration/RAM locally; they are never copied here.
for game in ['pedrofu','scoutcamp']:
    for scenario in (SRC/'verification'/game).glob('v5_*'):
        if not scenario.is_dir():continue
        for name in ['smoke.log','run-metadata.json','performance.json']:
            source=scenario/name
            if source.is_file():
                dest=DST/'flash-ports/verification'/game/scenario.name/name
                dest.parent.mkdir(parents=True,exist_ok=True)
                if name=='smoke.log':dest.write_text(source.read_text().rstrip()+'\n')
                else:shutil.copy2(source,dest)
source=SRC/'pedrofu/tests/render-native/smoke.log'
dest=DST/'flash-ports/pedrofu/tests/render-native/smoke.log'
dest.write_text(source.read_text().rstrip()+'\n')
for name in ['CHECKPOINT-v6.md','STAGE-SMOKE-v6_final-pedrofu.md']:
    shutil.copy2(SRC/'verification'/name,DST/'flash-ports/verification'/name)
tags=['v6_baseline_pair','v6_baseline_motion','v6_final_pair','v6_final_motion',
      'v6_final_production_pair','v6_final_production_motion']
for tag in tags:
    source=SRC/'verification/pedrofu'/(tag+'-benchmark.json')
    dest=DST/'flash-ports/verification/pedrofu'/source.name
    dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,dest)
scenarios=[f'v6_final_stage{i:02d}' for i in range(1,16)]+[
 'v6_transitions','v6_arrow_tutorial','v6_exit','v6_input_stress']
for tag in tags:
    scenarios += [tag+'_'+str(n)+'s' for n in ([3,9] if 'motion' in tag else [4,10])]
for scenario in scenarios:
    for name in ['smoke.log','run-metadata.json']:
        source=SRC/'verification/pedrofu'/scenario/name
        if source.exists():
            dest=DST/'flash-ports/verification/pedrofu'/scenario/name
            dest.parent.mkdir(parents=True,exist_ok=True)
            if name=='smoke.log':dest.write_text(source.read_text().rstrip()+'\n')
            else:shutil.copy2(source,dest)
source=SRC/'pedrofu/tests/scene-native/smoke.log'
dest=DST/'flash-ports/pedrofu/tests/scene-native/smoke.log'
dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for name in ['CHECKPOINT-v7.md','STAGE-SMOKE-v7_final-pedrofu-scoutcamp.md']:
    shutil.copy2(SRC/'verification'/name,DST/'flash-ports/verification'/name)
for game in ['pedrofu','scoutcamp']:
    for scenario in (SRC/'verification'/game).glob('v7*'):
        if scenario.is_file() and scenario.suffix=='.json':
            dest=DST/'flash-ports/verification'/game/scenario.name
            dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(scenario,dest)
        elif scenario.is_dir():
            for name in ['smoke.log','run-metadata.json']:
                source=scenario/name
                if source.is_file():
                    dest=DST/'flash-ports/verification'/game/scenario.name/name
                    dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for scenario in (SRC/'verification/scoutcamp').glob('controls_*'):
    for name in ['smoke.log','run-metadata.json']:
        source=scenario/name
        if source.is_file():
            dest=DST/'flash-ports/verification/scoutcamp'/scenario.name/name
            dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for folder in ['scene-native','scene-native-flash','render-native','format-native']:
    source=SRC/'pedrofu/tests'/folder/'smoke.log'
    if source.is_file():
        dest=DST/'flash-ports/pedrofu/tests'/folder/'smoke.log'
        dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
source=SRC/'scoutcamp/tests/native-runs/SCENG/log.txt'
dest=DST/'flash-ports/scoutcamp/tests/native-runs/SCENG/log.txt'
dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for name,scenario in {'pedro-v7-cache.png':'pedrofu/v7_ram_production_pair_10s',
                      'pedro-v7-flash.png':'pedrofu/v7_ram_art_fill',
                      'scout-v7-crowded.png':'scoutcamp/v7_stage16_crowded_7'}.items():
    shutil.copy2(SRC/'verification'/scenario/'screen.png',DST/'docs/screenshots'/name)
# v8: explicitly selected summaries/logs only, never native binaries/RAM/saves.
for name in ['CHECKPOINT-v8.md','STAGE-SMOKE-v8_candidate-scoutcamp.md','v8-package-validation.json']:
    shutil.copy2(SRC/'verification'/name,DST/'flash-ports/verification'/name)
for scenario in (SRC/'verification/scoutcamp').glob('v8*'):
    if scenario.name=='v8_art_native_launcher':continue # failed experimental fixture
    if scenario.is_file() and scenario.suffix=='.json':
        dest=DST/'flash-ports/verification/scoutcamp'/scenario.name
        dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(scenario,dest)
    elif scenario.is_dir():
        for name in ['smoke.log','run-metadata.json']:
            source=scenario/name
            if source.is_file():
                dest=DST/'flash-ports/verification/scoutcamp'/scenario.name/name
                dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for folder in ['art-native','render-native','physics-native','food-native']:
    for name in ['result.json','smoke.log']+(['coordinate-only-v7-result.json'] if folder=='physics-native' else []):
        source=SRC/'scoutcamp/tests'/folder/name
        dest=DST/'flash-ports/scoutcamp/tests'/folder/name
        dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for tag in ['before_slope_fix','after_ceiling_fix','inclusive_floor_fix','frozen_v7_control']:
    for name in ['result.json','smoke.log']:
        source=SRC/'scoutcamp/tests/route-native/runs'/tag/name
        dest=DST/'flash-ports/scoutcamp/tests/route-native/runs'/tag/name
        dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for name,tag in {'scout-v8-win.png':'v8_campaign_two_rocks','scout-v8-unlock-ram32k.png':'v8_win_unlock_ram32k'}.items():
    shutil.copy2(SRC/'verification/scoutcamp'/tag/'screen.png',DST/'docs/screenshots'/name)
for name in ['FlashGamesCE-v8-preview.zip','FlashGamesCE-v8-preview.zip.sha256']:
    shutil.copy2(ROOT/'release'/name,DST/'dist'/name)
# v9: only accepted production runs and selected native summaries.
for name in ['CHECKPOINT-v9.md','STAGE-SMOKE-v9_candidate-scoutcamp.md','v9-package-validation.json','validate_v9_package.py','RELEASE-v9.md']:
    shutil.copy2(SRC/'verification'/name,DST/'flash-ports/verification'/name)
for scenario in (SRC/'verification/scoutcamp').glob('v9*'):
    accepted = scenario.name.startswith(('v9_candidate_stage','v9_combined_','v9_controls_','v9_ready500_')) or scenario.name in {'v9_loss','v9_retry','v9_stage3_combined','v9_stage3_rocks_snow','v9_campaign_stage2_reinforce','v9_stage4_entry_earned','v9_win_unlock_ram32k','v9-campaign-results.json'}
    if not accepted:continue
    names=['smoke.log','run-metadata.json'] if scenario.is_dir() else [None]
    for name in names:
        source=scenario/name if name else scenario
        if source.is_file() and (name or source.suffix=='.json'):
            dest=DST/'flash-ports/verification/scoutcamp'/scenario.name
            if name:dest=dest/name
            dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for folder in ['movement-native','render-native','food-native','physics-native','native-runs/SCENG']:
    for name in ['result.json','log.txt' if folder.startswith('native-runs') else 'smoke.log']:
        source=SRC/'scoutcamp/tests'/folder/name
        if source.is_file():
            dest=DST/'flash-ports/scoutcamp/tests'/folder/name
            dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for name,tag in {'scout-v9-stage3-win.png':'v9_stage3_combined','scout-v9-unlock-ram32k.png':'v9_win_unlock_ram32k'}.items():
    shutil.copy2(SRC/'verification/scoutcamp'/tag/'screen.png',DST/'docs/screenshots'/name)
for name in ['FlashGamesCE-v9-preview.zip','FlashGamesCE-v9-preview.zip.sha256']:
    shutil.copy2(ROOT/'release'/name,DST/'dist'/name)
# v10 work in progress: stage-4 start-cursor fix (candidate not promoted to bin/ or released).
for name in ['CHECKPOINT-v10.md','STAGE-SMOKE-v10_cursor-scoutcamp.md']:
    shutil.copy2(SRC/'verification'/name,DST/'flash-ports/verification'/name)
for scenario in (SRC/'verification/scoutcamp').glob('v10_cursor_*'):
    for name in ['smoke.log','run-metadata.json']:
        source=scenario/name
        if source.is_file():
            dest=DST/'flash-ports/verification/scoutcamp'/scenario.name/name
            dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(source.read_text().rstrip()+'\n')
for name,tag in {'scout-v10-stage4-cursor.png':'v10_cursor_stage04_idle','scout-v9-stage4-nocursor.png':'v9_control_stage04_idle'}.items():
    shutil.copy2(SRC/'verification/scoutcamp'/tag/'screen.png',DST/'docs/screenshots'/name)
shutil.copy2(SRC/'REPO-README.md',DST/'README.md')
for name in ['FlashGamesCE-v7-preview.zip','FlashGamesCE-v7-preview.zip.sha256']:
    shutil.copy2(ROOT/'release'/name,DST/'dist'/name)
print('Synced', count, 'project files and checkpoint evidence to', DST)
