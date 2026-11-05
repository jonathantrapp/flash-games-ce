# Scouts vs Aliens CE

Native calculator adaptation of the supplied `scoutcamp_unlocked.swf` (the title in the game is **Scouts vs Aliens**, Hamumu Software, 2012).

`bin/SCOUTCE.8xp` is the compiled TI-84 Plus CE program. Use the runtime libraries and launch instructions in the parent package README.

## Play

Choose any of the 17 stages with Left/Right and press Enter. Move the white building cursor with the arrows. Ground that can accept a tower gets a white cursor; invalid ground gets a red cursor. The faint dotted route shows the aliens' path. Aliens grab one of the camp's five meals and carry it back to a portal. Kill a thief to return its meal to the camp. Losing all five meals loses the stage; clearing all waves wins.

- **1 / 2 / 3 / 4:** select Rock Tower ($50), Roly Poly ($100), Snow Fort ($60), Shock Tower ($80).
- **2nd:** build at the cursor.
- **Enter:** upgrade the tower at the cursor; build if empty. Towers have five levels.
- **Del:** sell the tower at the cursor.
- **+:** send the next wave early, once the current wave has finished spawning.
- **Alpha:** pause/resume; opens controls on the stage menu.
- **Mode:** return to the stage menu.
- **Clear:** save stage victories and exit.

Snow slows enemies, Roly Poly does area damage, and Shock hits several nearby enemies. All stages are available immediately. Victory marks persist in the `SCTSV01` AppVar.

## Adaptation scope

Includes all 17 original map layouts and original enemy wave compositions/spawn intervals, original downsampled character/tower/tile artwork, scrolling side view, four base tower types, upgrades/selling, nine enemy appearances, cash rewards, food theft and recovery, stage victory/loss, and saved victory marks.

This is a smaller native adaptation, not a SWF player or a complete reproduction. Enemy movement follows routes computed through the original terrain with a preference for ground; the original physics, jump-arrow logic, and enemy special abilities are simplified. Attacks apply damage immediately and display brief shot lines. The original skill tree, branching tower evolutions, boss mechanics, sounds, music, menus, and cinematics are omitted. The first original terrain theme is reused across stages. Graphics are half-size, with a shared reduced palette. Economy and enemy scaling are adjusted, and at most 48 enemies/40 towers are active. Waves wait for the previous wave's spawning to finish before the next can start.

No complete balance pass or physical-calculator test has been performed. Native emulator validation is recorded by the parent package.

## Source and build

`src/main.c` is the native implementation. `src/data.h` contains generated level RLE, route tables, wave tables, and indexed artwork. `generate.py` rebuilds those tables from the supplied SWF's FFDec exports under `original/` and `assets/`. These files retain original third-party content and attribution; this private conversion does not grant redistribution rights.

From this directory, with the workspace-local toolchain:

```powershell
& ../../local-tools/cedev/CEdev/bin/make.exe
```

To regenerate data, Python 3.12 plus Pillow is required. The script currently locates Pillow in the workspace's `local-tools/plot-libs`.

```powershell
& 'C:/Users/jonat/AppData/Local/Programs/Python/Python312/python.exe' generate.py
python verify_data.py
```
