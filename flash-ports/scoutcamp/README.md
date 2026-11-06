# Scouts vs Aliens CE

Native calculator rebuild of the supplied `scoutcamp_unlocked.swf` (the in-game title is **Scouts vs Aliens**, created by Hamumu Software, 2012). It is built from the AS3 recovered with JPEXS, not from a Flash emulator. This is a work in progress; the [parity audit](../PARITY-AUDIT.md) lists what is verified and what is not.

`bin/SCOUTCE.8xp` is the program; all 32 banks `SCA00.8xv` through `SCA31.8xv` hold the artwork and must be sent with it. Runtime libraries and install steps are in the parent README.

## Play

Choose a stage with Left/Right on the stage menu. Stages unlock in order as you win. Aliens walk from their portals to the camp, grab one of the five meals and carry it back; kill a thief to drop its meal where it dies, and nearby aliens can pick it up again. Lose all five meals and the stage is lost. Win by clearing every wave.

| Key | Action |
| --- | --- |
| Arrows | Move the building cursor |
| 1 / 2 / 3 / 4 | Choose Rock Tower, Roly Poly, Snow Fort or Shock Tower |
| 2nd | Build the chosen tower (needs the tower's skill; the Rock Tower skill is provided) |
| Enter | Upgrade the tower under the cursor (five upgrades); builds if the spot is empty |
| Math / Apps | Specialize a base tower into its first / second branch tower (needs the branch skill) |
| Del | Sell for the displayed refund |
| + | Send the next wave early (On A Roll skill pays a bonus) |
| Alpha | Pause; opens the controls page on the stage menu |
| Mode | Back to the stage menu |
| Stat | Skills (stage menu and result screens) |
| Clear | Save and exit |
| Vars (held on the stage menu) | QA only: starts any stage regardless of progress |

On the skill screen: arrows move, Enter learns a rank, Del resets everything for a full refund, Mode goes back. Defeating aliens earns XP, win or lose; each level gives one skill point.

## What is in this build

- All 17 original maps (four layers each), the original wave schedules, concurrent waves and the enemy-level formula from `WaveManager.as`.
- Original full-size artwork, palette and sky progression, with the stage briefings from the original game.
- The 12 towers (four bases and eight branch towers), upgrade and build prices, damage, range, reload and special values generated from the original AS3 formulas (`src/rules.h`).
- Ten alien types with the original life, money and speed formulas and their specials: Wormy immunity while grounded, Speedy acceleration, Blinky healing, Scary tower suppression, Hungry and its babies.
- Projectile combat (straight and homing shots, rolling and falling boulders, sprays, lightning, cripple and quake), with freeze, slow, shock, poison, cripple, flatten, fling and disable as separate effects.
- All 48 skills in four trees with the original prerequisites, applied in the simulation; save file `SCTSV02` keeps skills, level, XP, points and stage wins.
- A hardware-timed simulation: 20 Hz status/wave/tower updates and 60 Hz movement and projectile substeps. The renderer is independent of simulation timing.

## Not done, or not verified

- The title and stage selector remain a combined screen; the original campaign map, options and animated ending flow are not integrated.
- No music or sound; no mouse-style tower focus-fire or alien targeting (the original lets you click an alien to focus fire).
- The speed slider and freeze-time key of the original are not reproduced.
- Skill descriptions are not shown; the skill screen shows names, ranks and prerequisites.
- Tower and alien behaviour is translated from the AS3 but has not been compared frame by frame with the original running in Ruffle. Stages are verified to load and run in the emulator, not to be winnable.
- Tower animation frames are approximated (idle, then a generic firing cycle).
- This checkpoint has not been tested on a physical calculator. The earlier Pedro build was reported to run slowly and crash; that report does not establish the safety of this Scouts checkpoint.
- The native stage-1 performance capture measured 24 FPS in CEmu, with a small battle. Crowded stages and the cave background can be slower; this is not a physical-calculator frame-rate claim.
- Active pools are bounded at 160 aliens, 64 towers and 96 projectiles; spawning waits when a pool is full.
- Numerical rules (tower stats, prices, monster life/money, skill prerequisites) are checked against the original formulas by `tests/check_original_rules.py`.

## Source and build

`src/main.c` is the keypad front end and renderer. `src/engine.h`, `src/combat.h` and `src/rules.h` hold the simulation; `src/data.h` holds map metadata, portal locations and wave tables; original map RLE lives in the versioned resource banks; `src/art.h`/`art.c` load the art banks; `src/tips.h` holds the original stage briefings.

All resource banks must match the program: the loader rejects missing, outdated or mixed banks using a bundle signature, index and size checks. Do not combine banks from an older download.

The stage-1 sky and common terrain tiles are cached losslessly in RAM. The linked code section is 60,386 bytes, below the 64 KiB code boundary; the fixed BSS/heap region has about 2.7 KiB of allocator space left. The program does not allocate graphics buffers dynamically during play.

Generators (Python 3.12 with Pillow from `local-tools/plot-libs`): `generate_data.py` (maps/waves; `generate.py` is a compatibility wrapper), `generate_rules.py` (rules and skills), `build_art.py` (art banks), `generate_tips.py` (briefings). Build from this directory with the workspace-local toolchain:

```powershell
& ../../local-tools/cedev/CEdev/bin/make.exe
python verify_data.py
python tests/check_resources.py
python tests/check_original_rules.py
```

The original game, artwork and music are by Hamumu Software (2012); see [CREDITS.md](../CREDITS.md). This is an unofficial fan port and grants no rights to the original content.


## Checkpoint verification

- All 17 packed maps compared byte for byte with the original SWF exports; all 23 portals, 184 waves and 362 spawn groups compared with the original data.
- All 32 TI resource checksums and bundle headers, 1,034 frame references and frame bounds checked; 153,600 sky pixels decoded from the optimized format and matched exactly.
- 120,030 native rule comparisons against independently evaluated original formulas: zero differences.
- A native eZ80 fixture passed 19 checks covering walking displacement, the three original jump impulses/apices, Hungry's large-health threshold and its three baby speeds/birth durations, Free Pebbles, global Cold Hard Cash freeze, branch conversion state/refund basis, and a long-range homing shot velocity that formerly overflowed 24-bit arithmetic.
- The experimental assembly PackBits decoder passed all 256 command/length cases and 100 mixed streams with output canaries. Production uses the faster row-fill/RLET renderer instead.

These checks do not prove that every stage is winnable or that enemy/projectile collision timing matches the original frame for frame. Resource, numerical, unit and smoke evidence are distinct.
