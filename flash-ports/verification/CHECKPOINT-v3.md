# v3 checkpoint verification — 6 November 2026

Scope: default production builds below, with matching signed data banks. CEmu used the user's OS 5.3.0.0037 ROM, not the physical calculator's OS 5.8.2.29. ROMs and RAM dumps are excluded from the repository and package.

| Program | Bytes | SHA-256 |
| --- | ---: | --- |
| PEDROCE.8xp | 54,063 | `31381ea9f0f12d24c479a22d853d61dadebd2dcf6037d391ec2d633660eb1a41` |
| SCOUTCE.8xp | 42,845 | `c8b3d44855f4467be4da378653c0345b46a99a96c4c4a2cbce438a628a64b04f` |

## Final integrated emulator checks

| Scenario | Evidence/result | Limit |
| --- | --- | --- |
| Pedro checkpoint_opening | PLAY mode check passed; production opening captured | Part of sequence captured |
| Pedro intro_checkpoint | DIALOGUE mode check passed after 18 seconds | Transition, not exact original timing |
| Pedro stage1_checkpoint | PAUSE mode check passed after walking/jump/attack inputs; screenshot shows aerial-kick instruction | One run; not physical crash reproduction |
| Pedro checkpoint_exit | Observed OS home-screen capture after Clear | No automated assertion; save reload not checked |
| Scouts checkpoint_play | 3/3 state assertions: play, one tower, paused | Short scenario |
| Scouts checkpoint_hungry | 4/4 state assertions including stage/tower/pause | QA entry, not campaign completion |
| Scouts checkpoint_exit | Observed OS home-screen capture | No automated assertion |

The corrected runner gives accepted OS key tokens an 80 ms emulation interval. Earlier undefined-program screens caused by launch races were harness failures, not established game crashes. Final runs above use the corrected runner. Logs report a 48 MHz CPU clock; clock selection alone did not solve Pedro performance.

## Targeted checks

| Check | Result | Scope/limitations |
| --- | --- | --- |
| Pedro combat | 20/20 passed, Nov 6 | Actual native player/enemy/projectile code with hardware stubs; selected regressions |
| Pedro runtime safety | 41/41 passed, Nov 6 | Enemy stats, encounters/tents, bounded death queue, guarded text buffers; aiming side effects stubbed; combat suite covers real projectile code |
| Pedro bank validation | 7/7 passed, Nov 6 | Complete/missing/truncated/empty/wrong signature/index/length fixtures |
| Pedro original data | 33 comparisons, zero differences, Nov 6 | 15 layouts, 6 arena tables, 12 dialogue events/28 pages; page text presence, not timing/order |
| Pedro native GraphX sprite cache | Passed, Nov 6 | 296 tiles, 150 selected actor frames both facings, 2 transparency fixtures; 102 large frames deliberately fall back; zero canary damage/roundtrip differences |
| Pedro native text | 2/2 passed during checkpoint work | Actual GraphX widths; dialogue/help and narrow-buffer stress, not every UI state |
| Pedro collision optimization | 341,077 comparisons | Zero interior differences; 4,084 top/left boundary differences (old negative fraction versus new zero) |
| Pedro progression | 29,678 checks, no failures during checkpoint work | Native profile rules with file-IO stubs; 277 quantization cases allowed up to 2.01 hundredths; not save-IO/timing proof |
| Scouts original rules | 120,030 checks, no failures | Numeric rules compared against original AS3 |
| Scouts maps/waves | Passed | 17 maps, 23 portals, 184 waves, 362 groups |
| Scouts resources/sky | Passed | 32 banks, 1,034 frame bounds, 153,600 optimized sky pixels |
| Scouts native engine | 19 cases passed | Source-derived targeted physics/skill/combat regressions |
| Scouts native decoder | 356 cases passed | Native decoder/canary fixtures, not every live scene |

Result JSON files retain additional scope and source hashes where supported. Historical v2 reports are not evidence for every change in these binaries. The runtime-safety fixture was updated to use an independent map buffer after production's map layout changed and to stub new external helpers; that repair changed the fixture, not game code.

## Performance and remaining validation

Last instrumented stage-one results: Pedro about 9 FPS; Scouts 24 FPS. Profiling variants differ from production by counters/overlay, so these are diagnostic measurements, not benchmarks of every packaged scene. Physical performance is unmeasured. No full original-versus-port campaign or hardware campaign was performed. No gameplay-fidelity percentage is supported.

Packaging checks ZIP integrity, exactly two program files, expected AppVar count, and records sizes/SHA-256 hashes in manifest.json. This verifies packaging consistency, not crash freedom or gameplay parity.
