# v3 checkpoint status

The 6 November development checkpoint is ready for review. It is not a finished faithful port. Read [the completed/unfinished work report](CHECKPOINT-2026-11-06.md) and [verification results](verification/CHECKPOINT-v3.md).

Pedro's original opening reaches its first conversation in the production emulator build. The stage-one tutorial input scenario passes, and targeted text/resource/cache safety checks pass. Its roughly 9 FPS instrumented result is still inadequate; the physical revision-8/OS-5.8.2.29 RAM-clear report remains unverified. CEmu uses the older OS-5.3 ROM.

Scouts has checked original maps/waves/rules and targeted native regressions. Final production play/Hungry smoke checks pass; the last instrumented stage-one result is 24 FPS. Missing campaign UI, controls and ending work are listed in the checkpoint report.

No complete original-versus-port campaign or physical-calculator validation has been done. Historical checklist percentages are not gameplay-fidelity measurements. Further work should begin with crash reproduction and Pedro profiling, then full stage comparisons.
