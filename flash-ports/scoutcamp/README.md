# Scouts vs Aliens CE

Native calculator rebuild of the supplied `scoutcamp_unlocked.swf` (the in-game title is **Scouts vs Aliens**, created by Hamumu Software, 2012). It is built from the AS3 recovered with JPEXS, not from a Flash emulator. This is a work in progress; the [parity audit](../PARITY-AUDIT.md) lists what is verified and what is not.

`bin/SCOUTCE.8xp` is the program; all 33 banks `SCA00.8xv` through `SCA32.8xv` hold the artwork, maps and original skill descriptions and must be sent with it. Runtime libraries and install steps are in the parent README.

The v5 input queue retains keypad transitions sampled during rendering and between simulation steps. Cursor repeat uses a 200 ms timer. Tests passed nine repeated plus taps at 220/150, 80/80 and 40/40 ms press/release intervals, with no queue overflows; they don't guarantee every short tap under arbitrary battle load. The tested stage-one setup measured 19.83 simulation ticks/sec at 1× and 44.83 at the requested 4× setting (targets: 20 and 80). See [v5 verification](../verification/CHECKPOINT-v5.md); physical timing and full campaigns remain unverified.

## Play

Choose Play Game on the title screen, then choose an unlocked stage with the arrows on the original campaign map. Enter starts the stage; Enter again dismisses its briefing. Stages unlock in order as you win. Aliens walk from their portals to the camp, grab one of the five meals and carry it back; kill a thief to drop its meal where it dies, and nearby aliens can pick it up again. Lose all five meals and the stage is lost. Win by clearing every wave.

| Key | Action |
| --- | --- |
| Arrows | Move the building cursor |
| 1 / 2 / 3 / 4 | Choose Rock Tower, Roly Poly, Snow Fort or Shock Tower |
| 2nd | Build the chosen tower (needs the tower's skill; the Rock Tower skill is provided) |
| Enter | Upgrade the tower under the cursor (five upgrades); builds if the spot is empty |
| Math / Apps | Specialize a base tower into its first / second branch tower (needs the branch skill) |
| Del | Sell for the displayed refund |
| + / - | Increase/decrease the requested simulation speed in 1/3x steps, from 0 to 4x |
| 0 | Freeze time, or restore the previous speed; building still works |
| Graph | Send the next wave early (On A Roll skill pays a bonus) |
| Alpha | Pause; opens the controls page on the stage menu |
| Mode | Back to the stage menu |
| Stat | Skills on the map/results; focus fire on the alien nearest the building cursor during play |
| Clear | Save and exit |
| Vars | Clear focus during play; held on the map, QA access to any stage |

On the skill screen: arrows move, Enter learns a rank, Alpha toggles the original current/next-rank descriptions, Del resets skills for a full refund, Mode returns to the campaign map. Defeating aliens earns XP, win or lose; each level gives one skill point. Title-screen Options includes the original six-confirmation Reset Progress sequence; the sound/music controls have no audio output on the calculator.

## What is in this build

- All 17 original maps (four layers each), the original wave schedules, concurrent waves and the enemy-level formula from `WaveManager.as`.
- Original full-size artwork, palette and sky progression, with the stage briefings from the original game.
- The 12 towers (four bases and eight branch towers), upgrade and build prices, damage, range, reload and special values generated from the original AS3 formulas (`src/rules.h`).
- Ten alien types with the original life, money and speed formulas and their specials: Wormy immunity while grounded, Speedy acceleration, Blinky healing, Scary tower suppression, Hungry and its babies.
- Projectile combat (straight and homing shots, rolling and falling boulders, sprays, lightning, cripple and quake), with freeze, slow, shock, poison, cripple, flatten, fling and disable as separate effects.
- All 48 skills in four trees with the original prerequisites, applied in the simulation; save file `SCTSV02` keeps skills, level, XP, points and stage wins.
- Separate title, campaign-map and options screens, using original artwork and all 17 original map locations/65 path dots. The latest location's path reveals before its marker grows, following the original sequence.
- All 240 original rank descriptions, with current/next-rank text available on the skill screen.
- Final-stage victory leads to the original ending text, a moving food parade and animated Soapbox towers. Food motion uses source-derived velocities/bounds with fixed-point updates; random sequences and text layout differ.
- Original speed-slider art and 0–4x requested speed settings, in the original 1/3x increments, with time freeze/restore. Actual attainable speed depends on calculator performance.
- Focus-fire priority for eligible targets, with range, line-of-sight, immunity and per-tower status filters. Snow skips already frozen/slowed aliens; Shock can fall back to shocked targets when no unshocked target qualifies. Crusher/Slushee/Lightning use their original separate below/above targeting and ignore focus. Death, escape and new stages clear focus.
- A hardware-timed simulation: 20 Hz status/wave/tower updates and 60 Hz movement and projectile substeps. The renderer is independent of simulation timing.

## Not done, or not verified

- Campaign selection uses calculator keys instead of a mouse. Some original hover text, level-history details, font/layout behavior and animated transitions remain approximate. Sound/music option values are session-only visual settings because audio is not implemented.
- No music or sound. Focus uses Stat to select the nearest alien within 24 pixels of the grid cursor; the original uses a precise mouse click. Slider adjustment uses calculator keys.
- The requested 4x setting is implemented, but exact 4x wall-clock progression is not verified: an emulator control interval initially expected to advance about 109 simulation ticks advanced 67. Nine rapid 220ms plus-key taps also missed an increment, reaching 11/3x; freeze/resume correctly restored that actual stored value. The longer plus-key sequence reached the 4x upper bound. Input sampling/render load still need improvement; do not treat the slider as a measured speed guarantee.
- Tower and alien behaviour is translated from the AS3 but has not been compared frame by frame with the original running in Ruffle. Stages are verified to load and run in the emulator, not to be winnable.
- Tower animation frames are approximated (idle, then a generic firing cycle).
- This checkpoint has not been tested on a physical calculator. The earlier Pedro build was reported to run slowly and crash; that report does not establish the safety of this Scouts checkpoint.
- The native stage-1 performance capture measured 24 FPS in CEmu, with a small battle. Crowded stages and the cave background can be slower; this is not a physical-calculator frame-rate claim.
- Active pools are bounded at 160 aliens, 64 towers and 96 projectiles; spawning waits when a pool is full.
- Numerical rules (tower stats, prices, monster life/money, skill prerequisites) are checked against the original formulas by `tests/check_original_rules.py`.

## Source and build

`src/main.c` is the keypad front end and renderer. `src/engine.h`, `src/combat.h` and `src/rules.h` hold the simulation; `src/data.h` holds map metadata, portal locations and wave tables; original map RLE lives in the versioned resource banks; `src/art.h`/`art.c` load the art banks; `src/tips.h` holds the original stage briefings.

All resource banks must match the program: the loader rejects missing, outdated or mixed banks using a bundle signature, index and size checks. Do not combine banks from an older download.

The stage-1 sky and common terrain tiles are cached losslessly in RAM. The linked code section is 64,426 bytes; the fixed BSS/heap region has 2,502 bytes of allocator space left. The program does not allocate graphics buffers dynamically during play. A linker guard rejects resident code/data that would overlap GraphX's LCD framebuffers.

Generators (Python 3.12 with Pillow from `local-tools/plot-libs`): `generate_data.py` (maps/waves; `generate.py` is a compatibility wrapper), `generate_rules.py` (rules and skills), `generate_ui.py` (map/ending/skill descriptions), `build_art.py` (signed resource banks), `generate_tips.py` (briefings). Run `generate_ui.py` before regenerating resource banks with `build_art.py`. Build from this directory with the workspace-local toolchain:

```powershell
& ../../local-tools/cedev/CEdev/bin/make.exe
python verify_data.py
python tests/check_resources.py
python tests/check_original_rules.py
```

The original game, artwork and music are by Hamumu Software (2012); see [CREDITS.md](../CREDITS.md). This is an unofficial fan port and grants no rights to the original content.


## Checkpoint verification

- All 17 packed maps compared byte for byte with the original SWF exports; all 23 portals, 184 waves and 362 spawn groups compared with the original data.
- All 33 TI resource checksums and bundle headers, 1,035 frame references/frame bounds and all 240 description offsets checked; 153,600 sky pixels decoded from the optimized format and matched exactly.
- 120,030 native rule comparisons against independently evaluated original formulas: zero differences.
- A native eZ80 fixture passed 19 checks covering walking displacement, the three original jump impulses/apices, Hungry's large-health threshold and its three baby speeds/birth durations, Free Pebbles, global Cold Hard Cash freeze, branch conversion state/refund basis, and a long-range homing shot velocity that formerly overflowed 24-bit arithmetic.
- The experimental assembly PackBits decoder passed all 256 command/length cases and 100 mixed streams with output canaries. Production uses the faster row-fill/RLET renderer instead.

These checks do not prove that every stage is winnable or that enemy/projectile collision timing matches the original frame for frame. Resource, numerical, unit and smoke evidence are distinct.
