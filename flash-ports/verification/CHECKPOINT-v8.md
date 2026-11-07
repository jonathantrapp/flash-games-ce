# v8 Scouts collision, rendering and campaign milestone, 7 November 2026

All results use the local CEmu OS 5.3.0.0037 ROM at 48 MHz. Emulator batches run at idle priority. No download or physical-calculator transfer took place. The user deferred the physical Pedro crash investigation; Cesium and OS 5.8 remain untested.

| Program | Bytes | SHA-256 |
| --- | ---: | --- |
| SCOUTCE.8xp | 47,779 | `245f216fc094e5188fa44806c1ecf46a77b32672e823efb05943590a73e33322` |
| PEDROCE.8xp | 51,070 | `c87979b6b2fdd59901cccf2b2b2aafa7d8d1d29a0bfbddfb21ae2268354d78a9` |

Pedro and both games' data banks/libraries are unchanged from v7. Pedro's RAM/cache, formatter and performance evidence remains in [CHECKPOINT-v7.md](CHECKPOINT-v7.md). This report adds Scouts evidence.

## Stage-one collision blocker

The v7 no-tower run could not lose because enemies failed to reach camp. A native single-Lumpy regression using the real stage-one map reproduced a turn at x496 without any food pickup after 2,500 ticks. Skipping ceiling collisions for floor-only slope tiles moved the blockage to x717. Accepting floor-slope contact at the inclusive bottom edge completed the food round trip: maximum x809, pickup observed, one escape and four food remaining after 1,515 ticks.

The recovered `TileSet_Grave.as` marks tiles14/18 as floor slopes; `FlxTilemapExt.as` gives them FLOOR and a side flag, never CEILING. Its floor-slope solver accepts feet through the tile's bottom edge, including rising motion. The port now follows those two rules. Existing center-based slope sampling remains; this is not a claim of complete AS3 collision equivalence on every map.

The frozen v7 physics remains under `scoutcamp/tests/reference/`. A second, uncached reference adds only these collision corrections, retaining coordinate divisions. That reference isolates the coordinate-cache optimization from the intentional v7 behavior change. The focused route and ceiling/slope assertions validate the correction separately.

## Optimizations and exact pixels

Enemy portal coordinates are cached at spawn; camp coordinates at stage entry. Food pickup caches each food position and rejects enemies outside the16-pixel circle's axis bounds before multiplying. Slot order and the original strict squared-distance test remain intact. Tile rendering checks the existing RAM cache before generic art metadata, uses opaque copies only for fully opaque tiles, and advances map row pointers/screen coordinates. The original HUD is cached as RLET. Artwork, layers, enemy counts and gameplay rules were not reduced for timing.

| Native check | Result |
| --- | --- |
| Cached versus uncached corrected physics:17 maps,10 variants,160 ticks,3 substeps | 81,600 comparisons, zero differences |
| Food/pickup versus frozen v7:17 maps, sparse/full slots and boundaries | 816 comparisons, zero differences |
| Engine/combat/jumps/floor slopes/solid ceilings | 44 assertions pass |
| Whole scenes:17 maps,8 states, both framebuffer addresses | 272 full-frame comparisons, zero differences; nonzero HUD/tile canaries intact |
| Sky/tile/HUD montages, clipping and edges, both framebuffers | 358 comparisons, zero differences |
| Map-loop coordinate enumeration | 51,940 cases match |

Fixtures are uncompressed and unarchived, with runtime libraries transferred alongside them. Some alternative fixture layouts returned OS ERROR: UNDEFINED with zero result counters, including the combined scene/component experiment. Those artifacts are not acceptance evidence, and their launch failure has not been diagnosed. The retained separate suites pass; both renderer fixtures use LTO=NO. Component guards retain their original values; the separate whole-scene suite uses nonzero0xA5 guards. Synthetic raw-sprite oracle timing is not a production FPS comparison.

## Production timing and RAM

Benchmarks use the production program above without a visual overlay or QA_PERF. Two matched runs measure1s and7s intervals; their difference excludes common startup and warmup. Frame/tick counters are read from RAM after freezing simulation.

| Scenario | FPS | Simulation ticks/s | Requested ticks/s |
| --- | ---: | ---: | ---: |
| Quiet stage1, no enemies or early wave send | 10.17 | 80.00 | 80 |
| Stage16 first wave,28–32 natural enemies, no towers | 1.33 | 15.83 | 80 |

The crowded stage uses VARS solely to open that map. It is not campaign-unlock evidence. The earlier v7 crowded sample reached14.5 ticks/s with 25–29 enemies; the populations differ, so this is not a controlled percentage speedup. Separate instrumented captures still identify enemy physics as the main cost: about44.4ms/update at this crowd, food4.17ms, and a last-frame sky/map/actors/effects/HUD split of32/75/10/0/28ms. These counters add overhead and belong to a different diagnostic binary.

The input matrix passes220/150,80/80 and40/40ms gameplay press/release intervals after settled menu entry, with zero queue overflows. Quiet paired tick rates are19.83 at1x and79.33 at requested4x in that protocol. All8 speed-control checks pass, including exact freeze/restore settings. All17 stage-entry checks pass on the production hash; these entries do not establish completability.

`ram_report.py` reports104,232 running bytes including relocated libraries and48,148 bytes free in the crowded capture. The saved-unlock arTIfiCE run has48,070 bytes free, or15,286 with an unarchived32,768-byte filler. `___data_high=0xD30D57` and BSS ends at0xD1388C; `ram_guard.ld` remains enabled. The program-end linker symbol alone excludes LibLoad's relocated library code.

## Actual stage-one play and saved unlock

These runs use normal stage selection, natural spawns and legal inputs, with no QA unlock, modified skills, injected save or synthetic result.

| Run | Observed outcome |
| --- | --- |
| No towers, early first wave, requested4x,125s wait | LOST; all 5 food stolen |
| Same loss followed by ENTER | Fresh stage-one briefing;5 food, zero enemies/tick, speed reset1x |
| Two rock towers purchased from the starting$120, requested4x,300s wait | WON; all 6 waves cleared,5 food retained, level3,2 skill points, stage2 unlocked |
| arTIfiCE win, CLEAR exit, DOWN reselect, relaunch, normal map RIGHT/ENTER | Stage-two briefing, saved stage-one win, unlocked=2 |
| Same complete arTIfiCE round trip with 32KB RAM filler | Same saved unlock;15,286 bytes free |

The winning input after game launch is:

```
enter wait:500 enter wait:500 enter wait:300 alpha 2nd
hold:right:80 hold:right:80 hold:right:80 2nd +*9 alpha wait:300000
```

Use500ms game taps and150ms release intervals. The first tower is at the starting cursor; three short right taps place the second. The save/relaunch suffix is `clear wait:2000 down enter wait:3000 enter wait:500 right enter wait:1000`. Launcher menus use220ms taps. DOWN after exit is essential: arTIfiCE resets to B, which clears RAM.

`scoutcamp/v8-campaign-results.json` records diagnostic bytes, wins/unlocked fields, free RAM, production hash and exact inputs. This proves stage-one win/loss/retry and a saved stage-two unlock under RAM pressure. It does not prove a full campaign, later-stage wins, archive garbage collection or physical stability.

## Packaging and remaining work

The v8 preview contains exactly two production programs,61 game-data AppVars,4 runtime libraries, notes, manifest and checksums. It excludes ROM, raw RAM, saves, fillers, diagnostic and experimental builds. v7 remains available separately.

Continue with stage-two and later real campaign play, explicit archive-GC/save round trips, crowded enemy-physics cost and sky/map/HUD rendering, then Pedro scrolling performance. The physical crash work remains deferred at the user's request.
