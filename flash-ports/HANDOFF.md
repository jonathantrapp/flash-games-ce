# Developer handoff, v9 memory and campaign preview, 7 November 2026

## 9 November 2026: stage-4 start cursor fixed in source (not released)

`startLevel()` now clamps the initial cursor to the movement bounds; stage 4 was the only affected map. The candidate is in `scoutcamp/bin_v10cursor` (43,569 bytes, SHA-256 `b78bf3e9…841a`): 17/17 stage entries pass, and a stage-4 idle entry shows the cursor where v9 showed none. It has not been promoted to `bin/` or packaged; v9 stays the release. See `verification/CHECKPOINT-v10.md`. The v9 notes below about the stage-4 cursor describe the v9 binary.

## Next session: controls and Pedro launcher icon (user request)

Recorded 7 November 2026 after the v9 release. The user says the arrow keys are difficult to use and wants a more natural, comfortable movement layout. Prioritize an alternative to relying on the calculator arrow pad, especially for Pedro. No replacement key mapping has been selected yet; consider a spaced keypad layout and check reachability of jump, attack and Fury combinations. Keep menu navigation, displayed help/tutorial prompts and controls documentation consistent, and validate actual input in CEmu before packaging. Review Scouts movement/cursor comfort as applicable; the user did not specify the scope more narrowly.

Add a recognizable Pedro icon for the Cesium launcher, using the existing original Pedro artwork. Initial inspection found `pedrofu/makefile` sets DESCRIPTION but no ICON, and its generated `icon.s` contains description metadata only. The installed CEdev makefile supports `ICON = icon.png`; its hello_world example uses a16x16 PNG. Do not download Cesium or perform a physical transfer without asking.

The user's latest instruction is **do not implement this now; write it down for next time**. No game code, artwork, build, package or release was changed for these requests. The published v9 release remains the baseline. This note is local only; do not republish v9 just to incorporate it.

Read `CONTINUATION-v9-2026-11-07.md` and `verification/CHECKPOINT-v9.md` first. v8 was published as `e26212d`. The selected Scouts program is 43,502 bytes, SHA-256 `9ae1dad156c59bc03cd4e453affb6a85d68bcb2a2205525907522aa125248aae`; Pedro remains exactly v7, 51,070 bytes, SHA-256 `c87979b6b2fdd59901cccf2b2b2aafa7d8d1d29a0bfbddfb21ae2268354d78a9`.

Scouts now shares Pedro's bounded formatter and caches each enemy's exact horizontal quotient, refreshing before movement when velocity changes. Two derived fields follow all gameplay fields. Reference/native checks preserve the preceding state and verify the cache separately. Retain all frozen references, native fixtures, nonzero render canaries and `ram_guard.ld`. The checkpoint identifies passing tests and layout-sensitive fixture failures that do not count as acceptance evidence.

All current native checks, input/speed controls and 17 stage entries pass. Selected production timing without overlays is 10.83 FPS/80.5 sampled ticks in quiet stage1 and 1.50 FPS/16.17 ticks with 29–34 enemies in stage16. Frame-boundary quantization and differing populations prevent a precise overspeed or controlled crowded percentage claim. Running bytes including relocated libraries are97,536, with54,844 free crowded and21,982 with a32KB filler after arTIfiCE win/save/relaunch. No graphics or rules were reduced.

Actual play has cleared the first three stages. Stage2 followed a real stage1 win on v8; an unchanged VAT-exported earned save continued stage3 on both v8 and v9. v9 also passes normal loss/retry and the32KB RAM-pressure saved-unlock round trip. Saves and raw RAM stay local. Entries are not campaign wins. Stage4's initial cursor is out of bounds (55 on a53-wide map); one LEFT clamps it, but startLevel still needs a bound fix. Archive-GC remains pending: the normal OS command completes, but the combined native proof workflow has not passed. A separate standing-floor shortcut failed byte comparisons and must not be promoted.

Both selected programs, maps, banks and build metadata are in each game's default `bin/`; the exact Scout candidate is also preserved in `bin_v9combined`. Do not rebuild over selected files: TI container timestamps alter full-file hashes. `package.py` defaults to v9. Sync only through `sync_repo.py` into `build/flash-games-ce-repo`, review, then commit/push there. Preserve root NeuroFlappy and Horsey. Exclude experimental/native/diagnostic binaries, saves, RAM, ROMs, fillers and private emulator images from releases.

The user asks to end at a playable GitHub release while preserving30% of the five-hour limit. Prioritize publishing this validated preview and a clear handoff over further experiments. Physical-crash investigation is deferred; no download or physical transfer is authorized. Cesium and OS5.8 remain untested. Emulator batches stay idle priority.

## Historical v8 handoff

### v8 Scouts route/rendering preview, 7 November 2026

Read `CONTINUATION-v8-2026-11-07.md` and `verification/CHECKPOINT-v8.md` first. The published v7 commit is `eef8843`; v8 adds the work described below. Pedro remains the exact v7 binary (51,070 bytes, SHA-256 `c87979b6b2fdd59901cccf2b2b2aafa7d8d1d29a0bfbddfb21ae2268354d78a9`). Scouts is now 47,779 bytes, SHA-256 `245f216fc094e5188fa44806c1ecf46a77b32672e823efb05943590a73e33322`.

Scouts caches portal/camp coordinates, adds an exact pickup broadphase, draws opaque cached tiles/HUD directly and walks map rows by pointer. Original tile14/18 floor-slope flags and inclusive bottom-edge contact fix a reproduced stage-one route blocker. The original center-based slope sampling remains. Frozen v7 references are retained; the separate uncached v8 collision reference isolates optimization from the intentional fix.

Native checks pass 81,600 physics comparisons, 816 food comparisons, 44 engine assertions, 272 whole scenes with nonzero cache guards and 358 art montages. Gameplay input/speed and all 17 stage entries pass. Quiet overlay-free production reaches 10.17 FPS/80 ticks per second; crowded stage16 reaches1.33 FPS/15.83 ticks with 28–32 enemies. Different populations prevent claiming a controlled percentage improvement over v7. Physics still dominates. Keep native fixtures uncompressed/unarchived and transfer all four libraries. Renderer fixtures use LTO=NO; alternative layouts that returned ERROR: UNDEFINED/zero counters are not validation evidence. See the checkpoint for the retained passing suites.

Real stage-one production play now establishes loss, retry and a six-wave win with two ordinary rock towers. Win/save/CLEAR/arTIfiCE DOWN/relaunch preserves stage2 on the normal map, including with an unarchived32KB filler (15,286 bytes free). This is not full-campaign or archive-GC evidence. Continue stage2 and later wins, explicit archive-GC, crowded physics/render cost, then Pedro scrolling. The user explicitly deferred physical-crash investigation: no questions, downloads or physical transfers unless requested later.

Final selected files are in `scoutcamp/bin/` and `pedrofu/bin/`; the Scouts candidate remains preserved in `bin_v8play/` with build metadata. Avoid rebuilding over a validated file: convbin timestamps its TI comment, changing the full-file hash. Experimental/profile/native binaries and RAM fillers remain local and must not enter the package. `package.py` supports isolated bin folders and checkpoint paths. Commit/push only after `sync_repo.py` into `build/flash-games-ce-repo`; preserve root NeuroFlappy changes and Horsey. Keep `ram_guard.ld` and references/canaries.

## Historical v6 state

## Latest performance continuation

Read `CONTINUATION-v6-2026-11-06.md` and `verification/CHECKPOINT-v6.md` first. Pedro production: 60,826 bytes, SHA-256 `be1a601f9859941f0492af6a033349355c5c953ffc64ad0c82aba4b51a7e5f35`. Scouts/data banks are unchanged from v5.

Pedro now uses exact resident sky rows (`build_row_sky.py`), notice-panel pixel caching and per-framebuffer damage restoration. Scrolling, changed terrain/scenery, frontend/stage changes and bounded overflow trigger full redraws. All 600 final full-frame comparisons against frozen v5 pass, including 96-enemy repair pressure and 25-to-24 scenery changes. Tile/HUD/actor cache comparisons/canaries also pass. Intro is stubbed in the pixel fixture; production opening/input captures are separate.

Important timing correction: old 13 FPS included the timing-text overlay. The comparable v5 renderer without that overlay measured 17.33 FPS stationary / 16.67 moving. The v6 profiling candidate measured 37.50 / 20.77. Final production counters are in `v6_final_production_pair-benchmark.json` and `v6_final_production_motion-benchmark.json`; these use normal opening entry and identify the packaged hash. Simulation remains approximately 30 Hz. Don't claim whole-game 30 FPS or physical-calculator performance.

Resident end `0xD3C65C`; BSS end `0xD13011`, 4,039 allocator bytes remain. Keep the `0xD40000` guard. The assembly/row-pointer experiment produced an OS MEMORY error before gameplay and is excluded under `tests/experiments`; no useful performance measurement came from it. An early retained-rendering mismatch came from mail icons extending below the HUD and was fixed before the final 600-frame pass.

Next performance target is scrolling: roughly 22 FPS remains below 30. Preserve fixed sky, foreground layering, original art and simulation; don't obtain higher numbers by stripping graphics or measuring an overlay-heavy baseline. Hardware rev8/OS5.8.2.29/arTIfiCE RAM clear and full original-versus-port campaigns remain open. Root NeuroFlappy work must remain untouched; push only the separate checkout using the configured contributor identity.

Package default: `FlashGamesCE-v6-preview.zip`. Per-stage final results: `STAGE-SMOKE-v6_final-pedrofu.md`. Separate production captures cover opening/arrow input, pause→skills/details→map, stress and observed exit; their metadata distinguishes the pre-sentinel candidate where applicable. Preserve ROM/raw RAM locally.

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
