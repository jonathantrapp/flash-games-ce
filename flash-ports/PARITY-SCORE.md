# Parity score (2026-11-05)

**Historical scoring snapshot.** Subsequent changes are documented in [the v3 checkpoint](CHECKPOINT-2026-11-06.md) and [v4 continuation](CONTINUATION-2026-11-06.md). These percentages have not been recalculated and must not be presented as current completion or gameplay fidelity.

This scores every item of the [parity audit](PARITY-AUDIT.md) checklist against the current code and test evidence. It measures **audit coverage and evidence**, not how closely the games play like the originals: no side-by-side comparison with the original running in Ruffle and no full playthrough has been done, so true gameplay fidelity is unmeasured.

## Rubric

| Class | Meaning |
| --- | --- |
| **V** Verified | Implemented, and a native test compared it with the original source or data and found no differences. |
| **I** Implemented | Implemented from the original source with every sub-claim of the item addressed; no test compares its behaviour with the original. |
| **P** Partial | Implemented, but a sub-claim of the item is missing or known to be simplified. |
| **M** Missing | Not implemented, or not done at all. |

The shared gates (S1..S9) apply to both games and are scored for each. Items were classified conservatively: anything without a comparison test is at most I.

## Results

| | Items | V | I | P | M | Verified | Implemented or better (V+I) | Not missing (V+I+P) | Weighted* |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Scouts vs Aliens | 34 | 3 | 22 | 8 | 1 | 8.8% | 73.5% | 97.1% | 47.1% |
| Pedro Kicks Back | 31 | 3 | 12 | 14 | 2 | 9.7% | 48.4% | 93.5% | 40.3% |
| Both | 65 | 6 | 34 | 22 | 3 | 9.2% | 61.5% | 95.4% | 43.8% |

*Weighted = (V + 0.5 I + 0.25 P) / items. The weights are a judgement call, not a measurement; the first three percentage columns need no weighting.

## Shared gates

| ID | Item | Scouts | Pedro | Evidence / gap |
| --- | --- | --- | --- | --- |
| S1 | Original screens reachable (title, map, options, pause, retry, win/ending, skills) | P | P | No options screen in either game; the rest exist. |
| S2 | Map dimensions and layers byte-exact | V | V | `scoutcamp/verify_data.py`; `pedrofu/tests/check_data.py` (15 stages from the packed banks). |
| S3 | Frame sizes, offsets, palette, layering, hitboxes | P | P | Sizes and offsets come from the source; the palette is quantized to at most 255 colours and layering is approximate. |
| S4 | Fixed simulation tick independent of drawing | I | I | Hardware-timer fixed step; displacement, jump apex and shot cadence were not compared with the original. |
| S5 | Resources fit flash/RAM; saving cannot invalidate pointers | I | I | Runs in CEmu with all resources; pointer safety is by design (RAM-only saves), not tested. |
| S6 | Save keeps progression across exit and relaunch | I | I | A prepared save loads (Pedro); a game-written save was not round-tripped. |
| S7 | Every stage's win condition achievable; unlock order correct | I | I | Unlock order implemented; no stage was played to a win. |
| S8 | Original-runtime and native screenshots for key scenes | P | P | Native captures exist; none from the original runtime. |
| S9 | Physical calculator testing | M | M | Not done. |

## Scouts vs Aliens

| ID | Item | Class | Evidence / gap |
| --- | --- | --- | --- |
| W1 | 17 maps and exact WaveDef schedules | V | `verify_data.py` wave checks. |
| W2 | Concurrent active waves | I | Per-wave spawners. |
| W3 | Absolute wave times, early send, On A Roll | I | |
| W4 | Enemy level formula | I | Reduces to `stage*3 + waveIndex + 1` (activeWaves length equals waves started); not tested. |
| W5 | Initial money and skill economy | I | |
| W6 | Tip pause, victory and defeat conditions | I | Tip pause seen in CEmu; win and loss not reached. |
| W7 | Sky progression and single tile atlas | I | |
| F1 | Five separate food objects | I | |
| F2 | Carrier death drops food; others re-grab; jumpers cannot | I | |
| F3 | Portal escape, direction reversal, refrigeration/poison trap | I | |
| F4 | Original collision layers and jump markers 3..11 | I | |
| F5 | Jump velocity and horizontal jump speed | I | Constants match the source. |
| F6 | Slope and tile collision semantics | I | Only tiles 14 and 18 are slopes in `TileSet_Grave.as`, as implemented. |
| R1 | Ten alien types: formulas, bounds, animation, XP | P | Life, money and speed verified by the rules test; bounds, XP and animation timing are not. |
| R2 | Wormy immunity | I | |
| R3 | Blinky healing | I | |
| R4 | Scary tower suppression | I | |
| R5 | Hungry and babies | P | Baby spawning and food eating exist; the 2 / 1 / 0.5 baby speed multipliers and shrinking are missing. |
| R6 | Status effects as separate mechanics | I | |
| T1 | Base towers: stats, build time and growth | P | Stats verified; build time is 1 s instead of 2 s and there is no growth animation. |
| T2 | Eight branch conversions, gated | I | Exercised in CEmu (no crash); effects not compared. |
| T3 | Projectile geometries and hit callbacks | P | Shots are simplified (rock shots do not arc, falling and rolling boulders are approximate). |
| T4 | Soapbox, Slushee/Crusher, Lightning Rod, Crippler targeting | I | |
| T5 | 48 skills, rank 5, prerequisites | V | `check_original_rules.py`. |
| T6 | Every skill effect connected to simulation | P | 47 of 48 skills are referenced in the simulation; Free Pebbles is not. |

## Pedro Kicks Back

| ID | Item | Class | Evidence / gap |
| --- | --- | --- | --- |
| A1 | Stages 11 and 14 start with five mail | I | |
| A2 | Arena spawn arrays, locations, time bonuses | V | `check_data.py` (6 tables equal to `Arena.as`). |
| A3 | Arena reward priority and expiry | I | |
| A4 | Stage 15 needs one mail via the Master's death | P | The Master drops a mail pickup instead of decrementing the count directly. |
| A5 | Master Yak invulnerability, dizzy window, orbs, teleport, guards | P | Orbs, 8 s window, respawn positions and guards exist; line-of-sight teleport is missing. |
| A6 | Barrier entity and orbs | I | |
| A7 | Tag completion (DEADLY and BACKGD groups, level2Spot) | P | Enemy tags only; background-object tags and the stage-3 trap record are missing. |
| A8 | Dialogue events 5, 8, 9, 10 side effects | I | |
| B1 | Physical units, acceleration, jump grace, variable jump | P | Integer-scaled approximations (about 6% off on gravity); no variable jump height. |
| B2 | State machines; skill-gated specials | I | |
| B3 | Move set with original inputs, costs, timing, knockback | P | All moves exist; timing and knockback are interpretations; burning Pedroken is missing. |
| B4 | Fury units and directional selector | I | |
| B5 | Statuses and skills across the simulation | P | All 45 skills are referenced; shock, burn and flatten statuses are missing. |
| B6 | All map entities 1..47 behave correctly | P | Fire Man and several props are minimal. |
| B7 | Enemy class AI, projectiles, hitboxes, animations, special states | P | Core behaviours exist; some wake-up and hidden states are simplified. |
| C1 | Layouts and pickup rules (heart, soul, technique mapping) | I | Maxima verified in the profile test; the pickup mapping is inspected only. |
| C2 | XP, level, base life and fury rules | V | `check_profile.py`. |
| C3 | 45 skills: prerequisites, purchase, effects, profile | P | Prerequisites and purchase verified; effects unverified. |
| C4 | Intro blimp sequence | M | Not implemented. |
| C5 | All 12 events and 28 pages, speakers, camera, triggers | P | Page text verified exact (`check_data.py`); speaker bubbles and camera behaviour are not reproduced. |
| C6 | Key trigger examples | P | Most listed triggers exist; the stage-3 armored wake is not reproduced. |
| C7 | Ending and replay flow | I | |

## What would raise the numbers

- Verified (V) needs comparison tests: running the original in Ruffle for the same scenario and comparing results, and completing each stage.
- Several P items are small fixes: Hungry baby speeds, tower build time, Free Pebbles, shock/burn/flatten statuses, the Master's teleport.
- S9 needs a physical TI-84 Plus CE.
