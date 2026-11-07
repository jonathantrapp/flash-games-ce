# v7 RAM and input milestone, 6 November 2026

This preview reduces Pedro's launch footprint and validates Scouts' high-water marks. All results below come from the local CEmu OS 5.3.0.0037 ROM at 48 MHz, with emulator processes at idle priority. No physical-calculator transfer or download took place. The user deferred the physical-crash investigation; Cesium and OS 5.8 remain untested.

| Program | Bytes | SHA-256 |
| --- | ---: | --- |
| PEDROCE.8xp | 51,070 | `c87979b6b2fdd59901cccf2b2b2aafa7d8d1d29a0bfbddfb21ae2268354d78a9` |
| SCOUTCE.8xp | 47,348 | `2447f78a30e103a038f9555400399196166d99a7ce7805d79f1fcf1c8c64b9e3` |

## Pedro: flash sky with an optional RAM cache

`SKY_FLASH=YES` is now the default. The production executable omits the 37,679-byte resident pixel stream and draws the original archived PDU20/PDU21 rows. At startup, it discards a leftover `PDSKYTMP` AppVar and checks `os_MemChk`. When at least 43,855 bytes are available, it reconstructs the exact overlapping row stream in a temporary, unarchived AppVar. The check reserves 6 KB plus allocation overhead. Fuller calculators retain the flash path.

`profile_save` reopens the temporary AppVar and refreshes its pointer after file I/O, because RAM variables can move. Exit deletes the cache before archiving the profile. The cache contains no progression data. The linker guard remains enabled; `___data_high` is `0xD31B8E`. That address alone does not report free RAM: LibLoad relocates libraries after the program.

| Production capture | Sky path | Free RAM, OPS minus FPS |
| --- | --- | ---: |
| Normal opening, stationary gameplay | RAM cache | 6,867 bytes |
| arTIfiCE gameplay | RAM cache | 6,881 bytes |
| arTIfiCE with an unarchived 8 KB filler | Flash | 36,368 bytes |
| arTIfiCE with a stale, zero-filled 37,679-byte cache | Recreated RAM cache | 6,881 bytes |
| Save, exit, reselect with Down, relaunch with 8 KB filler | Flash; profile/map loaded | 36,354 bytes |

The running program plus relocated libraries occupies 107,871 bytes, down from the earlier 151,597-byte measurement. See `pedrofu/v7-ram-results.json` and the associated launcher logs/metadata. `ram_report.py` now distinguishes the gap to `progPtr` from total VAT usage; the old label overstated what that pointer establishes.

The small formatter replaces nanoprintf and supports the game's closed vocabulary: integer/string output, zero padding, percent signs, diagnostic hex and unsigned long counters. The production map contains no nanoprintf formatter. Host tests passed 9,312 comparisons with system snprintf, including truncation and guards. A native GraphX-context fixture passed 640 checks on the CE's 24-bit-int/32-bit-long ABI. All 18,090 generated skill-description cases also pass using the new formatter directly, with bounded buffers; 210 cases retain the previously accepted Flash roundoff tolerance.

The cache lifecycle host fixture reconstructs all 76,800 sky pixels and tests allocation thresholds, open/resize failures, moved RAM, archived/wrong-size cache rejection, stale copies and cleanup. Native flash rendering passes 600 whole-frame comparisons against frozen v5 with intact canaries, including retained frames and overflow fallbacks. A smaller native fixture passes another 600 cache-versus-flash full-redraw comparisons. It omits the duplicate frozen renderer to leave enough RAM for the optional cache; its result does not establish retained-frame reuse. Tile/HUD/actor comparisons and guards pass too. Reports live under `pedrofu/tests/{scene-native-flash,scene-native,render-native,format-native}/`.

| Normal-opening benchmark, no overlay | Stationary FPS | Moving/jumping FPS | Simulation steps/sec |
| --- | ---: | ---: | ---: |
| Previous v7 resident sky | 40.0 | 21.8 | about 30 |
| Packaged v7, optional cache active | 40.0 | 21.15 | 30.0 |
| Same packaged binary, 8 KB filler selects flash | 37.0 | 19.49 | about 30 |

These use `benchmark_frames.py --production-entry`, paired intervals and the packaged hash. The flash measurements pass `--extra FILL8192.8xv`. No artwork, layers or gameplay rules were removed. The RAM improvement trades some scrolling throughput for headroom; this does not meet sustained 30 FPS scrolling.

## Scouts: quiet-stage speed improves; crowded speed does not

`enemyTop` and `bulletTop` bound active-object scans without changing slot order or free-slot searches. Stage initialization clears the marks, activation raises them, and update shrinks trailing inactive slots. The native engine fixture's 37 assertions pass; its synthetic reset sets full marks because those cases activate slots directly. The runner now transfers the four libraries with standalone fixtures.

The production controls matrix passes 220/150, 80/80 and 40/40 ms hold/release sequences, with zero queue overflows. Entry uses ordinary 500 ms taps and 300 ms waits first. Earlier short menu-entry taps sometimes left the briefing open, so this establishes gameplay control timing, not loading/menu latency. All eight speed-control assertions pass, including exact restoration of 3 and 12 thirds. `input-timing-results.json` measures 19.83 ticks/sec at 1x and 80.33 at requested 4x in the quiet stage-one interval.

The crowded late-stage result is **14.5 ticks/sec at requested 4x**, far below the 80 target. Stage 16's natural first wave grows from 25 to 29 enemies in matched 1s/7s intervals after a 20s warmup. No towers or altered rules are involved; QA only opens the stage. Stage 17's single Hungry measured 60 ticks/sec in a separate one-second difference. See `scoutcamp/v7-crowded-campaign-results.json` for snapshots and limitations.

Opaque-tile copies, a resident HUD cache and a cheaper map loop remain local experiments, outside production. Their pixel fixture failed before a result: direct resource/header lookup succeeded, but the fixture's sprite-accessor path returned to an OS error. Alternative metadata lookup/LTO configurations did not resolve it. This is not evidence of a hardware defect or a successful rendering optimization. The validated package retains the existing renderer.

## Stage entries and unfinished play checks

All 15 Pedro and 17 Scouts entries pass on the packaged hashes: `STAGE-SMOKE-v7_final-pedrofu-scoutcamp.md`. These are short QA entry checks, not campaigns or unlock proofs.

Scouts' attempted no-tower loss/retry checks did not reach a loss. After 150 seconds of emulated wall time, the stage-one snapshot remains PLAY at tick 3,212 with 41 enemies and all five food items. The earlier attempted retry pressed Enter while still in PLAY and built a tower. The expected-loss/retry assertions failed; neither counts as a passed lifecycle check. Wins, genuine retries, unlocks, original-runtime comparisons and archive-GC save round trips remain open.

The ZIP includes only the two production programs, 61 game-data AppVars, four libraries, instructions, a manifest and checksums. It excludes ROMs, raw RAM, saves, fillers, diagnostics and experimental builds. Packaging checks TI file checksums/names, bank sets, resident guards, ZIP integrity and per-file hashes.
