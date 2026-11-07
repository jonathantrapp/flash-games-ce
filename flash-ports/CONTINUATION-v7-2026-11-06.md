# v7 RAM and input preview, 6 November 2026

Pedro now starts with a smaller executable and chooses its sky path from available RAM. The original rows remain in flash; when memory permits, a disposable `PDSKYTMP` AppVar restores the faster row-copy path. Save operations refresh the RAM pointer, and exit deletes the cache. A stale cache from a crash gets discarded and rebuilt at startup. Keep `PDPROG2`; `PDSKYTMP` is not a save.

The running footprint, including relocated libraries, falls from 151,597 to 107,871 bytes. Empty-emulator gameplay with the optional cache has 6,867 bytes free. With an 8 KB RAM filler, Pedro selects flash and retains 36,368 bytes. These are emulator results, not a physical crash fix. The user deferred that investigation; no transfer or download took place.

On the packaged binary, normal-opening benchmarks measure 40.0 FPS stationary and 21.15 moving with the cache, or 37.0/19.49 when the filler selects flash. Simulation stays around 30 Hz. The previous v7 movement result was 21.8 FPS. This preview improves memory headroom; it does not establish 30 FPS scrolling.

Scouts' high-water marks now pass its native engine fixture, gameplay input/speed tests and all 17 stage entries. Quiet stage one reaches 80.33 simulation ticks/sec at requested 4x. Crowded stage 16, with 25–29 naturally spawned enemies, reaches only 14.5 ticks/sec. The render experiment has not passed its pixel fixture and is excluded from production. Campaign wins/losses/retries and unlocks remain unverified; the no-tower stage-one run did not lose even after 150 emulated seconds.

Read [the evidence and failed-check details](verification/CHECKPOINT-v7.md). The two packaged programs have matching final stage-entry metadata; all 15 Pedro entries pass as well. Native tests cover both sky paths, exact pixels/canaries, the formatter's CE ABI and buffer limits, and cache lifecycle failures/relocation.

`FlashGamesCE-v7-preview.zip` contains the production programs and unchanged matching data banks/libraries. Its manifest, `SHA256SUMS.txt` and adjacent ZIP checksum identify the contents. Preserve saves and unrelated calculator programs when updating. The opt-in hardware diagnostic, RAM fillers, ROM and raw RAM captures are not in this package.

Next work: Scouts' crowded simulation/rendering cost, the failed pixel-fixture accessor path, genuine campaigns and save/archive-GC round trips, then Pedro scrolling performance. Physical OS 5.8/Cesium investigation waits for the user's request.
