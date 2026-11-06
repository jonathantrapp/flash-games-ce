# Developer handoff, v5 preview, 6 November 2026

## Latest continuation from db136ad

Read `CONTINUATION-v5-2026-11-06.md` and `verification/CHECKPOINT-v5.md`. The v4 material below remains historical.

- Production Pedro: 58,689 bytes, SHA-256 `d1e5b5c667a54655fa5b32afd276cad8e4790be990a883f541e7daf318c0d958`. Six 1,600-byte actor-cache slots retain exact art and improve the sampled scene from 12 to 13 FPS / 30 steps/sec. Native terrain/HUD/actor framebuffer and canary checks pass. Resident end `0xD365D8`, BSS end `0xD12903`.
- Production Scouts: 46,974 bytes, SHA-256 `9a64c9ef1f85b452c2e40396aaf6b3378ae737dc8fbdec2f0e0be94f4c3faa74`. `input.c` queues sampled transitions through rendering and simulation checkpoints, throttled to roughly 125 Hz. Cursor repeat is 200 ms. Three tap intervals and freeze/restore pass; first-wave 40/80 ms tap scenarios also pass. Measured 1×/4× settings advance 19.83/44.83 ticks/sec in the paired stage-one setup (targets 20/80), so sustained 4× remains unresolved.
- All 15 Pedro and 17 Scouts entries pass again; see `STAGE-SMOKE-v5-pedrofu-scoutcamp.md`. Scouts entries 1–3 were repeated after the final throttle change and have matching run metadata. These are not playthroughs.
- Hardware clarification: user launched through **arTIfiCE**, then used **arrow keys after the kick instruction**. Revision 8 / OS 5.8.2.29 / ROM 5.6.1.6. `v5_arrow_tutorial` visibly reaches the kick tip; `v5_arrow_continuation` advances to Yak dialogue without a local OS 5.3 reset. Hardware RAM clear is still unresolved; no matching OS 5.8 ROM is available locally.
- The original-game browser comparison stopped: browser control disabled in Work settings, and native Computer Use could not verify Brave's URL. Do not claim original-versus-port campaigns were completed. Full campaigns, boss/arena phases and save/archive-pressure reload remain priorities after performance/hardware reproduction.
- Assets/banks stay at v4 content. Package default now creates `FlashGamesCE-v5-preview.zip`. Sources, selected logs/metadata and screenshots sync through `sync_repo.py`; never upload ROM or raw RAM. The native pixel fixture now stays open after reporting and checks its result-screen swap before capture.

## Historical v4 handoff

Workspace: `E:\AI Stuff\Calc Stuff`. Start with `CONTINUATION-2026-11-06.md`, `verification/CHECKPOINT-v4.md` and each game's notes. Both programs are development previews; never reuse historical checklist percentages as gameplay fidelity.

## State left behind

- Frozen programs: Pedro58,706B/SHA256`e1df6622836ff3597d2ee1a8ba296cf74e36169253a8806f45415da2e63aabe3`; Scouts47,039B/SHA256`8c6bf764ae0679215e4fb017d4474c4c9c10aa37a59b605fab6372c9c85a50fd`.
- All15 Pedro +17 Scouts production stage-entry checks passed. They are not full playthroughs. Pedro tutorial/stress/exit, native pixel/UI checks and Scouts engine/controls checks are documented with scopes/limitations.
- Pedro: original opening already restored; this pass added opaque terrain/HUD RAM caches and original live descriptions for45 skills. Same emulator scene improved~9→12 FPS; still inadequate.
- Scouts: original campaign/menu/ending and48skills×5 descriptions, focus targeting, speed settings/freeze, status-filter repairs.33signedSCA banks/signature91bdb3a8; replace all with program. Pedro has19PDB banks plus9 separate art/palette/tile AppVars.
- Package: `release/FlashGamesCE-v4-preview.zip`; repository copy under `build/flash-games-ce-repo/dist/`. The separate repo README links latest source, package, report and screenshots.

## Next priorities

1. Reproduce the physical stage-one freeze/RAM clear after the aerial-kick tutorial. User hardware is TI84 Plus CE rev8, OS5.8.2.29/ROM5.6.1.6. Local emulator ROM is OS5.3.0.0037, so passing CEmu tests do not prove a fix.
2. Profile Pedro's remaining redraw cost. Keep exact original art/mechanics; use framebuffer comparisons for optimizations. Do not switch to speed/compiler experiments that crash or overlap memory.
3. Fix Scouts rapid-input sampling and measure actual accelerated simulation. A4× setting is selectable/restorable, but sustained4× real time is unverified; one220ms tap was missed in a repeated-input case.
4. Run original-versus-port campaigns in Ruffle/CEmu, including bosses/arenas/skills/save reload under archive pressure. Correct remaining animation/effect/camera/timing differences. Pedro30Hz fixed point still differs from Flash60Hz float; original audio is absent.

## Commands/tools

From each game folder, default build: `& '../../local-tools/cedev/CEdev/bin/make.exe' 'OBJDIR=obj_v4'`.32-bit make/compiler tools require escalated execution in this environment; default execution can fail with an Illegal System DLL Relocation message. Both makefiles include ram_guard.ld; resident code/data must stay below0xD40000. Do not remove the guard to make an oversized build pass.

From workspace root:

```
python flash-ports/run_scenario.py pedrofu example "enter enter wait:18000 enter enter hold:right:2000 alpha mode" --tap 500 --check pedro_diag:2:1
python flash-ports/verify_stages.py pedrofu scoutcamp --tag next
python flash-ports/pedrofu/tests/check_native_render_cache.py
python flash-ports/pedrofu/tests/check_skill_descriptions.py
python flash-ports/pedrofu/tests/check_native_skill_ui.py
python flash-ports/package.py
python flash-ports/sync_repo.py
```

Native runner: `build/cemu-cli/cemu-autotester.exe`; sources in `local-tools/cemu-source/tests/autotester`. The OS-token launch race was fixed with80ms emulation after accepted tokens. CEmu key names use `+`/`-`, not add/sub. Stage key scripts now include Scouts title→map→briefing (3 Enter taps); GRAPH sends a wave. `smoke.py --check` supports comma-separated accepted values and treats NMI output as failure. Capture directories have raw RAM locally: never upload those or the user's ROM.

Asset regeneration needs Python3.12/Pillow from `local-tools/plot-libs`, not default Python3.15. Scouts: generate_ui.py before build_art.py (see README). Pedro: build_assets.py, build_full_assets.py, build_intro_assets.py, build_render_cache.py, bundle_assets.py, build_skill_descriptions.py. Do not package obj_*/bin_* experiments; default bin files only. Verify all matching banks before distributing.

## GitHub and user rules

Only push `build/flash-games-ce-repo` to `https://github.com/jonathantrapp/flash-games-ce`. The workspace root repo is unrelated NeuroFlappy work: preserve its modifications and never push that remote for this task. User authorized continued repo updates and asks for screenshots and candid completed/unfinished reports. Do not claim99–100% fidelity or hardware crash resolution. Keep the repo private; preserve original Hamumu credits. Commits use the user's configured contributor identity `jonathantrapp <166062444+jonathantrapp@users.noreply.github.com>` as authorized.

Git Credential Manager works for escalated git push; gh is unauthenticated. sync_repo.py copies project files, selected evidence/screenshots and .ld/.s sources, excluding builds/ROM/RAM. Copy the new ZIP into the separate repo's dist folder before committing. Read git log/status to determine the latest pushed commit. Do not touch unrelated files or request already-granted repo permission again.
