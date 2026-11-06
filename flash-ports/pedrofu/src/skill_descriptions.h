/* Generated from original SkillDef.Describe. X/C labels become ALPHA/DEL.
 * Arithmetic uses exact fractions truncated to hundredths, not Flash roundoff. */
#ifndef PEDRO_SKILL_DESCRIPTIONS_H
#define PEDRO_SKILL_DESCRIPTIONS_H
static const char *sd_number(int value,char *buffer){
 snprintf(buffer,16,"%d.%02d",value/100,value%100);
 unsigned n=strlen(buffer);while(n&&buffer[n-1]=='0')buffer[--n]=0;
 if(n&&buffer[n-1]=='.')buffer[--n]=0;return buffer;
}
static void skill_description(int id,int pts,char *dest,unsigned capacity){
 char number[4][16];(void)number;if(!capacity)return;
 if(pts<1)pts=1;if(pts>5)pts=5;
 switch(id){
 case 1:snprintf(dest,capacity,"Tap ALPHA to punch for %s damage. Tap or hold ALPHA to rapidly punch %d times before you need a break.",sd_number(((((1*10)+(pts*1))*(((((1*10)+(progress.skills[12]*1))*10)+(progress.skills[0]*3))+((progress.skills[4]*1)*2)))/10),number[0]),(pts+1));break;
 case 0:snprintf(dest,capacity,"Each punch has a %d%% chance to generate 2 Fury. Punches also do %d%% more damage.",(pts*10),(pts*3));break;
 case 4:snprintf(dest,capacity,"Punching generates waves of wind to strike enemies %d feet further away. Punches also do %d%% more damage.",(pts*2),(pts*2));break;
 case 3:snprintf(dest,capacity,"Double-tap forward to smash through enemies for %s damage. This charge lasts %s seconds, but you can stop early by tapping the opposite direction.",sd_number(((2+pts)*(((((1*10)+(progress.skills[12]*1))*10)+(progress.skills[0]*3))+((progress.skills[4]*1)*2))),number[0]),sd_number(((pts*1)*50),number[1]));break;
 case 5:snprintf(dest,capacity,"If you hold ALPHA when Burro Bash hits an enemy, you'll grab him!  Keep ALPHA held to carry him around. Release ALPHA to throw him, doing %s damage. Giant enemies can't be grabbed.",sd_number(((pts*3)*((((1*10)+(progress.skills[13]*1))*10)+(progress.skills[8]*3))),number[0]));break;
 case 8:snprintf(dest,capacity,"Thrown enemies bonk into other enemies, doing %d%% of the throw damage to the enemy hit. Bonked enemies may bonk other enemies as well. Base throw damage is also increased by %d%%.",(pts*10),(pts*3));break;
 case 6:snprintf(dest,capacity,"Tap ALPHA while ducking to perform a rising uppercut for %s damage.  This knocks enemies very far away.",sd_number((((pts*3)*(((((1*10)+(progress.skills[12]*1))*10)+(progress.skills[0]*3))+((progress.skills[4]*1)*2)))/2),number[0]));break;
 case 7:snprintf(dest,capacity,"Tap down while carrying an enemy and jumping to slam him into the ground, doing %s damage, and stunning him for %s seconds.",sd_number(((pts*3)*((((1*10)+(progress.skills[13]*1))*10)+(progress.skills[8]*3))),number[0]),sd_number(((pts*1)*50),number[1]));break;
 case 10:snprintf(dest,capacity,"Piledriver causes an explosion, doing %s damage to enemies within %d feet. This costs %d Fury.",sd_number(((pts*2)*((1*100)+(((progress.skills[38]*3)+((progress.skills[43]*1)*4))+((progress.skills[44]*1)*4)))),number[0]),(5+(pts*3)),pts);break;
 case 9:snprintf(dest,capacity,"Pedroken launches a column of fire, adding %s damage, makes you invulnerable, and has a %d%% chance to shatter armor. But it now costs %d Fury each time you do a Pedroken.",sd_number((pts*((1*100)+(((progress.skills[38]*3)+((progress.skills[43]*1)*4))+((progress.skills[44]*1)*4)))),number[0]),(pts*20),(pts*2));break;
 case 2:snprintf(dest,capacity,"Tap Down when injured to drop to the ground safely. In addition, each time an enemy is defeated, you have a %d%% chance to heal 1 heart.",(pts*6));break;
 case 11:snprintf(dest,capacity,"Pedro Punches have a %d%% chance of doing triple damage and granting %d Fury.",(pts*4),pts);break;
 case 12:snprintf(dest,capacity,"All punch attacks inflict %d%% more damage.",(pts*10));break;
 case 13:snprintf(dest,capacity,"All throws inflict %d%% more damage.",(pts*10));break;
 case 14:snprintf(dest,capacity,"Pedro Punches electrocute the victim, shooting lightning at up to %d other enemies within %d feet for %s damage.",pts,(pts*10),sd_number(((1+(pts*1))*20),number[0]));break;
 case 16:snprintf(dest,capacity,"Press ALPHA in the air to jumpkick for %s damage.",sd_number(((1+pts)*((1*100)+(((progress.skills[15]*3)+(progress.skills[22]*3))+((progress.skills[28]*1)*10)))),number[0]));break;
 case 15:snprintf(dest,capacity,"Kicking an enemy generates %d Fury. This excludes Tornado Kick hits. Also boosts damage of all kicks by %d%%.",pts,(pts*3));break;
 case 22:snprintf(dest,capacity,"Jumpkicks knock enemies %d%% further away, and all kicks do %d%% more damage.",(pts*30),(pts*3));break;
 case 18:snprintf(dest,capacity,"Tap Down in the air to dive onto enemies below and bounce off for %s damage. You can do this %d times in one jump.",sd_number(((((2*2)+(progress.skills[21]*1))*((1*100)+(((progress.skills[15]*3)+(progress.skills[22]*3))+((progress.skills[28]*1)*10))))/2),number[0]),pts);break;
 case 21:snprintf(dest,capacity,"Dive Kicks hit so hard, they flatten the enemy for %s seconds. Also increases Dive Kick damage by %s.",sd_number((2*20),number[0]),sd_number(((pts*1)*50),number[1]));break;
 case 17:snprintf(dest,capacity,"Holding Down to duck also dodges all attacks for the first %s seconds.",sd_number(((1*pts)*20),number[0]));break;
 case 20:snprintf(dest,capacity,"Tap ALPHA twice in the air to dash at the nearest enemy with a flying kick for %s damage.  This knocks them far back.",sd_number(((1+pts)*((1*100)+(((progress.skills[15]*3)+(progress.skills[22]*3))+((progress.skills[28]*1)*10)))),number[0]));break;
 case 23:snprintf(dest,capacity,"Tap ALPHA when injured to instantly strike back with a Dragon Kick for %s damage.  This costs %d Fury.",sd_number(((1+progress.skills[23])*(((1*100)+(((progress.skills[15]*3)+(progress.skills[22]*3))+((progress.skills[28]*1)*10)))+(((progress.skills[38]*3)+((progress.skills[43]*1)*4))+((progress.skills[44]*1)*4)))),number[0]),(20-(pts*3)));break;
 case 19:snprintf(dest,capacity,"Gain %d%% more XP when you defeat enemies.",(pts*6));break;
 case 24:snprintf(dest,capacity,"Keep ALPHA held when a Flying Kick hits an enemy to perform a Tornado Kick, striking up to %d more times for %s damage each time.",pts,sd_number((1*((1*100)+(((progress.skills[15]*3)+(progress.skills[22]*3))+((progress.skills[28]*1)*10)))),number[0]));break;
 case 27:snprintf(dest,capacity,"Tornado Kick sucks in enemies from up to %d feet away, hitting them all.",(pts*5));break;
 case 26:snprintf(dest,capacity,"Getting injured induces a terrible rage in Pedro, with all damage increased by %d%% for %d seconds.",(pts*8),pts);break;
 case 25:snprintf(dest,capacity,"All kicks except Tornado Kick have a %d%% chance of doing triple damage and shattering armor.",(pts*3));break;
 case 28:snprintf(dest,capacity,"All kicks do %d%% more damage.",(pts*10));break;
 case 29:snprintf(dest,capacity,"Defeated enemies explode, doing %d damage to all other nearby enemies.",(pts*2));break;
 case 30:snprintf(dest,capacity,"Hold DEL and tap Down to blast all enemies onscreen for %s damage. This also shatters armor. This costs 100 Fury.",sd_number((((pts*3)+(progress.skills[32]*2))*((1*100)+(((progress.skills[38]*3)+((progress.skills[43]*1)*4))+((progress.skills[44]*1)*4)))),number[0]));break;
 case 38:snprintf(dest,capacity,"Gain %d Fury whenever you are injured. Also boosts the damage of abilities that cost Fury by %d%%.",(pts*2),(pts*3));break;
 case 32:snprintf(dest,capacity,"Furious Blast flings enemies away from you and destroys %d%% of projectiles. Also increases the damage by %d.",(pts*20),(pts*2));break;
 case 33:snprintf(dest,capacity,"Hold DEL, then hold Up to heal yourself.  This requires 100 Fury to start, but continues as long as you hold Up and have remaining Fury. Heals 1 Heart for every %d Fury spent.",(20-(3*pts)));break;
 case 34:snprintf(dest,capacity,"While Furious Fixing, you have %d%% chance to resist harm and reflect projectiles.",(20*pts));break;
 case 35:snprintf(dest,capacity,"Gain %d Fury for each enemy defeated.",(pts*2));break;
 case 36:snprintf(dest,capacity,"Hold DEL and press Left to freeze all enemies for %s seconds.  Frozen enemies thaw when hit.  This costs 100 Fury.",sd_number(((pts*3)*50),number[0]));break;
 case 37:snprintf(dest,capacity,"Frozen enemies won't thaw until they are hit %d times.  The hit that thaws them also does %d%% more damage.",(pts+1),(pts*20));break;
 case 31:snprintf(dest,capacity,"Begin each level with %d Fury and gain 1 Fury every %s seconds.",(20*pts),sd_number((((3*2)-(1*pts))*50),number[0]));break;
 case 39:snprintf(dest,capacity,"Hold DEL and press Right to go berserk, doing double damage for %d seconds.  This costs 100 Fury.",(pts*2));break;
 case 40:snprintf(dest,capacity,"While in Furious Frenzy, each press of ALPHA launches a homing fireball that does %s damage.",sd_number((((pts*1)*((1*100)+(((progress.skills[38]*3)+((progress.skills[43]*1)*4))+((progress.skills[44]*1)*4))))/2),number[0]));break;
 case 41:snprintf(dest,capacity,"Gaining Fury beyond your maximum limit will heal you 1 heart for every %d excess Fury.",(50-(8*pts)));break;
 case 42:snprintf(dest,capacity,"Every hit has a %d%% chance of reducing the enemy's current health by 20%% in addition to doing its regular damage.",(pts*2));break;
 case 43:snprintf(dest,capacity,"When both Fury and Health are at maximum, all attacks do %d%% more damage. Also always boosts the damage of abilities that cost Fury by %d%%.",(pts*6),(pts*4));break;
 case 44:snprintf(dest,capacity,"All Fury abilities have a %d%% chance to cost no Fury. Furious Fix has this chance each time it heals. Also boosts the damage of abilities that cost Fury by %d%%.",(pts*3),(pts*4));break;
 default:dest[0]=0;break;
 }
}
/* Interval audit: all ranks1..5, modifier ranks0..5; every generated
 * integer subexpression has absolute value <= 3875 (signed24-bit safe). */
#endif
