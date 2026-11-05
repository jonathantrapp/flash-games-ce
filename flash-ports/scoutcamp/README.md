# Scouts vs Aliens CE

Native calculator rebuild of the supplied `scoutcamp_unlocked.swf` (the in-game title is **Scouts vs Aliens**, Hamumu Software, 2012). It is built from the AS3 recovered with JPEXS, not from a Flash emulator. This is a work in progress; the [parity audit](../PARITY-AUDIT.md) lists what is verified and what is not.

`bin/SCOUTCE.8xp` is the program; the 18 `SCAxx.8xv` banks hold the artwork and must be sent with it. Runtime libraries and install steps are in the parent README.

## Play

Choose a stage with Left/Right on the stage menu. Stages unlock in order as you win. Aliens walk from their portals to the camp, grab one of the five meals and carry it back; kill a thief to drop its meal where it dies, and nearby aliens can pick it up again. Lose all five meals and the stage is lost. Win by clearing every wave.

| Key | Action |
| --- | --- |
| Arrows | Move the building cursor |
| 1 / 2 / 3 / 4 | Choose Rock Tower, Roly Poly, Snow Fort or Shock Tower |
| 2nd | Build the chosen tower (needs the tower's skill, Rock Tower is free) |
| Enter | Upgrade the tower under the cursor (five upgrades); builds if the spot is empty |
| Math / Apps | Specialize a base tower into its first / second branch tower (needs the branch skill) |
| Del | Sell for half of everything spent |
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
- Projectile-based combat (arcing, rolling and falling shots, sprays, lightning, cripple and quake), with freeze, slow, shock, poison, cripple, flatten, fling and disable as separate effects.
- All 48 skills in four trees with the original prerequisites, applied in the simulation; save file `SCTSV02` keeps skills, level, XP, points and stage wins.
- A 20 Hz fixed-step simulation on a hardware timer, independent of drawing speed.

## Not done, or not verified

- No music or sound; no mouse-style tower focus-fire or alien targeting (the original lets you click an alien to focus fire).
- The speed slider and freeze-time key of the original are not reproduced.
- Skill descriptions are not shown; the skill screen shows names, ranks and prerequisites.
- Tower and alien behaviour is translated from the AS3 but has not been compared frame by frame with the original running in Ruffle. Stages are verified to load and run in the emulator, not to be winnable.
- Tower animation frames are approximated (idle, then a generic firing cycle).
- Not yet tested on a physical calculator.
- Numerical rules (tower stats, prices, monster life/money, skill prerequisites) are checked against the original formulas by `tests/check_original_rules.py`.

## Source and build

`src/main.c` is the keypad front end and renderer. `src/engine.h`, `src/combat.h` and `src/rules.h` hold the simulation; `src/data.h` holds generated map, route and wave tables; `src/art.h`/`art.c` load the art banks; `src/tips.h` holds the original stage briefings.

Generators (Python 3.12 with Pillow from `local-tools/plot-libs`): `generate.py` (maps/waves), `generate_rules.py` (rules and skills), `build_art.py` (art banks), `generate_tips.py` (briefings). Build from this directory with the workspace-local toolchain:

```powershell
& ../../local-tools/cedev/CEdev/bin/make.exe
python tests/check_original_rules.py
```

These files retain original third-party content and attribution; this private conversion does not grant redistribution rights.
