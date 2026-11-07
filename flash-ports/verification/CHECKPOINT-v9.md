# v9 Scouts memory and campaign preview, 7 November 2026

Results use CEmu OS 5.3.0.0037 at 48 MHz, with emulator batches at idle priority. No download or physical-calculator transfer took place. Physical Pedro crash investigation remains deferred; Cesium and OS 5.8 are untested.

| Program | Bytes | SHA-256 |
| --- | ---: | --- |
| SCOUTCE.8xp | 43,502 | `9ae1dad156c59bc03cd4e453affb6a85d68bcb2a2205525907522aa125248aae` |
| PEDROCE.8xp | 51,070 | `c87979b6b2fdd59901cccf2b2b2aafa7d8d1d29a0bfbddfb21ae2268354d78a9` |

Pedro, the resource banks and runtime libraries are unchanged from v8. Its validation remains in [CHECKPOINT-v7.md](CHECKPOINT-v7.md). Scouts' v8 collision/rendering baseline remains in [CHECKPOINT-v8.md](CHECKPOINT-v8.md).

## Exact optimizations

Scouts now uses the same bounded formatter already verified for Pedro. A small source wrapper includes that implementation; HAS_PRINTF=NO avoids linking nanoprintf. Scout format strings use the supported integer/string/percent vocabulary. The shared implementation remains byte-identical, SHA-256 `75c64fc49f4c8cbe1534bcdaccfe74e51c423a5bf0d2200a36b44a65e7ebaafa`.

Each enemy caches its horizontal velocity's exact `vx/60` quotient. The cache refreshes immediately before movement when vx changes. Spawn clears both fields, so an initial zero velocity has the correct zero quotient. A fast path handles facing±1 and retains multiplication for other values. No movement rule, artwork or enemy count was reduced for benchmarks.

The two new Enemy fields are derived metadata. Native comparisons check every preceding gameplay byte and separately assert that the cached quotient equals cached velocity/60. Frozen v7, uncached collision-corrected and actual-v8 physics references remain available.

| Native check | Result |
| --- | --- |
| Movement cache versus frozen v8;17 maps,16 variants,160 ticks,3 substeps | 130,560 comparisons, zero differences; velocity changes, quotient boundaries and nonstandard facing included |
| Combined caches versus uncached collision-corrected reference | 81,600 comparisons, zero differences |
| Food/pickup versus frozen v7 with the larger Enemy layout | 816 comparisons, zero differences |
| Engine/combat/jump/slope/solid-ceiling fixture | 44 assertions pass |
| Complete scenes, old nanoprintf versus new formatter, both framebuffers | 272 full-frame comparisons, zero differences; nonzero HUD/tile canaries intact |

The montage renderer/art source is unchanged from v8, whose358 comparisons and51,940 map-coordinate cases remain applicable. The combined scene fixture links both formatters under separate names, so its reference does not silently use the replacement formatter.

Some alternative native fixture layouts returned ERROR: UNDEFINED with zero counters. They are not acceptance evidence. Retained passing harnesses expose persistent phase traces in unused emulator RAM; the engine fixture uses normal GraphX startup and idles on result counters. Captured OPS/FPS bounds confirm0xD3F000 is free in these empty native-test sessions. Probes and helper binaries are not in the production package. The layout-sensitive launch failures have not been diagnosed as game or hardware defects.

## Production timing and RAM

The production hash above is measured without QA_PERF or a visual overlay. Matched7s and1s captures subtract common startup/warmup. Frame-boundary sampling adds quantization;80.5 measured ticks/s is not a claim of precise overspeed.

| Scenario | FPS | Simulation ticks/s | Requested ticks/s |
| --- | ---: | ---: | ---: |
| Quiet stage1, no enemies or early wave send | 10.83 | 80.50 | 80 |
| Stage16,29–34 natural enemies, no towers | 1.50 | 16.17 | 80 |

Stage16 uses VARS solely for entry, not a campaign unlock. v8 measured10.17 FPS in the same quiet protocol and15.83 crowded ticks/s with28–32 enemies. Crowded populations differ, so no controlled percentage speedup is inferred. The native movement comparison measures1,795,053 versus1,655,032 timer ticks for frozen v8/candidate across its16 variants; that is a component measurement, not production FPS.

Gameplay input passes220/150,80/80 and40/40ms press/release intervals after settled menu entry, with zero queue overflows. Separate paired input rates are20.0/79.17 ticks/s at requested1x/4x. All8 speed checks and17 stage-entry checks pass on the production hash. Entries do not establish completability.

| Capture | Running bytes including relocated libraries | Free RAM |
| --- | ---: | ---: |
| Crowded stage16 | 97,536 | 54,844 |
| arTIfiCE win/save/relaunch with32KB RAM filler | 97,536 | 21,982 |

The running footprint falls6,696 bytes from v8. Resident linker data ends at0xD2F32F; BSS ends at0xD13C43, leaving917 bytes in the configured C heap. Game buffers remain static; no heap allocation was added. `ram_guard.ld` remains enabled. The linked end alone excludes LibLoad's relocated code.

## Actual campaign play

Stage2 was won sequentially after the proven stage1 win on the preserved v8 production binary. Two initial rock towers at(3,16)/(7,15), then reinforcements at(9,14)/(13,13), cleared all5 waves and retained all5 food. The result earned level4,3 skill points and stage3.

`export_earned_save.py` exports SCTSV02 unchanged from the run's real descending VAT, validating its type,76-byte payload, magic and expected wins. The save stays local. Provenance records source run/program/RAM/save hashes. Subsequent runs resume that earned state rather than fabricate progress.

Stage3 was won from that save on both v8 and the combined v9 binary. Two points bought Rock Tower ranks and one bought Snow Fort. Initial rocks at(6,14)/(5,14), snow at(4,14), earned reinforcements at(3,14)/(2,14) and two upgrades cleared all9 waves, including Beasty, retaining all5 food. Stage4 unlocked; level5,1 point and344 XP persisted. Inputs, skills, win arrays, program hashes and save provenance are recorded in `scoutcamp/v9-campaign-results.json`.

The combined v9 binary separately passes stage1 loss (all5 food stolen), ENTER retry (fresh briefing/five food), and an arTIfiCE stage1 win/CLEAR/DOWN reselect/relaunch/normal stage2 entry with an unarchived32KB filler. These are actual game outcomes, not synthetic states or QA wins.

This establishes campaign progress through the first3 stages, including an earned-save continuation and an actual v9 stage3 win. It does not establish the remaining14 stages or a complete campaign. Stage4 entry exposed an existing initial-cursor bug: cx55 on a53-wide map. First LEFT clamps it to51; the initialization bound still needs fixing.

## Archive GC status

Archive-GC round-trip validation is still in progress and is not claimed here. A TI-BASIC GarbageCollect control completed and preserved the earned save. Direct native helper/chaining attempts did not pass; pre-reset captures distinguish their failures from accepted game runs. The current test runs GC through the normal OS command between native programs and checks space reclamation, every bank CRC and unchanged saved bytes. Only a completed persisted-proof check can close this item.

The local CEmu CLI gained opt-in pre-reset captures, private image save/restore and explicit named ASM/BASIC launches to support these tests. They do not change core emulation or ordinary runs without those options. Images contain ROM and remain local, as do raw RAM, earned saves, fillers and helper binaries.

## Packaging and next work

The preview contains only the two production programs,61 game-data AppVars,4 runtime libraries, notes, manifest and checksums. No ROM, raw RAM, saves, fillers, native probes or experimental builds belong in it.

Continue archive-GC verification, bound the initial cursor, play later campaign stages, and reduce crowded physics/sky/map/HUD cost. Pedro scrolling performance remains open. Physical testing stays deferred.
