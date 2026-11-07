# v7 work in progress, 6 November 2026 (evening session)

Status: **uncommitted, unpackaged work in `flash-ports/`.** The pushed repository is still v6 (`eb688b5`). Nothing here was tested on a physical calculator. All emulator results use CEmu with the local OS 5.3.0.0037 ROM at 48 MHz.

## 1. Pedro physical crash: what was learned

The report is a freeze or RAM clear on TI-84 Plus CE revision 8, OS 5.8.2.29, launched through arTIfiCE, with arrow input after the aerial-kick tip. It was made against the **v2 build the user downloaded**: `C:\Users\jonat\Downloads\FlashGamesCE-v2.zip`, PEDROCE 57,515 bytes, SHA-256 `a0317ea6…ff39`.

### New tooling

- **`flash-ports/launcher_scenario.py`** drives CEmu through the real launcher path: APPS → Cabri Jr → File/Open → ARTIFICE → arTIfiCE shell → program.
  - It uses `ARTIFICE.8xv` from the user's own backup (`backups/2026-10-30-before-first-transfer/`). Cabri Jr 5.0.0.0089 is already installed in the ROM image; pass `--rom-cabri`, because sending the 100 KB `.8ek` alongside the game overruns the autotester's USB timeout.
  - Other options:
    - `--user-libs`: use the backup's older CE libraries.
    - `--pkg-dir DIR`: test a specific package.
    - `--direct`: home-screen control run.
    - `--name`: program-name override.
    - `--extra`: additional files, such as RAM fillers.
  - The token `GAME` separates launcher navigation (always 220 ms taps) from game input (`--tap`).
  - Debug mode writes `native-ram.bin` and `screen.png`.
- **`flash-ports/ram_report.py`** reports `asm_prgm_size`, FPS/OPS free RAM and VAT size from a RAM dump.
- **`pedrofu/tests/stack_depth.py`** gives a static worst-case stack estimate from `obj*/lto.s`: about 1.1 KB from `main`, excluding library internals. The deepest path runs through `draw_frontend` (580-byte frame).
- **`flash-ports/launcher-probe/`** holds three tiny C programs (draw / create AppVar / create+archive) for isolating launcher behaviour.
- **`flash-ports/verification/fillers/FILL*.8xv`** are RAM (unarchived) filler AppVars for simulating a full calculator.

### Results (emulator only)

| Scenario | Result |
| --- | --- |
| User's exact v2 + package libs via arTIfiCE, through the kick tip with arrows (`art_userv2_kick`) | Runs; tip shown, no crash |
| v6 via arTIfiCE, arrow tutorial to Yak dialogue (`art_arrows`) | Runs |
| v2/v6 play → CLEAR → back to arTIfiCE shell (`art_v2_exit`, `art_v6_exit`) | Clean return |
| v6 relaunch from shell after exit, cursor moved back to PEDROCE (`art_v6_relaunch`) | Works; save loads, map shown |
| v6 with RAM fillers leaving 185/135/75/35 bytes free, arrow tutorial (`art_v6_fill*_play`) | Runs |
| CLEAR exit with 35 bytes free (`art_v6_fill800_exit`) | Clean; `PDPROG2` VAT entry present |
| User's old libs (FILEIOC v7, GRAPHX v12) (`art_userv2_userlibs`) | LibLoad "Library Version" error; dismissing returns to the shell cleanly |

**Artifacts to avoid (they cost time this session):**

- After a program returns, the arTIfiCE shell's cursor resets to the first entry, `B`. `B` is a program in the ROM image, and **running `B` clears RAM by itself**. Every apparent "relaunch clears RAM" result was actually `B`.
- Long (500 ms) taps in Cabri Jr menus auto-repeat and pick wrong items, producing fake "aborted to Cabri" results.
- The autotester `key:` command does not navigate these menus.

**Not reproduced:** no crash on OS 5.3 through arTIfiCE. **Still untested:**

- OS 5.8.2.29 itself (no ROM available).
- The **Cesium** leg. The user's backup contains `Cesium.8ek`, and arTIfiCE auto-launches Cesium when it is installed, so the user probably launched via Cesium. Cesium can't be sent over USB because it is built on-calculator; testing needs the Cesium installer `.8xp`, which would have to be downloaded with permission.
- Real hardware.

### Real defect found: RAM headroom

During Pedro gameplay, `asm_prgm_size` is **151,597 bytes**: the program plus LibLoad-relocated libraries, which sit in RAM after `___data_high`. Free RAM is **~837–851 bytes on an otherwise empty emulator**. Every variable on the calculator, archived or not, costs VAT RAM. The user's backup (122 files plus both games) would need roughly 5–6 KB more, so v6 would likely show **ERR:MEMORY at launch** on their calculator. Dismissing that error is graceful in the emulator.

The old note "14,756 bytes spare before 0xD40000" ignored the relocated libraries and the VAT; it is not free RAM.

## 2. Pedro code changes (in `pedrofu/`, uncommitted)

- **Title label** changed from stale "v3 checkpoint" to "v7 preview" (`frontend.c`).
- **Hardware diagnostic build** (`make HWDIAG=YES` → program `PEDRODG`): `src/hwdiag.h` and `src/hwdiag.c`, plus hooks in `main.c` and `profile.c`.
  - It paints phase blocks directly onto the visible LCD buffer in the top-right corner, so a photo of a frozen screen identifies the phase and subsystem.
  - It shows free RAM, frame count and measured stack depth, and stops on a readable screen if the stack nears the 4 KB bottom.
  - Production compiles every hook to nothing: the production v7 build differs from v6 only by the label.
  - **The diagnostic build currently fails to launch (ERR:MEMORY) because of the headroom problem above**, so RAM must be freed first.
- **Sky-from-flash option** (`make SKY_FLASH=YES`): draws the exact sky rows directly from the existing archived `PDU20`/`PDU21` banks instead of the 37,679-byte resident table. `build_row_sky.py` now wraps the table in `#ifndef SKY_FLASH_ROWS`.
  - Resident end moves from 0xD3C658 to **0xD33208 (−37,968 bytes)**.
  - Benchmarks (`verification/pedrofu/v7_*-benchmark.json`, `v7sky_*`): v7 40.0 FPS stationary / 21.8 moving; sky-from-flash 37.5 / 19.4 (+5.4 ms draw per frame when scrolling).
  - It is **not the default**. Planned design: keep it in the binary, and at startup copy the rows into a temporary RAM AppVar only when `os_MemChk` shows room (≈38 KB + margin). Refresh the pointer after every `profile_save`, because creating or growing variables can move RAM data. Fall back to flash otherwise and delete the temporary AppVar at exit.
- Planned and not started: replace nanoprintf (`_npf_vpprintf` 6 KB plus 64-bit helpers) with a small formatter covering `%d %02d %s` (and `%u %X %lu` for diagnostic builds), verified against host `snprintf`.

Builds present: `bin_v7` (production + label), `bin_v7diag` (PEDRODG), `bin_v7sky`. The `bin/` folder is still v6.

## 3. Scouts 4× speed: fixed in the emulator scene tested

- **Root cause** was found with new per-subsystem counters (`SIM_MARK` in `combat.h`, perf builds only; the overlay text is now behind `QA_OVERLAY`).
  - On stage 1 before any wave, `update()` cost ~13 ms per tick. Most of it was loops scanning all 160 enemy and 96 bullet slots.
  - Under `-Oz` each inactive-slot check costs ~400 cycles (an `__imulu` by `sizeof(Enemy)` plus frame shuffling). The food scan alone took 850 ms per 6 s.
- **Fix:** `enemyTop`/`bulletTop` high-water marks.
  - Set at spawn (the only activation paths), reset by the stage `memset`, and shrunk only at the end of `update()`.
  - All loops over active objects stop at the mark; free-slot searches still scan every slot. Iteration order and rules are unchanged.
- **Evidence:**
  - Native engine fixture: all **37 cases pass** (`tests/native-runs/SCENG/log-v7.txt`). The fixture's reset helper now sets full marks because its cases activate slots directly, which the game never does.
  - Production smoke `v7_smoke` passes.
  - Paired-interval rate (`scoutcamp/tests/v7-rate-results.json`): **4× = 80.33 ticks/s (v5 44.83), 1× = 19.83**.
  - Note: the fixture must be built `COMPRESSED=NO ARCHIVED=NO` and sent with the four libraries; `run_native_test.py` sends it alone, and that now fails with ERR:UNDEFINED. Use `tests/native-runs/SCENG/test_libs.json` as the working config.
- **Not yet done:**
  - Rerun `check_input_timing.py` and `check_speed_controls.py`.
  - Rerun the 17-stage entry matrix (`verify_stages.py`).
  - Measure crowded late-game 4×.
  - Scouts renders only **~6 FPS** in that stage-1 scene (sky 24 ms, map 43 ms, HUD 28 ms per frame). That's a large separate optimisation target.

## Not done this session

Campaign playthroughs, save/archive-pressure round trips, Pedro scrolling 30 FPS, original-runtime comparisons, packaging, repository sync/commit/push.
