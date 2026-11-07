# v9 playable preview: Scouts RAM and campaign progress

This preview includes both native TI-84 Plus CE games and all required data/runtime AppVars. Replace the programs and all supplied banks together; preserve your saves. See START-HERE.md in the ZIP for setup and controls.

Scouts uses 6,696 fewer running bytes than v8, leaving 54,844 bytes free in the crowded emulator sample. Native checks pass 130,560 movement comparisons, 81,600 uncached-reference comparisons, 816 food cases, 44 engine assertions and 272 exact full-frame scenes with canaries. Input, speed controls and all17 stage entries pass. Actual campaign play has cleared stages1–3; stage3 was repeated on this v9 build from an unchanged earned save. Loss/retry and saved unlock under32KB RAM pressure also pass.

Pedro is the unchanged validated v7 program: flash sky fallback, optional temporary RAM cache, 40.0 FPS stationary/21.15 moving with the cache. Its native render/scene/formatter checks, stage entries and arTIfiCE/RAM-filler scenarios are documented in the repository.

These are development previews tested in CEmu OS5.3 at48MHz, not hardware-certified builds. Scouts crowded stage16 remains slow (1.50 FPS/16.17 simulation ticks per second at requested4x). Stage4's initial cursor starts beyond the right edge; tap LEFT once to bring it onto the map. Later campaign completion, archive-GC round trips, Cesium and OS5.8 remain unverified. Physical crash investigation is deferred.

The ZIP has2 programs,61 data AppVars,4 runtime libraries and documentation. No ROM, raw RAM, saves, fillers, diagnostic or experimental builds are included. The adjacent .sha256 file and the ZIP's manifest/SHA256SUMS identify the exact tested binaries.

ZIP SHA-256: `6d31aa31478fcfd32db4e9e6438f50841b603343e7b312d2df4adb1ce9d69e03`
