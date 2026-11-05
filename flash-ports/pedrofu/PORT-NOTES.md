# Pedro Kicks Back CE

`pedrofu_unlocked.swf` identifies its original game as **Pedro Kicks Back**, by Hamumu Software (2012). This is a native TI-84 Plus CE adaptation built from inspection of the supplied SWF, not a Flash emulator or automatic bytecode conversion.

## Included

- All 15 original stage layouts, including the original back, solid and decoration tile layers.
- Original pixel art for terrain, Pedro and the basic Yak enemy, converted to a common 256-color palette.
- Scrolling camera, terrain collision, slopes and one-way platforms.
- Walking, crouching, double jumping, punches, aerial attacks, dash and area fury attack.
- Original mail locations and collectible placement; collect all mail in a stage to finish.
- Enemies placed from the original map entity layer, with simplified pursuing/jumping AI, health, hit stun and damage. Defeating tagged enemies opens corresponding tagged gates.
- Stage selection, retry, pause, next stage and saved recommended stage (`PDSAVE`). All stages remain selectable.

## Controls

| Key | Action |
| --- | --- |
| Left / Right | Walk; choose stage in menu |
| Up or 2nd | Jump; tap again for double jump |
| Down | Crouch |
| Alpha | Punch / aerial attack (holding repeats) |
| Math | Dash; uses fury |
| Del | Area fury attack; costs 40 fury |
| Mode | Pause; press again for stage menu |
| Enter | Start / resume / retry / next stage |
| Clear | Exit |

## Adaptation limits

This is a playable reduced adaptation, not a feature-complete reproduction. Original conversations, introduction, music, sound, skill trees, shops, extensive move unlocks, original enemy-specific animation/AI, projectiles and scripted boss/arena encounters are not reproduced. Enemy variants share Yak art and differ mainly in health/speed. Stages with no map mail finish when their placed enemies are defeated; original scripted enemy waves are omitted. Water and moving/breakable objects are simplified. The maps are retained, but full traversal and completion of all original layouts has not been verified; the stage selector provides direct access if an original scripted obstacle remains. Health, damage, fury costs and progression are adapted for this version.

## Build

`src/main.c` builds with CEdev using the included `makefile`. Run `build_assets.py` with Pillow available to rebuild the AppVars from the exported original images and compressed maps under `assets/`. The converter uses the workspace's CEdev `convbin.exe`. Transfer `PEDROCE.8xp`, every included `PD*.8xv` data file, and the CE runtime libraries. Data files are archived by default and the graphics are read directly from archive.

Original behavior was inspected in `original/scripts/xplor/MapStore.as`, `Pedro.as`, `PlayState.as`, `Level.as`, `LevelSet.as` and `TileSets/TileSet_Grave.as`. These establish original entity IDs, map compression/layer ordering, tile collision properties, sprite sizes and core movement mechanics. Actual calculator hardware testing remains necessary.
