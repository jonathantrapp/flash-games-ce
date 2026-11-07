# v8 Scouts route and rendering preview, 7 November 2026

Scouts now gets past two stage-one slope collision blockers. A production run can lose all five food items, retry, and win all six waves with two normally purchased rock towers. Saving, exiting through arTIfiCE, reselecting with DOWN and relaunching preserves the stage-two unlock. The same round trip passes with a32KB RAM filler. This is stage-one campaign evidence, not a complete campaign.

The renderer keeps the original pixels while drawing cached tiles and HUD more directly. Native checks cover272 whole scenes and 358 art montages, with nonzero cache guards in the scene suite. Coordinate caches pass 81,600 comparisons against an uncached collision-corrected reference; food pickup passes 816 comparisons against frozen v7. All44 engine assertions,8 speed-control checks, input-timing checks and 17 stage entries pass.

The production program measures 10.17 FPS and80 simulation ticks/s in quiet stage one. Crowded stage16 with 28–32 enemies reaches only 1.33 FPS and15.83 ticks/s at requested4x; enemy physics remains the main cost. These are overlay-free CEmu OS5.3 measurements. Free RAM is about48KB, or15.3KB in the32KB-filler saved-unlock run.

Pedro is unchanged from v7: flash sky with an optional disposable RAM cache, smaller formatter and107,871-byte running footprint. Its cached production benchmark remains40.0 FPS stationary and21.15 moving; filler-selected flash measures37.0/19.49. Preserve `PDPROG2`; `PDSKYTMP` is disposable. The user deferred physical crash investigation, and no download or physical transfer took place.

Read [the v8 evidence, hashes and limitations](verification/CHECKPOINT-v8.md), [Pedro's v7 evidence](verification/CHECKPOINT-v7.md) and [the developer handoff](HANDOFF.md). The package contains only the selected production programs, matching banks, libraries and notes. No ROM, RAM capture, save, filler or experimental build is included.

Next: later campaign wins and save/archive-GC coverage, crowded physics and exact-pixel rendering performance, then Pedro scrolling. Cesium, OS5.8 and physical stability remain untested.
