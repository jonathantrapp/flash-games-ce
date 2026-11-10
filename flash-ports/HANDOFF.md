# Developer handoff, v9 memory and campaign preview, 7 November 2026

## 10 November 2026: Pedro candidate `pedrofu/bin_v9` (SHA-256 `b0b9ddf7…`, 52,977 bytes; not promoted/packaged/pushed)

Result (CEmu production-entry benchmark, `benchmark_frames.py --motion --production-entry`, v8 -> v9): scrolling/motion 26.5 -> 34.9 FPS (draw 30.9 -> 23.7 ms, sim 4.4 -> 2.6 ms, still exactly 30 steps/s); idle 50 -> 60 FPS. Caution: that FPS counts repeat draws between 30 Hz ticks, so it overstates scrolling. The honest measure is the steps-per-loop-iteration histogram (`-DPEDRO_STEPHIST`, `tests/perf/stephist.py`/`stagehist.py`): an iteration that ran 2+ steps is a dropped draw. Same instrumentation, walking left/right, v8 source -> v9: stage 1 26.8% -> 8.8% dropped (draw 33.0 -> 27.0 ms, sim 4.7 -> 2.9), stage 3 14.8% -> 5.2%, stage 15 34.0% -> 16.4%. So stage 1 is now close to but not exactly 30 FPS while scrolling, and the instrumented builds run a little slower than production. Free RAM after the sky loads rose from 5.6 KB to 7.5 KB (margin above `SKY_RAM_RESERVE` about 2.4 KB, was 0.5 KB), BSS headroom is 2,438 bytes.

Heavier stages are far from 30 FPS and are now the real problem (stage-entry walking, instrumented build): stage 2 sim 13.7 ms, stage 5 draw 62 ms/sim 27 ms, stage 7 draw 68/sim 36, stage 9 sim 26, stage 10 draw 100 (arena), stage 13 sim 27. Cycle profiles (no-inline build): stage 9 spends 8% in the `ishrs` (variable shift) helper (call sites in `move_body`, `enemy_update`, `draw_game`, `prop_update`, `restore_region`), 8% in `idvrmu` (24-bit divide/modulo; nearly all of it inside libc `random`, so some game code calls `rand()` far more often than the obvious AI sites in enemies.c, which is worth finding), 4% in `imulu` (`enemy_update`, `tile_at`, `more`, `cached_sprite`, `draw_sprite`); stage 2 is similar. Stage 5 spends 44% inside GraphX sprite drawing. Mechanical next steps: replace `/16`-style divides and shifts in the physics with exact-semantics inline forms (the -Oz build calls helpers), find the `rand()` caller, and cut per-enemy draw cost.

What changed in v9 (all pixel/behaviour preserving):
- Sky: scrolling frames repaint only from the higher of this buffer's old content top and the new tile/scenery top (`top_old`, `content_top`, `row_any`), plus last frame's damage rects that lie above that top (`draw_game`, render.c). Reuse frames keep `top_old` valid. Rows above are untouched sky. `pedro_render_stats[3]` counts frames that skipped rows. The scene is clipped to rows >= 22 so the HUD strip is never overdrawn.
- HUD: a buffer whose own strip signature still matches needs no copy at all (v8 copied 7 KB every frame); mail icons spilling below row 22 are drawn clipped; "Lv"/"+pts" strings are only reformatted when their value changes.
- Cell loops: the tile, pickup and decor passes in `draw_game` skipped empty cells at about 200 cycles each; `skip_zero`/`skip_zero2` now jump empty runs three bytes at a time (largest single win, about 3 ms).
- Multiplies: pointer iteration replaces per-iteration array scaling in `projectile_update` (about 1 ms of sim), `damage()`, the render loops and the HUD boss scan; `cached_tile` uses a byte slot table plus a 4-byte-stride pointer table instead of an array of 3-byte pointers.
- RAM: `notice_images` moved from .data (resident, counted against the sky's free-RAM test) to BSS; HUD sprites are packed with `gfx_ConvertToNewRLETSprite` (about 4.2 KB instead of 6.7 KB reserved; 4,800-byte pool). `SKY_RAM_RESERVE` is now `#ifndef`-guarded (profile builds pass `-DSKY_RAM_RESERVE=3000` when code growth would lose the sky) but production still uses 5120.

Verification on this build: host tests (profile 29,678 checks, combat 20/20, data, runtime-safety 41/41, bank validation, small format, skill descriptions, sky runtime) pass; `check_collision` shows its documented 4,084 boundary differences unchanged; native render-cache, text, rlet, format, skill UI pass; scene comparison against frozen v5 600/600 in both flash and cache modes; new `check_native_sky_track.py` (continuous walking/jumping/scrolling trajectories on alternating buffers, tracked frames hashed against forced full redraws; 4 final runs, 1,536 frame pairs, 0 mismatches; mutation check with the old-rect repaint disabled produced 178 mismatches, so the test can fail); 15/15 stage entries; 8 fuzz soaks of 60 s; in-game HUD check 2,545 frames 0 mismatches (boss bar and HP-change frames still not deliberately exercised). Logs are in `verification/p9_final`. Three test harness fixes: declarations the tests patch (`notice_images`, `hud_storage`) changed, and the flash-mode scene fixture must now be zx7-compressed (stored uncompressed it no longer launches: ERROR: UNDEFINED, zero counters, which is not evidence of anything).

Tried and rejected: per-row dirty flags for the sky (bookkeeping cost as much as it saved), skipping sky under opaque-covered cells (many small partial-width calls, 3 ms slower), a 24-bit-word tile blit in C (70% slower than GraphX), inlining the first-cell test before `skip_zero` and a pointer loop in `prop_update` (logically neutral but 1.5-2 ms slower in CEmu, so benchmark results are sensitive to code layout by that much; treat differences under about 2 ms as noise and always confirm with the unmodified production build). Profiling macros perturb timing too: `PEDRO_PROFILE`/`PEDRO_PATHSTAT` builds ran 10% slower than production.

Not done: 32 KB-filler save round trip and archive-GC proof (still required before promotion), packaging, any push, physical calculator. Tools added in `pedrofu/tests/perf/`: `prof_phases.py` (draw/HUD phase sums for scrolling frames), `pathstat.py`, `stephist.py`, `stagehist.py`, `profnow.py` (no-inline cycle profile plus hot windows), `runbatch.ps1` (parallel test runner; keep concurrency near 6 because native test hash timeouts are wall-clock). Build the sources in a snapshot copy when editing during a test batch. `cemu_profile.py` call-site trick: executions of a `call __imulu` instruction = its histogram cycles / call cost, which ranks call sites without a call stack.

## 9 November, later: Pedro candidate `pedrofu/bin_v8` (SHA-256 `d40147cb…`, 51,652 bytes; not promoted/packaged/pushed)

CEmu production-entry benchmark: idle 40 -> 50 FPS; scrolling/motion 21.2 -> 26.5 FPS (draw 39 -> 31 ms, sim 6.2 -> 4.4 ms). Still not 30 while scrolling: about 2 ms short. Passing: 600 native full-frame comparisons, render-cache, sky-runtime lifecycle, runtime-safety 41/41, 15/15 stage entries, and an in-game HUD check build (`-DPEDRO_HUDCHECK`: 765 frames drawn with and without strip retention across three scenarios, 0 mismatches; boss bar and HP-change frames were not specifically exercised).

Source changes: row-wise solid-cache compare; good-item scan by row pointer; flat sky rows drawn as one memset block; `prop_update` skips behaviour-less props; back layer skipped under an opaque solid tile; `tile_at` caches the last row multiply (no measurable gain); retained HUD top strip (`draw_hud_impl` in render.c: when hearts/mail/fury/boss signature matches the other buffer's last frame, rows 0-21 are copied from it and only the spilling mail icons are redrawn; `invalidate_scene_cache` clears the retention flag). `SKY_RAM_RESERVE` lowered 6144 -> 5120 because the retained HUD adds about 400 bytes of code. This matters: the 37,679-byte sky AppVar is allocated only when free RAM >= SKY_ROW_BYTES + reserve + 32, and without it the game falls to 15-21 FPS. After load there must be about 5.6 KB free (`ram_report.py` on a dump from a 9 s run); a changed reserve or any code growth can silently lose the sky, so re-check that before trusting a benchmark. Save/archive behaviour with the smaller reserve is covered only by runtime-safety 41/41, not the 32 KB-filler round trip; run that before promotion.

Ideas for the last 2 ms: remaining HUD (mail icons, XP bar and two text strings are redrawn every frame, about 2.5 ms), clean-sky-rows skip (about 2 ms but needs about 2.8 KB code, which needs equal savings elsewhere), sim (4.4 ms; imulu is 5.6% of all cycles, call sites unidentified). Tried and rejected: gradient-sky memcpy grouping (slower), noinline helper loops (slower), FAST_RENDER (blank screen), per-cell sky repair. Tools: `pedrofu/tests/cemu_profile.py` (build recipe: `make BINDIR=bin_p8prof OBJDIR=obj_p8prof CFLAGS="-Wall -Wextra -Oz -std=c11 -DSKY_FLASH_ROWS -DPEDRO_PROFILE"`, copy the PDB/PDU banks in, delete the obj folder between builds).

## 9 November 2026: Scouts frame-rate work in progress (not promoted, not pushed)

Candidate `scoutcamp/bin_v10hybrid` (SHA-256 `70008d21…`, built from current src). Changes:
- Retained background: repair recorded rectangles and redraw each touched tile cell once.
- Retained HUD.
- Indexed sky repair.
- Physics kept out of `main()` and rewritten without shift helpers.
- 30 FPS frame cap.

CEmu 1x FPS, v9 vs earlier candidate builds:

| Scene | v9 FPS | Candidate FPS |
|---|---|---|
| Quiet stage 1 | 12 | 30.0 (capped) |
| Stage 16 crowd | 2.8 | 13.3 |
| Mid-wave stages 1/5/9/13/17 | 8.5/9.0/5.8/6.8/7.5 | 25.3/27.8/18.5/21.2/25.5 |

These FPS figures come from the builds before the final RAM trim; rerun the benchmarks on 70008d21.

Verified on 70008d21:
- `check_retained_render.py`: all 17 stages, 0 mismatches.
- Native physics: 81,600/81,600.
- Scene render: 272 scenes, after fixing the split-fixture transfer.
- 17/17 stage entries.

On the previous build, input timing, speed controls, movement, food, route and host rules passed.

RESOLVED later on 9 November: `check_native_art_render.py` failure was a test-harness bug, not the game. The extra `delay|1500` before `action|launch` made the autotester launch fail (ERROR: UNDEFINED, zero counters). Removed it; 358/358 comparisons, 0 mismatches, 0 guard hits on 70008d21.

Re-measured on 70008d21 (CEmu 1x, benchmarks run alone): quiet stage 1 30.0 FPS / 20.0 ticks; stage 16 crowd 13.67 FPS / 19.83 ticks (`verification/scoutcamp/v10h_*-benchmark.json`). RAM (`ram_report.py` on the stage-16 dump): 38,462 bytes free crowded (v9: 54,844; the 31.7 KB figure was stale). The 32 KB-filler save round trip leaves about 6 KB, so it is untested and tight; run it before promotion.

## Later on 9 November: Scouts candidate `scoutcamp/bin_v10m` (SHA-256 `0b737d29…98eb8` after a rebuild (the measured build was `6773b591…ef9db`; same source, container timestamp differs), 49,272 bytes)

Changes over 70008d21 (source is current `src/`): HUD text is only reformatted when a change signature differs (`hudCompute`, `statusSerial` in `say`); one repair rectangle per enemy for sprite, health bar and status pips; per-row touched-cell spans instead of scanning the 15x21 grid; sky repair skipped when every touched cell holds an opaque tile.

CEmu 1x, benchmarks alone: quiet stage 1 29.8 FPS; mid-wave stages 5/9/13/17 = 29.3/21.0/24.8/27.2; crowded stage 16 = 14.8 (was 13.7), always 20.0 ticks/s. Verified: retained-vs-full-redraw pixel check on all 17 stages (0 mismatches), input timing, speed controls and 17/17 stage entries pass. Free RAM crowded 37,064 bytes. Not re-run on this build: native physics/food/scene suites (those files are untouched), 32 KB-filler save round trip, archive-GC.

Why stage 16 stays below 30: the game logic runs at HZ=20 (matching the original), and enemy physics alone costs about 40% of CPU in a crowd (physicsEnemy 21%, multiply/divide helpers 9%, stepFood 3%, surfaceF 2%). Render is about 1.3M cycles per frame. Reaching 20 drawn frames per tick in crowds needs physics or render about 25% cheaper; 30 distinct frames is not possible since nothing moves between ticks. Next steps: per-address profile of physicsEnemy (use the -fno-inline build recipe: `make BINDIR=bin_v10p2 OBJDIR=obj_v10p2 LTO=NO CFLAGS="-Wall -Wextra -Oz -std=c11 -fno-inline -fno-inline-functions -fno-inline-functions-called-once"`, copy the SCA banks in, then `cemu_profile.py v10h_s16_7 --base v10h_s16_1`), and avoiding the full 16x16 tile redraw by clipping to the dirty rectangle. Pedro was not changed: production stationary 37-40 FPS, scrolling/motion 19.5-21.8 FPS (`v7_*_production_*-benchmark.json`); scrolling remains the target.

OPEN:
- Not 30 FPS during waves. Enemy motion is still 20 Hz (sim rate).
- Not promoted/packaged/pushed. Before promotion: 32 KB-filler save round trip, archive-GC proof, and check input/speed controls on 70008d21 (last run was the previous build).

Tools:
- `tests/cemu_profile.py`: cycle profiler. Needs `build/build_cemu_prof.py` and the `CEMU_PROFILE` hook in `local-tools/cemu-source/core/cpu.c`; both are local.
- `tests/record_build.py`.
- `benchmark_crowded.py --plus 0` measures at 1x.
- Run benchmarks alone: host load distorts their timing.

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

Also tried and reverted on 9 November: per-row cell-run sky repair instead of per-rectangle repair (stage 16 fell from 14.8 to 14.2 FPS). User note: the original Scouts targeted 30 FPS (unverified by me; the extracted rules run logic at HZ=20). Crowded stage 16 would need about half the current render cost plus cheaper physics to hold 30.
