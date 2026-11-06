# v4 development preview — 6 November 2026

This continues the v3 checkpoint. Both ports are closer to the supplied games, but neither is finished. No measured gameplay-fidelity percentage is available.

## Added since v3

**Scouts vs Aliens:** restored the original title → campaign map → stage briefing flow, using the original map art, 17 locations and connecting paths. Integrated all 48 skills' original current/next-rank descriptions, the original options/reset sequence, and the ending text, animated towers and food parade. The reset option requires the original six confirmations; routine installation preserves existing saves.

Scouts also now has the original speed settings, in one-third increments from frozen to 4×, and focused targeting. The calculator uses keys: +/− changes the setting, 0 freezes/restores speed, GRAPH sends the next wave, STAT focuses the alien near the building cursor and VARS clears focus. Target selection retains range, visibility, immunity and status filters; towers that select below themselves retain that behavior. Focus clears when the alien dies/escapes or a new stage starts. These are keyboard adaptations of mouse controls. Actual accelerated throughput is limited by rendering/simulation cost; a 4× setting is not a verified 4× real-time result.

**Pedro Kicks Back:** fully opaque terrain now uses direct opaque draws, and the HUD has a separate bounded RAM sprite cache. The cache respects the clip regions used by Fury, XP and boss meters. Native framebuffer comparisons found no pixel differences in the tested tile/HUD cases. The same stage-one diagnostic scene improved from about 9 to 12 rendered FPS, with 30 simulation steps/second. This is still too slow and has not been measured on the physical calculator.

Pedro now displays original descriptions for all 45 skills with live bonuses and current/next-rank previews. ALPHA opens details; Left/Right previews ranks, Up/Down scrolls, ALPHA/MODE closes. ENTER learns and DEL refunds. Descriptions use integer arithmetic; checked Flash formatting differences are at most 0.01. Generated numeric intermediates stay within signed24-bit limits.

Both builds now reject a resident program that would overlap the LCD framebuffers. An experimental large Pedro build exceeded that bound; other slower/resetting experiments were excluded. This guard addresses a build hazard, not proof of the cause of the user's physical RAM clear.

## Checks and limits

See [the v4 verification report](verification/CHECKPOINT-v4.md) for final binary hashes, stage-entry results and the exact scope of native tests. All 15 Pedro and17 Scouts stages passed entry checks. The aerial-kick tutorial sequence and a 90-second input stress run also passed without an emulator NMI reset. Skill descriptions and optimized rendering have separate source-comparison, native input, pixel and buffer-guard checks.

The emulator still uses OS 5.3.0.0037. The user's calculator is hardware revision 8 with OS 5.8.2.29. **The physical freeze/RAM-clear report is not proven fixed.** Reaching a stage and surviving scripted inputs does not prove the stage can be completed.

## Still unfinished

- Pedro's frame rate remains inadequate. Its 30 Hz fixed-point simulation, some distance/offscreen rules, visual effects/scaling, camera behavior, options and presentation still differ from the 60 Hz Flash game.
- Scouts still needs precise tower firing animation timing and some original hover/history/presentation behavior. Ending randomness and fixed-point motion are not frame-for-frame Flash equivalents. Speed and focus controls are adapted to the keypad.
- Scouts can miss rapid key taps under load. An initial stricter timing/tap-count check failed; later checks record actual stored speed restoration and bounds rather than claiming those timing problems are fixed.
- Crowded battles, every boss/arena phase, save reload under realistic archive pressure and full campaigns still need sustained testing. Neither game has a complete original-versus-port playthrough or physical-calculator validation.
- Original music/sound is not reproduced. Scouts' audio options have no audible output.

## Install this preview

Use `FlashGamesCE-v4-preview.zip`. Replace the program and **all matching data files** together. Scouts now needs 33 banks (`SCA00`–`SCA32`); Pedro still needs 19 banks (`PDB00`–`PDB18`) plus its palette, tiles and six `PDUxx` images. The package includes both programs, 61 game-data AppVars, four runtime AppVars, controls, verification and a SHA-256 manifest.

Preserve unrelated calculator programs and saves `PDPROG2`/`SCTSV02`. Follow START-HERE.md in the ZIP. The original artwork/games remain credited to Hamumu Software; the Git history identifies the calculator-port contributor.

Next priorities are physical crash reproduction and Pedro's remaining draw cost, followed by full original-versus-port stage/boss playthroughs and remaining animation/effect corrections. This preview records progress, not completion.
