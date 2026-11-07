# v9 native/reference and production checks

From the workspace root, with the existing local CEdev toolchain, libraries and user ROM:

```
python flash-ports/scoutcamp/tests/check_native_stage1_route.py --v7-control --tag frozen_v7_control
python flash-ports/scoutcamp/tests/check_native_stage1_route.py --tag corrected_route
python flash-ports/scoutcamp/tests/check_native_movement.py
python flash-ports/scoutcamp/tests/check_native_physics.py
python flash-ports/scoutcamp/tests/check_native_food.py
python flash-ports/scoutcamp/tests/check_native_art_render.py
python flash-ports/scoutcamp/tests/check_native_scene_render.py
python flash-ports/scoutcamp/tests/check_input_timing.py --tag v9_ready500
python flash-ports/scoutcamp/tests/check_speed_controls.py --tag v9_controls
python flash-ports/verify_stages.py scoutcamp --tag v9_candidate
```

The frozen-v7 route is an expected blocked control; the corrected route must steal one meal and return to the portal. Physics compares the coordinate optimization against an uncached v8 reference with the same intentional slope correction. The frozen v7 reference and coordinate-only result remain available. Neither comparison alone proves original collision parity; the focused source-derived slope/ceiling assertions and route regression address the correction.

Renderer fixtures use LTO=NO, COMPRESSED=NO and ARCHIVED=NO, and transfer all four runtime libraries. They compare raw framebuffers at both addresses. The separate scene suite checks nonzero HUD/tile cache canaries; the montage suite preserves its original guard values. Keep the suites separate: alternative layouts, including a combined fixture, produced OS ERROR: UNDEFINED before result counters and are not accepted evidence. Debug-stop runs are phase probes only. Production binaries and data remain separate from these fixtures.

`benchmark_crowded.py` reads production frame/tick counters without an overlay or QA_PERF. Its default stage16 uses VARS only for map entry, natural first-wave spawns and paired1s/7s intervals. `--stage 1 --quiet` measures an empty stage without an early wave send. `--bin-dir` selects a preserved build, whose `build-metadata.json` binds the program hash to sources/flags. `profile_crowded.py` instead requires a separate QA_PERF build, with instrumentation overhead. Do not present those diagnostic timings as production FPS.

The stage-one legal two-rock strategy, loss/retry, arTIfiCE save/relaunch and32KB RAM-pressure evidence are documented in [CHECKPOINT-v8.md](../../verification/CHECKPOINT-v8.md). They establish a saved stage-two unlock, not a complete campaign or archive-GC. All emulator batches run at idle priority. ROM/RAM dumps, saves, fillers and native binaries stay local.

## Earlier fixture notes

# Original rule parity check

Run `python check_original_rules.py` from any directory after generating `src/rules.h` and `src/engine.h`. It uses the workspace's portable Zig host compiler.

The fixture compiles the actual generated native rules and actual `skillNeeded` function. Its independent expected values are evaluated from the original decompiled AS3, including original `int`/`uint` return coercion. It checks all12 towers,6 stat fields, levels0..5,246 skill profiles (uniform0..5 plus each individual skill at1..5), all48 skill unlock entries and10 monsters at levels0..64. Relative/absolute float tolerance is2e-6; integer return fields require their original integral values.

The result JSON records every difference with source line and input values. The initial expanded run found614 differences caused by native float return values where original AS3 returned integers; all monster and skill-unlock comparisons passed. Rerun after correcting the generator; this historical result does not establish the current implementation's status.

This checks numerical rule fidelity. It does not establish whether the game applies those rules correctly during projectile collisions, enemy AI, progression or the UI.

## UI continuation checks

`check_resources.py --bin-dir bin_ui` also verifies all 240 original skill-description offsets and the exact copied text blob in the signed banks. Run `generate_ui.py` before `build_art.py` to regenerate that blob.

Native scenarios under `../../verification/scoutcamp/`: `ui_map_final`, `ui_skills_final`, `ui_play_final`, `ui_reset_final`, `ui_ending_final`, `ui_exit_final`. The final production program is built with no QA flags. `QA_ENDING` starts a diagnostic build at the ending; combined with `QA_MAXED`, it lets reset tests distinguish the pre-reset and initial profiles. These diagnostic paths do not prove a complete campaign is winnable.

## Focus and speed continuation

v5: `check_input_timing.py` drives the production program at three hold/release intervals and compares paired 1s/7s simulation intervals. `input-timing-results.json` identifies the tested binary and actual rates; `input-timing-poll1-results.json` retains the slower rejected near-1-kHz polling variant. The below v4 `check_speed_controls.py` result remains historical. New `v5_combat_rapid40` and `v5_combat_rapid80` scenarios verify the requested speed and active first wave after repeated taps, without a campaign-completion claim.

The actual-native fixture `qa_engine/main.c` now has44 cases. Build from the game directory with `make NAME=SCENG SRCDIR=tests/qa_engine OBJDIR=obj_engine_raw BINDIR=bin_engine_raw COMPRESSED=NO ARCHIVED=NO`, then run `python tests/run_native_test.py SCENG bin_engine_raw engine_diag 0100002c`. Targeting cases cover focused priority, fallback when blocked/ineligible, Snow/ice/shock/cripple filters, the separate FindBelow behavior, selection distance, death and escape cleanup.

`check_speed_controls.py` drives real keypad inputs in CEmu and reads exported tick counters. It checks freeze, restored requested settings, progression and bounds. It records observed timing; it does not certify the nominal4x setting runs at4x wall-clock speed. The initial exact-rate assertion failed and is documented in its result scope. CEmu accepts `+`/`-` key names, not `add`/`sub`.

`QA_FOCUS` places a frozen fixture enemy near the initial building cursor, solely for keyboard focus/clear/new-stage integration checks. It is excluded from production. New native scenarios are `focus_selected_final`, `focus_cleared`, `focus_newstage`, `focus_gameplay`, `controls_*` and `controls_exit`.

## v9 campaign and source provenance

See [CHECKPOINT-v9.md](../../verification/CHECKPOINT-v9.md) and `verification/scoutcamp/v9-campaign-results.json`. The selected build passes stage3 from an unchanged earned save, normal loss/retry and an arTIfiCE saved unlock under32KB RAM pressure. `export_earned_save.py` checks the real VAT-backed save and records provenance; the save itself is private test input, never release content. Movement comparisons use frozen actual-v8 physics; whole-scene tests link the old formatter independently of the replacement. Generated native folders and all `experiments` remain local. The floor-standing shortcut failed and is excluded. Archive-GC helper tests remain unfinished and are not release validation.
