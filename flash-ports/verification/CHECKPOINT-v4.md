# v4 preview verification — 6 November 2026

These results apply to the frozen compact production builds below. CEmu uses the user's OS 5.3.0.0037 ROM; the physical calculator is revision8/OS5.8.2.29. Physical performance and the reported RAM-clear failure remain unverified.

| Program | Bytes | SHA-256 |
| --- | ---: | --- |
| PEDROCE.8xp | 58,706 | `e1df6622836ff3597d2ee1a8ba296cf74e36169253a8806f45415da2e63aabe3` |
| SCOUTCE.8xp | 47,039 | `8c6bf764ae0679215e4fb017d4474c4c9c10aa37a59b605fab6372c9c85a50fd` |

Pedro's 19 signed PDB banks are unchanged from v3. Scouts requires all33 signed SCA banks, signature `91bdb3a8`, with1,035 frame records and240 skill descriptions. Old/new banks must not be mixed.

## Final production checks

- **15/15 Pedro stage entries passed:** [matrix](STAGE-SMOKE-v4-pedrofu.md). Each run asserts the selected stage and an expected gameplay/dialogue/result state; NMI resets fail even if diagnostic bytes happen to match.
- **17/17 Scouts stage entries passed:** [matrix](STAGE-SMOKE-v4-scoutcamp.md). Runs use the new title/map/briefing flow and GRAPH wave key. Both matrices record the tested production binary hashes.
- Pedro `v4_tutorial`: aerial-kick instruction input scenario reaches PAUSE. `v4_stress`:90 seconds of deterministic movement/jump/attack/Fury inputs completes without NMI. `v4_exit`: observed OS home screen; no automated exit assertion or save-reload test.
- Scouts `focus_gameplay`:3 assertions passed. `focus_newstage`:3 assertions passed, including clearing focus/resetting speed/showing briefing. `focus_selected_final`/`focus_cleared`:1 assertion each using QA_FOCUS's deterministic alien. `speed_max_restore`:1 assertion confirms requested speed12thirds restored. `controls_exit`: observed OS home screen.

These are launch/input checks, not proof that any campaign, stage, boss or ending can be completed.

## Targeted native/source checks

| Check | Result | Scope |
| --- | --- | --- |
| Pedro terrain/HUD pixel comparison | Passed | Actual render_cache.c: all296 tiles under15 stage cache selections,4 clipped screen-edge montages,8 HUD/clip montages; zero pixel differences or tile/HUD canary damage |
| Pedro skill descriptions | 18,090 comparisons passed | All45 skills, ranks0..5,67 modifier profiles, guarded output sizes0/1/2/64/384.210 accepted Flash numeric-format differences of at most0.01; longest text183 bytes |
| Pedro native skill UI | 285 assertions passed | Real frontend/profile code and GraphX fonts/assets: locked/details behavior, rank previews, learn/refund, navigation, close and print bounds. Stage loading stubbed; no bad print coordinates |
| Pedro description integer bound | Passed | Generator interval analysis over independently varied ranks/modifiers; maximum absolute numeric intermediate3,875, below signed24-bit maximum8,388,607 |
| Scouts native engine | 37 cases passed | Actual simulation/targeting code: retained physics/skills plus focused targets, filters, status fallback and focus removal on death/escape |
| Scouts resources | Passed | 33 banks,1,035 frame bounds,240 original-description offsets/blob,153,600 sky pixels;17 maps/23 portals/184 waves/362 groups retained |
| Scouts speed controls | 8 behavioral assertions passed | Frozen tick stability, stored setting restoration, forward progress and bounds; see limitations below |

Scouts' restored map/skills/reset/ending UI has separate native scenarios: ui_map_final1 assertion, ui_skills_final1, ui_play_final3, ui_reset_final3 and ui_ending_final1. The latter reset/ending tests use diagnostic QA_ENDING/QA_MAXED paths and do not prove a campaign was completed. UI captures predate the final focus/speed addition; the screens are unchanged. The production build excludes QA flags. The later focus/speed/stage tests apply to the final binary above.

Earlier v3 combat, numeric-rule, data, text and decoder checks are retained for their unchanged code/data; see [the historical v3 report](CHECKPOINT-v3.md). They do not establish whole-game fidelity.

## Performance and rejected experiments

The final Pedro profiling variant records12 rendered FPS and30 simulation steps/second in the same stage-one scenario that previously measured about9 FPS. `pedrofu/v4_performance/performance.json` records counters and both profile/production hashes. The overlay is diagnostic, not part of the packaged HUD. This is one sampled epoch/scene, not a minimum, physical-calculator result or full-game benchmark.

Scouts' last24 FPS stage-one measurement predates these changes. Its requested speed setting reaches0..4 in one-third increments, but actual4× wall-clock speed was **not** verified. A stricter initial timing expectation failed (109 expected ticks,67 observed). Nine rapid220ms plus taps missed one increment and reached11thirds;15 taps reached the upper bound12. The behavioral check correctly verifies restoration of the value actually stored, not an assumed tap count. Frozen counters stayed at8 across the two sampled captures; resumed1× advanced24 ticks and the sampled11/3 setting advanced67. These limitations remain open.

The PackBits sky experiment was slower (about10 FPS versus12), and contiguous fill/early-culling experiments did not improve the integer FPS result. A no-LTO speed-compiled experiment reset CEmu and is excluded. A whole-program-O1 experiment ended at0xD46D54, overlapping display memory, and was never selected for packaging. Both makefiles now link a guard that rejects resident data/code beyond0xD40000; a negative build verified the guard rejects the oversized experiment.

Default Pedro resident end:0xD365CE; BSS end:0xD12389. Scouts resident end:0xD2F175; BSS end:0xD13612. The default Pedro rebuild produced an identical calculator payload; only the TI transfer-file timestamp differed. Both packaged programs remain the exact stage-tested files above.

## Package scope

The preview contains2 programs,61 game-data AppVars and4 runtime AppVars. Packaging checks expected resource names/counts, resident-memory bounds, ZIP integrity and a per-file size/SHA-256 manifest. No ROM or raw RAM capture is included. These checks establish package consistency, not hardware stability or gameplay equivalence.
