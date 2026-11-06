# Flash Games CE

TI-84 Plus CE ports of **Scouts vs Aliens** and **Pedro Kicks Back**.

The latest deliverable is the **6 November v3 development checkpoint**, not a finished port. [Download the calculator package](dist/FlashGamesCE-v3-checkpoint.zip), read [what was completed and what remains](flash-ports/CHECKPOINT-2026-11-06.md), and see [verification details](flash-ports/verification/CHECKPOINT-v3.md). Pedro's frame rate remains inadequate and the physical-calculator RAM-clear report is not proven fixed. No gameplay-fidelity percentage is claimed.

The original games and artwork are by Hamumu Software (2012). This repository tracks calculator port development and the supplied games' recovered reference material.

Both ports are native rebuilds written from the AS3 recovered with JPEXS: full-size original artwork, the original rules and formulas, enemy and tower behaviour, skill trees, conversations and scripted encounters. They are still works in progress. The [parity audit](flash-ports/PARITY-AUDIT.md) records what is checked by native tests, what is implemented but not yet verified in play, and what is not implemented. No percentage of parity is claimed.

Per-game notes, controls and known gaps: [flash-ports/scoutcamp](flash-ports/scoutcamp/README.md) and [flash-ports/pedrofu](flash-ports/pedrofu/PORT-NOTES.md).

## Development screenshots

Native calculator-emulator (CEmu) captures

Latest production checkpoint:

| Pedro opening | Pedro aerial-kick tutorial | Scouts |
| --- | --- | --- |
| ![Restored opening](docs/screenshots/pedro-v3-opening.png) | ![Tutorial](docs/screenshots/pedro-v3-tutorial.png) | ![Scouts](docs/screenshots/scout-v3-gameplay.png) |

| Scouts vs Aliens | Pedro Kicks Back |
| --- | --- |
| ![Scouts title](docs/screenshots/scout-title.png) | ![Pedro title](docs/screenshots/pedro-title.png) |
| ![Scouts gameplay](docs/screenshots/scout-gameplay.png) | ![Pedro stage map](docs/screenshots/pedro-map.png) |
| ![Scouts skills](docs/screenshots/scout-skills.png) | ![Pedro gameplay](docs/screenshots/pedro-gameplay.png) |

## Build environment

The project uses the [CE C/C++ toolchain](https://github.com/CE-Programming/toolchain), GraphX, keypadc and fileioc. Makefiles expect a workspace-local portable toolchain at `local-tools/cedev/CEdev` and game projects under `flash-ports/`. Asset converters require Python 3.12 with Pillow. Each program needs its resource AppVars alongside it (`SCAxx` for Scouts, `PDxxx` for Pedro); `flash-ports/package.py` assembles the transfer package.

## Credits

Scouts vs Aliens and Pedro Kicks Back were created by Hamumu Software (copyright 2012, [hamumu.com](http://hamumu.com)); the original music is by Nosoapradio.us. This is an unofficial fan project and grants no rights to the original games, artwork or music. See [flash-ports/CREDITS.md](flash-ports/CREDITS.md) for the full list, including the tools used.
