# Original rule parity check

Run `python check_original_rules.py` from any directory after generating `src/rules.h` and `src/engine.h`. It uses the workspace's portable Zig host compiler.

The fixture compiles the actual generated native rules and actual `skillNeeded` function. Its independent expected values are evaluated from the original decompiled AS3, including original `int`/`uint` return coercion. It checks all12 towers,6 stat fields, levels0..5,246 skill profiles (uniform0..5 plus each individual skill at1..5), all48 skill unlock entries and10 monsters at levels0..64. Relative/absolute float tolerance is2e-6; integer return fields require their original integral values.

The result JSON records every difference with source line and input values. The initial expanded run found614 differences caused by native float return values where original AS3 returned integers; all monster and skill-unlock comparisons passed. Rerun after correcting the generator; this historical result does not establish the current implementation's status.

This checks numerical rule fidelity. It does not establish whether the game applies those rules correctly during projectile collisions, enemy AI, progression or the UI.
