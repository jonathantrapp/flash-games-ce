# v5 development preview, 6 November 2026

Continues v4 at `db136ad`. Both games still need full original-versus-port campaigns and physical-calculator testing. No gameplay-fidelity percentage is available.

Pedro's actor cache now holds six 1,600-byte sprites instead of eight 1,024-byte sprites. This admits original tree and hit-spark frames that previously fell back to archive drawing. The sampled stage-one profiling scene rose from 12 to 13 rendered FPS while retaining 30 simulation steps/second. It remains too slow. The renderer keeps the original sprite pixels; native framebuffer comparisons cover terrain, HUD clipping and actor-cache eviction, with buffer guards.

The user clarified the RAM-clear report: **revision 8, OS 5.8.2.29 / ROM 5.6.1.6; launch through arTIfiCE, then arrow input after the kick instruction**. New OS 5.3 CEmu runs reach that instruction and continue to the Yak conversation using arrows. They don't reproduce the reset. We still lack a matching local OS 5.8 ROM and a hardware run through that launcher, so this preview does not claim to fix the physical failure.

Scouts now queues keypad transitions during drawing and between simulation steps. A roughly 125 Hz scan limit avoids the large cost of scanning at every checkpoint, and cursor repeat uses a 200 ms timer instead of counting rendered frames. Nine plus taps at each tested press/release interval (220/150, 80/80 and 40/40 ms) reached the 4× setting and survived freeze/restore, without queue overflow. Those finite tests don't establish arbitrary rapid-input reliability under every battle load.

Measured Scouts throughput still falls short of the speed label. Otherwise identical 7-second and 1-second runs differed by 119 ticks at 1× and 269 at the requested 4× setting: about **19.8 and 44.8 ticks per emulated second**, respectively. The requested rates are 20 and 80. These are OS 5.3 emulator measurements for one stage-one setup, not physical results or crowded-battle minima.

See [the v5 verification report](verification/CHECKPOINT-v5.md) for hashes, screenshots, test scopes and remaining work. The local browser comparison stopped because Computer Use could not verify Brave's URL; browser control was disabled in Work settings. No original-versus-port campaign playthrough was completed in this continuation.

Install `FlashGamesCE-v5-preview.zip`, replacing the programs and all matching data together. The 19 PDB banks, Pedro's nine separate art/palette/tile AppVars and 33 SCA banks retain v4's content. Preserve `PDPROG2`, `SCTSV02` and unrelated calculator programs. Original games and artwork: Hamumu Software.
