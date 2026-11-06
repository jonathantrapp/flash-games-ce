# Pedro regression checks

These tests use the actual native C sources with host hardware stubs or a standalone native GraphX diagnostic. They do not substitute for physical-calculator testing.

| Test | Scope |
| --- | --- |
| `check_profile.py` | Executes `profile.c`; compares skill damage, prerequisites, life/fury limits, XP and accumulated fury overflow against original AS3 rules. |
| `check_data.py` | Compares arena arrays, dialogue pages and all15 packed map layouts against original files. |
| `check_runtime_safety.py` | Includes actual `enemies.c`; tests nonfinal Master dialogue, orb/barrier gating, tagged tents, and maximum Combo Bombo chain. Extracts actual text functions with guarded96-byte local buffers. |
| `check_collision.py` | Compares actual optimized `move_body` to its saved pre-optimization implementation across all15 original solid layers plus an empty edge fixture, with deterministic random valid starts and velocities. |
| `check_bank_validation.py` | Executes actual `open_banks()` with complete, missing, truncated and empty AppVars. |
| `check_native_text.py` | Builds standalone `PDTEXT` and runs it in CEmu. Tests actual GraphX font widths and extracted text functions against28 original dialogue pages, current help and narrow-glyph stress. Memory hashes verify guard buffers and print coordinates. |

The host tests use the workspace's portable Zig compiler. The native diagnostic uses CEdev, the local CEmu console runner and the user's local ROM; none of these tools or ROM are part of a game release. Hardware/file stubs generated under `stubs/` are test-only. Compiler output and caches are ignored.

Every result JSON records the tested source hash where applicable. Rerun after source changes. A host test does not model the eZ80's24-bit `int` overflow or hardware library internals. Collision testing establishes preservation of earlier native movement semantics, not original Flixel equivalence. The initial optimized-collision run had341,077 valid starts and4,084 differences, all the old negative fractional boundary position(-15) versus new zero; no interior differences were found.

The initial crash-regression run reproduced text buffer writes outside96 bytes on synthetic narrow-glyph input; after bounds fixes, both host and native real-font tests passed. This does not identify the user's hardware crash trigger. Maximum Combo Bombo chains terminated and killed each of96 enemies once, but reached96 nested calls; depth is an observation, not proof of a stack overflow.
