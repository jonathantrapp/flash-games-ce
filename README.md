# Flash Games CE

TI-84 Plus CE ports of **Scouts vs Aliens** and **Pedro Kicks Back**.

Project owner and contributor: [Jonathan Trapp (@jonathantrapp)](https://github.com/jonathantrapp).
The original games and artwork are by Hamumu Software (2012). This private repository tracks calculator port development and the supplied games' recovered reference material.

The ports are undergoing a substantial fidelity rebuild. The first builds reproduced basic gameplay but omitted major systems. Current work restores original skills, upgrades, enemy behaviors, projectiles, conversations, scripted encounters and full-size artwork. No percentage of parity is claimed.

The [parity audit](flash-ports/PARITY-AUDIT.md) records original behavior and required acceptance checks. The per-game notes and source are in [flash-ports/scoutcamp](flash-ports/scoutcamp) and [flash-ports/pedrofu](flash-ports/pedrofu). Notes describing the earlier reduced builds will be updated alongside verification.

## Development screenshots

These are native calculator-emulator captures from the full-size Scout artwork milestone, not browser mockups.

![Scouts title](docs/screenshots/scout-title.png)
![Scouts gameplay](docs/screenshots/scout-gameplay.png)

## Build environment

The project uses the [CE C/C++ toolchain](https://github.com/CE-Programming/toolchain), GraphX, keypadc and fileioc. Current makefiles expect a workspace-local portable toolchain at `local-tools/cedev/CEdev` and game projects under `flash-ports/`. Asset converters require Python with Pillow. Calculator resource AppVars must accompany each executable.

The local native test harness uses CEmu with a user-supplied calculator ROM. ROMs, authentication data and unrelated workspace projects are excluded from this repository. Original-runtime comparison uses the official Ruffle web package locally.
