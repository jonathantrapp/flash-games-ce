# Flash games adapted for TI-84 Plus CE

These are native C rebuilds of the two supplied SWFs, written from the AS3 recovered with JPEXS. Both are works in progress: see [PARITY-AUDIT.md](PARITY-AUDIT.md) for what is verified and what is not, and each game's notes for controls and known gaps.

The current deliverable is the **v8 Scouts route and rendering preview**. Read [the changes](CONTINUATION-v8-2026-11-07.md) and [verification](verification/CHECKPOINT-v8.md) before installing. Scouts now verifies a real stage-one win/loss/retry and saved stage-two unlock, including with 32KB RAM pressure. Exact-pixel rendering measures 10.17 FPS in quiet stage one; crowded stage16 remains slow at1.33 FPS/15.83 simulation ticks per second. Pedro is unchanged from v7: optional sky cache, about 6.9KB free with it and36.4KB with an 8 KB filler selecting flash,40.0/21.15 cached stationary/moving FPS. CEmu OS5.3 results do not establish physical stability, complete campaigns or archive-GC coverage.

| Supplied file | Original game | Calculator program |
| --- | --- | --- |
| scoutcamp_unlocked.swf | Scouts vs Aliens | SCOUTCE (+ 33 `SCAxx` banks) |
| pedrofu_unlocked.swf | Pedro Kicks Back | PEDROCE (+ 19 `PDBxx` banks, `PDCOLOR`, `PDTILE0/1`, six `PDUxx` images) |

The original games, artwork and characters were created by Hamumu Software (2012); see [CREDITS.md](CREDITS.md). This is an unofficial fan project. This folder contains the calculator implementation and local recovery work. The Flash files themselves cannot run on the calculator.

## Install

1. Extract `FlashGamesCE-v7-preview.zip` on your computer. Check `SHA256SUMS.txt` and the manifest. (To assemble it yourself from compiled programs, run `python flash-ports/package.py` from the workspace root.)
2. Connect the TI-84 Plus CE using USB and open TI Connect CE's Calculator Explorer.
3. Send the `.8xp` and `.8xv` files from the extracted package. Keep the `.8xv` files in archive. Each game's asset AppVars must accompany its program.
4. Launch `SCOUTCE` or `PEDROCE` through Cesium using your existing native-game setup.

When updating, replace both programs and **all** supplied game data files. The versioned banks deliberately reject mixed old/new resources. Preserve your other programs and the save files `PDPROG2` and `SCTSV02`.

Pedro's unarchived `PDSKYTMP` is a disposable cache, not a save. It deletes and rebuilds a leftover copy at startup, then deletes it on clean exit. The physical-crash investigation is deferred; OS 5.8 and Cesium remain untested in this workspace.

If native games are not set up on your calculator, follow the current [arTIfiCE instructions](https://yvantt.github.io/arTIfiCE/) and obtain [Cesium](https://github.com/mateoconlechuga/cesium/releases). Compatibility depends on your OS and calculator revision; the linked project provides current instructions. There is no need to update the calculator OS to install these games.

The package includes the CE runtime AppVars used by the ports: `libload`, `graphx`, `keypadc`, and `fileioc`. Their upstream project is [CE Libraries](https://github.com/CE-Programming/libraries).

See each game's README for controls, implemented features, and differences from the original.

## Source and verification

Each game has its own directory and makefile. Builds use the workspace's portable [CE C/C++ Toolchain](https://github.com/CE-Programming/toolchain) and Python 3.12 with Pillow for asset generation.

- `run_scenario.py` runs a compact key script against a built game in windowless CEmu with a caller-supplied ROM, at idle priority, and saves a screenshot. `smoke.py` is the lower-level runner it uses.
- `verify_stages.py` opens every stage of both games through the QA path and writes `verification/STAGE-SMOKE.md`.
- `scoutcamp/tests/check_original_rules.py` and `pedrofu/tests/check_profile.py` run the real native rules code on the host and compare it with values evaluated from the original AS3.
- `reference_server.py` serves the original SWFs through Ruffle for side-by-side comparison; `extract_mechanics_spec.py` and `extract_dialogue_spec.py` index the recovered AS3.
- `sync_repo.py` copies the project files (no builds, ROMs or generated data) into the separate GitHub checkout under `build/flash-games-ce-repo`.

Logs, key scripts and LCD captures are kept in `verification/`. Physical-calculator testing is still outstanding.
