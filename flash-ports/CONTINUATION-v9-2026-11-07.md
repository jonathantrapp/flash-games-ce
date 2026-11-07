# v9 Scouts memory and campaign preview, 7 November 2026

Scouts now shares Pedro's verified bounded formatter and caches an exact horizontal-movement quotient. Its production file shrinks to43,502 bytes; the running footprint including libraries falls to97,536 bytes. Crowded gameplay has54,844 bytes free, and the32KB-filler arTIfiCE win/save/relaunch run has21,982 free.

Native checks preserve gameplay state and pixels:130,560 movement comparisons,81,600 uncached-reference comparisons,816 food/pickup cases,44 engine assertions and272 full scenes pass. The scene reference keeps the old formatter independent. Input/speed checks and all17 stage entries pass on the selected production hash.

Overlay-free production measures10.83 FPS/approximately80 simulation ticks per second in quiet stage one. Crowded stage16 with29–34 enemies remains slow at1.50 FPS/16.17 ticks per second at requested4x. Graphics and gameplay were not reduced to obtain these numbers.

Real campaign progress now reaches stage4's unlock. Stage2 was won normally after stage1 on the preserved v8 binary. Stage3 continued from that unchanged earned save and was won on both v8 and v9 with legal skill/tower purchases, all9 waves cleared and all5 food retained. The combined v9 build also passes loss/retry and the arTIfiCE32KB-pressure saved-unlock round trip. Earned save files stay local and out of the package.

Read [the full evidence, hashes and limits](verification/CHECKPOINT-v9.md) and [developer handoff](HANDOFF.md). Archive-GC round-trip verification and later campaign stages remain open. Stage4 entry exposed an initial-cursor bound that needs fixing. Stage entries and the first3 wins do not establish a complete campaign.

Pedro remains the exact v7 program and resources, with flash sky and an optional temporary RAM cache. Its cached benchmark remains40.0 FPS stationary/21.15 moving; flash fallback37.0/19.49. No physical-calculator transfer or download took place. The user deferred physical crash investigation; Cesium and OS5.8 remain untested.
