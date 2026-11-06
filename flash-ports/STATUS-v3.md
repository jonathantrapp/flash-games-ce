# Fidelity rebuild status

This is development work, not a finished v3 release. Do not use a checklist percentage as a gameplay-fidelity measurement.

Pedro's stage-1 freeze/RAM-clear report came from a TI-84 Plus CE hardware revision 8 running OS 5.8.2.29. The local emulator uses the user's older OS 5.3 ROM. The exact reported crash has not yet been reproduced on that hardware.

Completed and checked changes include text-buffer bounds and screen-coordinate guards, Master encounter activation, tagged-orb barrier checks, enemy stat corrections, bounded death-chain processing, original tent spawn sequences, and version/size validation of calculator resource banks. Existing host and native test outputs identify their exact source revisions.

The original burning-blimp flight, explosions, parachute descent, landing and canopy-collapse code is integrated. Native captures show the blimp and descent; completion and replay tests are still in progress.

Performance remains a release blocker. Pedro measured about 8 FPS in the initial instrumented emulator build; the first RAM sprite-cache test measures about 9 FPS. Lossless rendering experiments are being compared, and slower or unstable variants are excluded from release packaging. The current task is to improve the measured frame budget while preserving original pixels and mechanics.

Scouts has exact map/wave validation and corrected skills, baby speeds, build visuals and resource checks. Its newer fidelity simulation and rendering are also under profiling; its performance target has not been met.

No new finished release is claimed. Physical-calculator validation and complete original-versus-port stage playthroughs remain outstanding.
