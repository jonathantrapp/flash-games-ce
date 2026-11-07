# Pedro Kicks Back CE

`pedrofu_unlocked.swf` identifies its original game as **Pedro Kicks Back**, by Hamumu Software (2012; see [CREDITS.md](../CREDITS.md)). This is a native TI-84 Plus CE rebuild from the AS3 recovered with JPEXS, not a Flash emulator or an automatic bytecode conversion. It is a work in progress; the [parity audit](../PARITY-AUDIT.md) lists what is verified and what is not.

## What is in this build

- All 15 original stage layouts (back, solid, decoration and marker layers) with original tile collision, slopes and one-way platforms.
- Full-size original art: Pedro, the Yak clan, projectiles, props, powerups, HUD, title, world map and sky. Frames, offsets and hitboxes come from the original `loadGraphic` and constructor values.
- A 30 Hz fixed-step simulation driven by a hardware timer, so game speed no longer depends on how long a frame takes to draw.
- Persistent profile (`PDPROG2`): level, XP, skill points, 45 skill ranks, discovered techniques, collected hearts and Fury Souls, passed stages and best times. Stages unlock in order as on the original map.
- Original progression rules: XP to level is `level*10+50`, Fancy Footwork bonus, one level per gain, heart and Fury Soul maxima, skill prerequisites (3 points per earlier rank in the same set).
- Move set gated by skills: punch chains, Gale Fist, Burro Bash with grab/carry/throw, Piledriver and Atomic Piledriver, burning Pedroken, flying/dive/charge/tornado kicks, dodge, Retaliate, and the four Fury abilities (blast, freeze, frenzy, fix) with Fury Overload and Fury Master. The earlier invented double-jump and glide were removed after checking their actual activation paths in the original source.
- Enemy classes with their own state machines: Yak, Bruiser, Armor, Archer and Elite Archer, Ninja, Yakolyte, Iron Priest, Torgo/Robot, Master Yak, Barrier Orbs and the Barrier object. Projectiles include arrows, ninja stars, homing shots, rock spikes, ground fire and pike slashes.
- Stage scripts: tents that spawn Yaks, the five-round mail arenas on stages 11 and 14 (timed bonuses and rewards), tag gates, the Master Yak finale with respawning orbs, and the original conversations (28 pages across 12 events) with their gameplay side effects.
- Title, stage map, skill screen (original layout and artwork), help, pause, defeat, victory and ending screens.
- Original descriptions for all 45 skills, calculated with live bonuses, with current/next-rank previews. ALPHA opens details; Left/Right changes preview, Up/Down scrolls, ALPHA or MODE closes. ENTER learns and DEL refunds as on the grid.

## Controls

| Key | Action |
| --- | --- |
| Arrows | Run; hold Down to duck; double-tap a direction for Burro Bash (once learned) |
| Up or 2nd | Jump |
| Alpha | Punch; in the air, kick; duck + Alpha for Pedroken; hold to grab/carry after a Burro Bash |
| Down (in the air) | Dive kick |
| Del | Fury. With a full Fury bar, hold Del and press Down (blast), Left (freeze), Right (frenzy) or Up (fix) |
| Mode | Pause (Enter resume, Stat skills, Mode back to the map) |
| Stat | Skills (from the map, pause and result screens) |
| Enter | Confirm, advance conversation, next stage |
| Clear | Save and exit |
| Vars (held on the map) | QA only: opens any stage regardless of progress |

## Not done, or not verified

- v7 replaces the resident sky stream and nanoprintf to reduce the running footprint, including libraries, to 107,871 bytes. Flash is the base sky path; an optional `PDSKYTMP` RAM cache accelerates exact row copies when memory permits. It is disposable and contains no save data. Final CEmu measurements: 40.0/21.15 FPS stationary/moving with the cache, 37.0/19.49 with an 8 KB filler selecting flash. The sampled free RAM is 6,867 bytes with the cache or 36,368 with that filler. See [v7 verification](../verification/CHECKPOINT-v7.md); scrolling30FPS and physical stability remain unverified. The user deferred physical-crash diagnostics.

- The original burning-blimp flight, explosions, parachute descent and canopy collapse are now integrated before the opening conversation. Native captures and the checkpoint test cover that transition. Fire scaling, additive alpha and camera effects are approximated.
- v6 rendering exceeds 30 FPS in the tested stationary-camera scene and reaches about 22 FPS in the movement sequence. Exact sky rows, cached notice pixels and per-framebuffer repair regions preserve tested native pixels. Earlier v5's 13 FPS included a costly diagnostic overlay; its comparable overlay-free baseline measured 17.3 FPS stationary / 16.7 moving. See [v6 verification](../verification/CHECKPOINT-v6.md). Scrolling still falls short of sustained 30 FPS, and physical performance remains unverified. The RAM-clear report after arrow input at the kick instruction, launched through arTIfiCE on revision 8 / OS 5.8.2.29, remains unresolved.
- No music or sound (the calculator has none); screen shake and some flash effects are omitted.
- Skill descriptions now use original text/formulas; integer formatting can differ by 0.01 from Flash floating-point rounding. Hover/history and some options/tooltip presentation remain different.
- Move timing, hitboxes, enemy AI and boss phases are translated from the AS3 but have not been compared frame by frame with the original running in Ruffle. Stages are verified to load and run in the emulator, not to be completable.
- Not yet tested on a physical calculator.
- Numerical rules (XP, level-ups, damage multipliers, prerequisites, maxima, Fury Overload) are checked against the original formulas by `tests/check_profile.py` (see `verification/RESULTS.md`).

## Build

`makefile` builds `PEDROCE` with the workspace CEdev. Assets are generated, in this order, with Python 3.12 and Pillow (`local-tools/plot-libs`):

1. `build_assets.py`: stage maps (`PDLV01..15`) and base tiles.
2. `build_full_assets.py`: original sprite sheets, UI art, palette, skill metadata (`src/resources.h`, `src/ui_resources.h`, `src/skill_meta.h`).
3. `build_intro_assets.py`: blimp, explosion and burning-uppercut frames using the existing palette.
4. `build_row_sky.py`: exact row offsets/colors and the optional resident reference stream. Production defines `SKY_FLASH_ROWS` and reconstructs an optional temporary cache from the archived sky halves. `build_render_cache.py` retains the historical row-fill/RLET representation used by the v5 comparison fixture.
5. `bundle_assets.py`: packs the small resources into 19 signed banks of at most 32 KB (`PDB00..`) and writes `src/bundle.h`.
6. `build_skill_descriptions.py`: generates original live skill descriptions and checks every numeric intermediate against signed24-bit limits.

Transfer `PEDROCE.8xp` with every `PD*.8xv` file and the CE runtime libraries. In-play saves stay in RAM; clean exit archives `PDPROG2` after drawing has stopped, so resource pointers are no longer used if flash garbage collection occurs.

The default compact build is required. `ram_guard.ld` rejects resident programs that overlap GraphX's LCD buffers; an experimental whole-program `-O1` build exceeded this bound. Other speed experiments that reset the emulator are excluded from releases. RAM HUD caching reserves bounded worst-case GraphX conversion sizes and keeps cropped meters clipped.

Original behaviour was read from `original/scripts/xplor/` (`MapStore.as`, `Pedro.as`, `Monster/*.as`, `Profile.as`, `Menus/*.as`, `Arena.as`, `Conversation.as`).
