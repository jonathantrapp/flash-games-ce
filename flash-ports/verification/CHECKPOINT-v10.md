# v10 work in progress: Scouts stage-4 start cursor, 9 November 2026

## Change

`startLevel()` in `scoutcamp/src/combat.h` placed the building cursor four columns right of the first portal, with no bounds check. On stage 4 (53 x 16 tiles) that put it at column 55, off the map, so it was not drawn until the player tapped LEFT. The cursor is now clamped at level start to the same range the movement code in `main.c` already uses (columns 1..width-2, rows 1..height-2). No other gameplay, art or data changed.

The starting column itself (portal + 4) is a port choice: the original game uses the mouse and has no keyboard cursor. So this is a port bug fix, not a parity change.

## Evidence

| Check | Result | Scope |
| --- | --- | --- |
| `scoutcamp/tests/check_start_cursor.py` | pass. Stage 4 is the only clamped stage (raw 55,9 -> 51,9); the other 16 start positions are unchanged. | Formula check against the original level files, plus a check that the clamp is in `startLevel`. It does not run the game. |
| `verify_stages.py scoutcamp --tag v10_cursor --bin-dir bin_v10cursor` | 17 of 17 pass ([STAGE-SMOKE-v10_cursor-scoutcamp.md](STAGE-SMOKE-v10_cursor-scoutcamp.md)) | Launch and survival with scripted builds, as in earlier versions. Not completability. |
| Stage-4 entry with no cursor input, v10 candidate vs v9 `bin/` (`v10_cursor_stage04_idle`, `v9_control_stage04_idle`) | Both stay running on stage 4. v10 shows the cursor at the right of the camp; v9 shows none. | One CEmu frame each, inspected by eye. |

Candidate: `scoutcamp/bin_v10cursor/SCOUTCE.8xp`, 43,569 bytes, SHA-256 `b78bf3e9f2012484fde373e86977085500d4dbe19068be4cb981a9fa003e841a` (v9 was 43,502 bytes). Its SCA banks are byte copies of the v9 banks.

Screenshots: `docs/screenshots/scout-v10-stage4-cursor.png` (fixed) and `scout-v9-stage4-nocursor.png` (control).

## Not done

- The candidate has not been promoted to `scoutcamp/bin/`, packaged or released. v9 remains the published build and still has the bug.
- The native fixtures (physics, movement, render, engine) were not rerun. They don't use `startLevel`'s cursor, but that is an inference, not a run.
- No stage-4 win, no physical calculator run, no Ruffle comparison.
