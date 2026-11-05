# Original-game parity audit

This is a source-bound scope and acceptance checklist, not a claim of completed parity. The supplied games are Hamumu Software's **Scouts vs Aliens** and **Pedro Kicks Back** (2012). JPEXS recovered their AS3 into `*/original/scripts/xplor`. A checked acceptance item requires implementation inspection and a relevant native test. New native implementations were still in progress when this checklist was written.

The earlier native releases recovered maps and basic gameplay, but did not meet close reproduction of original mechanics. A percentage cannot be inferred from number of maps, successful launch, or similar screenshots.

## Status (2026-11-05)

This section summarizes the checklist below; it is not a parity percentage. The checklist items stay unchecked unless both source inspection and a relevant native test exist.

**Verified by native tests**
- Scouts rules: all 12 towers x 6 stat fields x levels 0..5 under 246 skill profiles, all 48 skill prerequisite entries, and 10 monsters at levels 0..64 match values evaluated from the original AS3 (`scoutcamp/tests/check_original_rules.py`, 120,030 checks, 0 differences).
- Pedro rules: per-move damage with berserk/rage/maximum-force modifiers, skill prerequisites, life and fury maxima, XP and level-up (including the original one-level-per-gain behaviour and level 99) and Fury Overload match the original (`pedrofu/tests/check_profile.py`, 29,678 checks, 0 differences).
- Both games build, launch in CEmu, and every stage opens and keeps running (`verification/STAGE-SMOKE.md`). This is launch and survival only.

**Implemented from the original source, not yet verified in play**
- Scouts: wave scheduling and concurrent waves, food dropping and re-grabbing, alien physics and jump markers, all alien specials, the 12 towers' projectile behaviour, branch conversions, status effects, the skill screen and save file.
- Pedro: the complete move set and Fury abilities, enemy state machines, the mail arenas, tag gates, Barrier and Master Yak finale, dialogue events with their side effects, profile persistence, stage unlock order.

**Not implemented**
- Pedro: the intro blimp flight, crash and parachute sequence.
- Both: sound and music, mouse-style focus fire and alien targeting (Scouts), the speed slider and freeze-time key (Scouts), skill description text, screen shake and similar effects.
- Both: frame-by-frame comparison against the original running in Ruffle, and physical-calculator testing.

## Shared acceptance gates

- [ ] Original title, map screen, options, pause, retry, win/ending and skill screens are reachable; keypad substitutes have clear equivalents.
- [ ] Original map dimensions and all four layers decode byte-exactly for every stage.
- [ ] Original graphics use correct frame sizes, offsets, palettes and layering. Actor collision boxes are not replaced by artwork bounds.
- [ ] Physics and timers advance in elapsed simulation seconds, with a stable tick, independent of expensive drawing. Compare displacement, jump apex and shot cadence over measured time.
- [ ] Archive resources fit calculator flash and active RAM; menu transitions and saving do not invalidate asset pointers.
- [ ] Save data retains original progression and all unlocked/reward flags across exit/relaunch.
- [ ] Each stage's intended win condition can be achieved with ordinary controls. Direct stage selection is useful for QA, but is not a substitute for correct unlock progression.
- [ ] Representative original/runtime and native screenshots are captured for title, menu, early gameplay, upgrade/skills, special enemy encounter and final battle. Visual resemblance alone does not prove behavior.
- [ ] Physical TI-84 Plus CE testing validates controls, frame rate, asset transfers and shell/OS compatibility.

## Scouts vs Aliens

All source references below are relative to `scoutcamp/original/scripts/xplor/`.

### Stage flow, waves and progression

- [ ] 17 maps and the precise `WaveDef` schedules, preserving group count/type/interval triples (`Level_Wave.as:58-82`).
- [ ] Concurrent active wave spawning. `WaveManager.as:81-142` maintains an array of active waves; a newer wave can start before an earlier wave finishes spawning. The first native version prohibited this.
- [ ] Scheduled wave time is absolute `timePerWave * waveIndex` from stage start (`WaveManager.as:60-78`). Manual early-send accelerates future timers, and On A Roll pays `(waveNum+1)*skill*2` (`WaveManager.as:97-115`, `154-158`).
- [ ] Enemy level at birth is `stage*3 + waveNum - activeWaves.length + activeWaveIndex + 1`, minus `stage` for stages below index4 (`WaveManager.as:127-132`). Enemy health/money formulas use this level. Do not substitute `stage*2+wave`.
- [ ] Initial money is `(120 + stage*20)*(1 + BigBucks*0.1)` (`Player.as:84-85`). Skill effects, enhancement discount, money/XP gains and saved level/skill points must match.
- [ ] Initial stage tip pauses gameplay; victory waits for all wave spawns and living enemies to finish, defeat occurs when foodLeft reaches0 (`PlayState.as`, `PlayUpdate`).
- [ ] First 4 stages, next4, next4, last4 and final stage use their original sky/song progression; the source always constructs the same `TileSet_Grave` atlas. Different-looking map regions should not be remapped arbitrarily.

### Food and alien movement

- [ ] Five separate food objects at camp, with their own positions and holders (`MapStore.as:111-136`).
- [ ] Killing a food carrier drops its food at the death location. Nearby aliens may acquire that food; food does not instantly teleport to camp (`Monster/Food.as:62-99`). A jumping alien cannot grab food (`47-60`).
- [ ] Food escapes through a portal via `BaseMonster.EnterPortal`, reducing the total. Food-carrying aliens reverse their advance direction and use refrigeration/poison trap modifiers.
- [ ] Alien collision/jumps use the original layer and marker values3..11, gravity, wall/fall tests and direction/goal rules (`Monster/BaseMonster.as:502-623`, `672-806`), rather than precomputed shortest routes.
- [ ] Ground jump velocity is `-90 - 30*(jumpStrength-1)`, horizontal jump speed35; normal speeds and collision dimensions come from each alien class.
- [ ] Slopes and per-tile collision properties retain the original `TileSets/TileSet_Grave.as` semantics.

### Enemy roster and specials

- [ ] Lumpy, Squirmy, Beefy, Beasty, Wormy, Speedy, Blinky, Scary, Hungry and HungryBaby have original health/money/speed formulas, bounds, animation sets and XP. The full formulas and methods are indexed in `../scoutcamp-mechanics-spec.json`.
- [ ] Wormy is immune while grounded/on slopes unless disabled; becomes vulnerable while jumping/falling (`Monster/Wormy.as:47-193`). This is strategically essential.
- [ ] Blinky heals other living allies within60 by `level` every0.5s, unless disabled (`Monster/Blinky.as:58-85`).
- [ ] Scary blocks firing of towers within60 every0.25s: `noFire=0.3`, preserves previous reload then resets it while blocked (`Monster/Scary.as:57-87`, `Monster/Tower.as:184-195`).
- [ ] Hungry has `250+level*90` HP, speed2; at successive1% health-loss thresholds it spawns three babies with speed multipliers2,1,0.5 at most once/sec, increments baby level, shrinks and consumes carried food within10 (`Monster/Hungry.as:40-144`). Hungry's `GotFood` deliberately does nothing.
- [ ] Freeze, slow, ability-disable, shock, cripple, poison, flatten, fling and status immunity interactions are ported from `BaseMonster.as:808-942`, not represented by one generic stun.

### Towers, projectiles and skills

- [ ] Four base towers with level index0 through5. Displayed level is index+1; original damage/reload/range/cost formulas use the index. A tower begins with build time2 and visual growth (`Monster/Tower.as:145-179`).
- [ ] Eight branch conversions, gated by learned skills: Rock→Sling/Soapbox; Roll→Crusher/Quake; Snow→Ice/Slushee; Shock→Crippler/LightningRod (`Player.as:1081-1164`). Converted towers retain level and invested cost. Selling uses spent/2 with skill adjustments.
- [ ] Rock/Sling arc/penetration, rolling and falling boulders, snow/ice/slush shots, lightning and cripple beams, and quake targeting use their original geometries and hit callbacks. A line effect plus instant generic damage is not the original projectile mechanic.
- [ ] Soapbox buffs nearby towers; Slushee/Crusher target below; LightningRod targets above; Crippler affects vulnerability and disables enemy specials. Tower targeting excludes immune enemies except specified exceptions (`Monster/Tower.as:199-201`).
- [ ] All48 skill entries across four trees are present (`Menus/SkillState.as:24-26`, `SkillDef.as`). Maximum rank5. Rank unlock requires3 points per rank spent in earlier ranks of the same group; branch skills also require the relevant base tower skill (`SkillState.PointsNeeded`).
- [ ] Every skill effect is connected to simulation, not only named in the skill menu: construction/enhancement/economy, range/fire rate/damage, crit/finisher, freeze/slow interactions, shock/chain/cripple/death explosion, rolling/flattening and trap synergies.

## Pedro Kicks Back

All source references below are relative to `pedrofu/original/scripts/xplor/`.

### Original stage-completion blockers

- [ ] Stage indices10 and13 start with five mail still required even when no mail is placed in the map (`MapStore.as:105-108`). These are five-round arenas, not generic kill-all stages.
- [ ] Arena spawn arrays, locations and time bonuses match `Arena.as:11-21`. Stage10 uses10 spawn slots and time limits30,30,60,60,80; stage13 uses13 slots and40,60,90,90,120. Each round requires all tag1 enemies cleared, then creates one mail item (`Arena.as:67-92`, `174-190`).
- [ ] Arena timed rewards prioritize heart, undiscovered fist/feet/fury technique, then `(round+1)*50` XP; expiry removes bonus but does not prevent advancing (`Arena.as:114-137`).
- [ ] Stage14 starts with1 mail required. Master Yak's death decrements it; killing all placed enemies is not its original win condition (`MapStore.as:110-112`, `Monster/Yak_Master.as:375-395`).
- [ ] Final Master Yak is invulnerable outside dizzy/hitstun. Destroying all Barrier Orbs opens an8s dizzy window, then recovery respawns orbs at(7,24),(7,18),(15,15),(24,17),(24,20). Master fires homing attacks, teleports when line-of-sight is blocked and summons guards (`Monster/Yak_Master.as:26`, `119-194`, `294-394`).
- [ ] Barrier entity43 is a solid/shocking object; destroying all associated orbs42 removes the entity with the same tag (`Monster/Barrier.as`, `Barrier_Orb.as:69-75`, `Badguys.as:149-170`). This is distinct from tile gates56..58.
- [ ] General tag completion considers DEADLY and BACKGD groups with exceptions, removes tile55+tag, and records level2Spot for stage2's later trap (`Badguys.TagCheck`, `Level.as:234-255`).
- [ ] Dialogue event5 summons Torgo (Yak_Big), inherits the master's tag, and erects tile56 walls at x97/116,y18..24. Events8/9/10 dismiss the master, enabling their encounters. These conversations have gameplay side effects (`Conversation.as:276-365`, `Yak_Master.as:276-292`).

### Movement, combat and world

- [ ] Core physical units: run70px/s, gravity300px/s², water gravity105, jump125px/s (`Pedro.as:51-57`). Run acceleration/drag is4×run speed; preserve jump grace, variable jump behavior, slopes, crouched bounds, safe-ground position and fall recovery.
- [ ] Ground movement, crouch/dodge, jump/double jump and aerial kick are original state machines, not always-on abilities. Special moves are gated by discovered and purchased skill ranks.
- [ ] Punch chains, Gale Fist, Pedroken/uppercut, flaming and lightning fists, charged/flying/dive/tornado kicks, Burro Bash, grabbing/carrying/throwing, piledriver and atomic piledriver all preserve inputs/costs/hit timing/knockback (`Pedro.as:318-1554`).
- [ ] Fury uses whole units plus fractional subFury; directional selector chooses blast/down, fix/up, freeze/left, frenzy/right. Do not replace four abilities with one flat area hit (`Pedro.as:1344-1443`, `1756-1816`).
- [ ] Statuses and skills affecting damage, recovery, retaliation, crits, rage, maximum-force, healing, fury generation/overload/mastery, frozen/shock/burn/flattening and projectile interactions are effective in simulation (`Pedro.as`, `Monster/BaseMonster.as`, `Bullet/*`).
- [ ] All map entities1..47 have correct behavior; original tents spawn enemies, trees/walls and blimp wreckage are physical objects, not only decorations (`MapStore.as:119-279`).
- [ ] Armor, archers/elite, ninja, bruiser, Torgo/Big, Master, FireMan, Yakolyte, Robot and Iron Priest retain their specific AI, projectiles, collision dimensions and animations, including wake-up/hidden/armor break/transform states.

### Progression and story

- [ ]15 original layouts preserve mail, heart, Fury Soul, technique and potion placement. Heart pickup adds1 max life up to20; soul adds1 max fury up to5; techniques7/8/9 discover skill `stage + 15*set`, and already-collected upgrades remain absent on revisits (`Profile.as:307-391`, `MapStore.as:131-157`).
- [ ] XP need is `level*10+50` until level99; Fancy Footwork multiplies earned XP by`1+rank*0.06`; levelling grants1 skill point (`Profile.as:272-305`). Base life/fury and skills come from original profile initialization, not100-point generic meters.
- [ ]45 skills in three15-skill sets preserve discovery prerequisites, rank purchase and all move/effect unlocks. Profiles retain spent ranks, discovered flags, points, XP, level, passed stages, best times and pickup flags.
- [ ] Intro blimp flight/crash/parachute arrives before original tutorial; stage0 Pedro initially inactive (`PlayState.as:135-142`, `Monster/Blimp.as`, `PedroChute.as:59-79`).
- [ ]All12 conversation events and28 pages, bubble speakers, camera/pause behavior and trigger conditions are present. Machine-readable extraction: `../pedro-dialogue-spec.json`; includes all exact pages, trigger source contexts and full non-dialogue branches.
- [ ]Key trigger examples: stage0 right-facing tent launch; stage2 armored wake; stage3 ground x>37*16 wreck comment; stage4 ninja proximity/LOS; stage9 tag2 archer movement then altitude; stage8/10/11/13/14 master encounters. Retain repeat guards and trap mutations.
- [ ]Final ending and replay/progression flow match `Menus/WinState.as` and `PlayState.as`.

## Useful recovered indexes

`extract_mechanics_spec.py` produces function names, original source line numbers, return expressions and complete bodies for105 Scout and100 Pedro files. It is a navigation aid; decompiled source and runtime are the authority. `extract_dialogue_spec.py` recovers conversation pages and trigger contexts. These files do not execute SWF code and do not establish runtime parity on their own.

## Required evidence before a near-complete label

No stage-completion blockers above may remain substituted. Native tests should exercise each boss phase, an arena from first through fifth mail, tag gate/barrier distinctions, every upgrade branch and move family, persistent skill purchases/pickups, multiple overlapping Scout waves, all alien specials and dropped-food re-grabs. Measure simulation speed and physical-calculator playability. Any untested feature remains **unverified**, even if source was translated. Any omitted feature remains **omitted**, with its gameplay consequence stated explicitly.
