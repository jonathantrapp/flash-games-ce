# Flash games adapted for TI-84 Plus CE

These are native C adaptations of the two supplied SWFs:

| Supplied file | Original game | Calculator program |
| --- | --- | --- |
| scoutcamp_unlocked.swf | Scouts vs Aliens | SCOUTCE |
| pedrofu_unlocked.swf | Pedro Kicks Back | PEDROCE |

The original games and extracted artwork are credited to Hamumu Software (2012), as identified by the supplied games. This folder contains the calculator implementation and local recovery work. The Flash files themselves cannot run on the calculator.

## Install

1. Extract `release/FlashGamesCE.zip` on your computer.
2. Connect the TI-84 Plus CE using USB and open TI Connect CE's Calculator Explorer.
3. Send the `.8xp` and `.8xv` files from the extracted package. Keep the `.8xv` files in archive. Each game's asset AppVars must accompany its program.
4. Launch `SCOUTCE` or `PEDROCE` through Cesium using your existing native-game setup.

If native games are not set up on your calculator, follow the current [arTIfiCE instructions](https://yvantt.github.io/arTIfiCE/) and obtain [Cesium](https://github.com/mateoconlechuga/cesium/releases). Compatibility depends on your OS and calculator revision; the linked project provides current instructions. There is no need to update the calculator OS to install these games.

The package includes the CE runtime AppVars used by the ports: `libload`, `graphx`, `keypadc`, and `fileioc`. Their upstream project is [CE Libraries](https://github.com/CE-Programming/libraries).

See each game's README for controls, implemented features, and differences from the original.

## Source and verification

Each game has its own directory and makefile. The existing NeuroFlappy project is separate. Builds use the workspace's portable [CE C/C++ Toolchain](https://github.com/CE-Programming/toolchain).

`smoke.py` runs the compiled programs in the local windowless CEmu runner using a caller-supplied ROM. Logs, JSON test sequences, and LCD captures are kept in `verification/`. Physical-calculator testing remains necessary to establish behavior on the user's hardware and OS.
