# Development checkpoint — 6 November 2026

This is a stopping point for continued development, not a completed port or a claim of 99–100% fidelity. Gameplay fidelity is still unmeasured. Earlier checklist percentages describe code coverage and judgement, not how closely either game plays.

## Completed: Pedro Kicks Back

- Restored the original burning-blimp opening: flight, fire/explosions, parachute descent, landing/canopy collapse, then the first conversation. The packaged production build reaches that conversation in CEmu.
- Added bounds checks for dialogue/help buffers, text coordinates, sprite caches and resource banks. Corrected an out-of-range flame-art lookup. Missing, truncated or mixed-version resource banks are rejected before use.
- Reduced mutable map memory, cached selected sprites in RAM, and encoded the original sky losslessly. Collision movement checks crossed pixels instead of every fractional step.
- Corrected Master Yak activation, line-of-sight teleport and encounter states; barriers wait for every tagged orb; occupied tagged tents keep gates closed. Regular and grass tents finish their original spawn sequences.
- Corrected enemy statistics, several attack/status/projectile rules, burning-uppercut charging and skill gating. Replaced recursive Combo Bombo chains with a bounded queue. Removed the invented double jump/glide after tracing the original activation paths.
- Save archiving happens after graphics shutdown and asset use ends. Key taps survive the fixed-step loop. Native tests cover selected repaired mechanics, not every combination.

## Completed: Scouts vs Aliens

- Checked all 17 maps, 23 portal starts, 184 waves and 362 wave groups against the original data.
- Corrected Hungry baby speeds/shrinking, Free Pebbles, Cold Hard Cash, conversion/refund rules and builder/growth behavior.
- Restored original jump/gravity substeps and corrected projectile motion, bounds, homing and status timers. Fixed large-health/long-shot arithmetic and bounded Megawatt chains.
- Moved map resources into validated versioned banks, added lossless sky rendering and common-tile RAM caches, and checked the native sprite decoder and resource bounds.

## What the checks show

Pedro's latest emulator run passes through the aerial-kick tutorial inputs and can be paused afterward. The opening reaches its first conversation. Both games return to the OS home screen in exit checks. Scouts' final integrated runs reach play with a placed tower and the Hungry test scenario.

These are bounded emulator checks, not full playthroughs. The emulator uses OS 5.3.0.0037; the reported freeze/RAM clear happened on hardware revision 8, OS 5.8.2.29. The exact physical crash has not been reproduced or proven fixed. The text overflow was a real defect, but is not established as its sole cause.

Detailed test counts, binary hashes and limitations: [verification/CHECKPOINT-v3.md](verification/CHECKPOINT-v3.md).

## Still unfinished

- **Pedro performance:** approximately 9 rendered FPS in the last instrumented stage-one emulator run, versus about 8 initially. This does not solve the reported roughly 10 FPS on the calculator. Explicit 48 MHz mode and rendering experiments did not establish a useful fix. Experimental builds are excluded from this package.
- **Scouts performance:** last instrumented stage-one capture was 24 FPS. That is one scenario, not a minimum or physical-calculator measurement.
- **Physical testing:** neither packaged binary has been tested on the user's revision-8/OS-5.8 calculator. RAM-clear stability, storage pressure, save persistence after restart and sustained play remain unverified there.
- **Pedro fidelity:** simulation remains 30 Hz fixed point versus the original 60 Hz floating point. Some distance tests, offscreen simulation, visual effects, scaling, camera behavior, UI/options and skill tooltips remain approximate or incomplete. Enemy/boss states and attacks still need comparison in play.
- **Scouts fidelity:** original campaign-map/options flow, animated ending, speed slider, focus-fire selection, original skill tooltip text and precise tower firing animations remain unfinished. Generated menu data is preparation, not an integrated feature.
- **Whole-game verification:** no complete original-versus-port playthrough of every stage, boss, arena, ending or skill combination has been performed. Existing tests do not establish gameplay equivalence.
- Original audio is not reproduced on the calculator.

## Deliverable and installation

`FlashGamesCE-v3-checkpoint.zip` contains two programs, 60 game-data AppVars, four runtime AppVars, controls, this report, verification notes and a SHA-256 manifest. Production programs: `PEDROCE.8xp` (54,063 bytes) and `SCOUTCE.8xp` (42,845 bytes). Debug/profiling variants are excluded.

Replace each program and **all** its supplied game-data AppVars together: Scouts uses `SCA00`–`SCA31`; Pedro uses `PDB00`–`PDB18`, `PDCOLOR`, `PDTILE0/1` and six `PDUxx` files. Preserve unrelated calculator programs and saves `PDPROG2`/`SCTSV02`. Read START-HERE.md in the ZIP for transfer instructions. Treat this as a test build while the RAM-clear report remains unverified.

## Next work, in order

1. Reproduce the stage-one failure with matching hardware/OS, or obtain a reliable crash trace; verify saves and repeated exits under realistic archive usage.
2. Profile Pedro's draw costs on the calculator and fix dominant costs while comparing original pixels and gameplay.
3. Compare every stage and boss with the original in Ruffle, record differences and fix them; finish missing Scouts menus/controls/ending and Pedro UI/effects.
4. Run complete campaigns and sustained hardware sessions before calling either port finished.

The original games/artwork are by Hamumu Software. Git commits identify the calculator-port contributor; they do not transfer authorship of the originals.
