# Scouts checkpoint

Production program: `bin/SCOUTCE.8xp`, 42,845 bytes. Resources: all 32 `SCA00` through `SCA31` AppVars, bundle signature `8f6377cb` (version SCA3).

The linked code section is 60,386 bytes (below 64 KiB). The decompressed resident program ends at `0xD2DB41`; fixed BSS ends at `0xD13535`, leaving 2,723 bytes in the configured allocator region. Hot graphics buffers are bounded static arrays.

This checkpoint fixes large-health and long-shot 24-bit arithmetic overflows, bounds Megawatt chain damage without recursion, validates resource versions/sizes before drawing, clamps loaded profile fields, clips text, restores original jump/gravity substeps, Hungry baby rates and shrinking, Free Pebbles, global sale freeze and the original conversion refund basis. It uses exact row-fill/RLET sky rendering and common-tile RAM caches. Projectile flight/pop frames, projectile hit bounds, homing speeds, rolling/falling motion and per-enemy status timers were corrected.

Last native stage-1 performance capture: `../verification/scoutcamp/perf_48mhz/screen.png` (24 FPS). The performance build contains counters; the production build does not. Final production integrated checks passed: checkpoint_play (3 assertions), checkpoint_hungry (4 assertions), and an observed return to the OS home screen. These use the corrected/relinked console runner.

Passed: 17 byte-exact maps; 23 portals; all 184 waves/362 groups; 32 resource files/1,034 frame bounds; 153,600 optimized sky pixels; 120,030 rules; 19 native engine regression cases; 356 native experimental decoder cases. Earlier full-stage smoke checks apply to the preceding binary and are not a complete test of this one.

Not finished: original title-to-campaign-map/options flow and animated ending; speed slider; focus-fire selection; original per-skill tooltip text in the UI; precise tower firing animation timing; full behavioral comparisons/playthroughs and physical-calculator validation. `generate_ui.py`, `menu_data.h` and `skill_text_index.h` are preparation only and are not integrated into the program.
