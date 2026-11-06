# v6 performance preview, 6 November 2026

Pedro now exceeds 30 rendered FPS in the tested stationary-camera scene and reaches about 22 FPS in the tested movement/scrolling sequence. These are OS 5.3 CEmu results, not physical-calculator measurements or whole-game minima. Simulation remains at approximately 30 steps/second.

The renderer keeps original pixels while doing less repeated work. It stores exact sky rows in resident RAM, omits sky only where later opaque terrain covers it, caches unchanged notice-panel pixels, and repairs old sprite regions in each framebuffer when the camera stays still. Scrolling, changed terrain/scenery, frontend transitions and bounded-cache overflow trigger a full redraw. No original artwork or gameplay rules were replaced.

The timing work also corrected the baseline: the earlier 13 FPS diagnostic included a costly text overlay. With the overlay removed, the same v5 renderer measured 17.3 FPS stationary and 16.7 during the movement sequence. The comparable v6 profiling build measured 37.5 and 20.8. Production measurements use the actual packaged binary and normal opening; see [the v6 report](verification/CHECKPOINT-v6.md) and its timing JSON files for those results.

The native whole-scene fixture passed 600 comparisons against frozen v5, including retained frames, terrain/pickup changes, long notices and repair/scenery overflow. It caught a HUD-mail cleanup error during development; the corrected build passed with zero pixel differences and intact guards. This establishes tested native-renderer preservation, not Flash fidelity or campaign completion.

Scouts remains the exact v5 program. Both games retain the same data banks and original Hamumu credits. Replace programs and matching data together from `FlashGamesCE-v6-preview.zip`, preserving saves and unrelated calculator programs.

Still open: sustained 30 FPS while scrolling, crowded-battle minima, full original-versus-port campaigns and the physical revision-8 / OS-5.8.2.29 / arTIfiCE RAM-clear report. The rejected assembly/row-pointer experiment stopped at an OS MEMORY error and is excluded from the production build. No hardware crash fix is claimed.
