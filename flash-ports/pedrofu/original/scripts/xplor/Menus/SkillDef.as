package xplor.Menus
{
   import xplor.Profile;
   
   public class SkillDef
   {
      
      public static const SKILLS_PER_SET:uint = 15;
      
      public static const FISTOFFURY:uint = 0;
      
      public static const PEDROPUNCH:uint = 1;
      
      public static const RECOVERY:uint = 2;
      
      public static const BURROBASH:uint = 3;
      
      public static const GALEFIST:uint = 4;
      
      public static const MIGHTYGRAB:uint = 5;
      
      public static const PEDROKEN:uint = 6;
      
      public static const PILEDRIVER:uint = 7;
      
      public static const COCONUTBONK:uint = 8;
      
      public static const FISTSOFFLAME:uint = 9;
      
      public static const ATOMICPILEDRIVER:uint = 10;
      
      public static const PRESSUREPOINTS:uint = 11;
      
      public static const IRONFIST:uint = 12;
      
      public static const STRONGARM:uint = 13;
      
      public static const LIGHTNINGFIST:uint = 14;
      
      public static const FEETOFFURY:uint = 15;
      
      public static const FLYINGKICK:uint = 16;
      
      public static const DODGE:uint = 17;
      
      public static const DIVEKICK:uint = 18;
      
      public static const FANCYFOOTWORK:uint = 19;
      
      public static const CHARGEKICK:uint = 20;
      
      public static const KOKICK:uint = 21;
      
      public static const POWERKICK:uint = 22;
      
      public static const RETALIATE:uint = 23;
      
      public static const TORNADOKICK:uint = 24;
      
      public static const LEADFOOT:uint = 25;
      
      public static const RAGINGBURRO:uint = 26;
      
      public static const WHIRLWIND:uint = 27;
      
      public static const STEELTOES:uint = 28;
      
      public static const COMBOBOMBO:uint = 29;
      
      public static const FURIOUSBLAST:uint = 30;
      
      public static const INNERFURY:uint = 31;
      
      public static const FURIOUSROAR:uint = 32;
      
      public static const FURIOUSFIX:uint = 33;
      
      public static const FURIOUSSHIELD:uint = 34;
      
      public static const FURIOUSBLOOD:uint = 35;
      
      public static const FURIOUSFREEZE:uint = 36;
      
      public static const DEEPFREEZE:uint = 37;
      
      public static const HEARTOFFURY:uint = 38;
      
      public static const FURIOUSFRENZY:uint = 39;
      
      public static const BURNINGFURY:uint = 40;
      
      public static const FURYOVERLOAD:uint = 41;
      
      public static const CRUSHINGBLOW:uint = 42;
      
      public static const MAXIMUMFORCE:uint = 43;
      
      public static const FURYMASTER:uint = 44;
      
      public var name:String;
      
      public var group:int;
      
      public var rank:int;
      
      public var x:int;
      
      public var icon:int;
      
      public function SkillDef(name:String, group:int, rank:int, x:int, icon:int)
      {
         super();
         this.name = name;
         this.group = group;
         this.rank = rank;
         this.x = x;
         this.icon = icon;
      }
      
      public static function Str(n:Number) : String
      {
         n = int(n * 100) / 100;
         return n.toString();
      }
      
      public static function PunchDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[SkillDef.PEDROPUNCH]);
         }
         return (1 + pts * 0.1) * (1 + Profile.skills[IRONFIST] * 0.1 + Profile.skills[FISTOFFURY] * 0.03 + Profile.skills[GALEFIST] * 0.02);
      }
      
      public static function BurroBashDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[SkillDef.BURROBASH]);
         }
         return (2 + pts) * (1 + Profile.skills[IRONFIST] * 0.1 + Profile.skills[FISTOFFURY] * 0.03 + Profile.skills[GALEFIST] * 0.02);
      }
      
      public static function ThrowDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[SkillDef.MIGHTYGRAB]);
         }
         return pts * 3 * (1 + Profile.skills[STRONGARM] * 0.1 + Profile.skills[COCONUTBONK] * 0.03);
      }
      
      public static function PedrokenDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[SkillDef.PEDROKEN]);
         }
         return pts * 1.5 * (1 + Profile.skills[IRONFIST] * 0.1 + Profile.skills[FISTOFFURY] * 0.03 + Profile.skills[GALEFIST] * 0.02);
      }
      
      public static function PiledriverDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[SkillDef.PILEDRIVER]);
         }
         return pts * 3 * (1 + Profile.skills[STRONGARM] * 0.1 + Profile.skills[COCONUTBONK] * 0.03);
      }
      
      public static function FuryDamageBonus() : Number
      {
         return Profile.skills[HEARTOFFURY] * 0.03 + Profile.skills[MAXIMUMFORCE] * 0.04 + Profile.skills[FURYMASTER] * 0.04;
      }
      
      public static function AtomicDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[SkillDef.ATOMICPILEDRIVER]);
         }
         return pts * 2 * (1 + FuryDamageBonus());
      }
      
      public static function FistsOfFlameDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[SkillDef.FISTSOFFLAME]);
         }
         return pts * (1 + FuryDamageBonus());
      }
      
      public static function KickDamageBonus() : Number
      {
         return Profile.skills[FEETOFFURY] * 0.03 + Profile.skills[POWERKICK] * 0.03 + Profile.skills[STEELTOES] * 0.1;
      }
      
      public static function JumpkickDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[FLYINGKICK]);
         }
         return (1 + pts) * (1 + KickDamageBonus());
      }
      
      public static function DiveKickDamage() : Number
      {
         return (2 + Profile.skills[KOKICK] * 0.5) * (1 + KickDamageBonus());
      }
      
      public static function ChargeKickDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[CHARGEKICK]);
         }
         return (1 + pts) * (1 + KickDamageBonus());
      }
      
      public static function TornadoKickDamage() : Number
      {
         return 1 * (1 + KickDamageBonus());
      }
      
      public static function RetaliateDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[RETALIATE]);
         }
         return (1 + pts) * (1 + KickDamageBonus() + FuryDamageBonus());
      }
      
      public static function FuriousBlastDamage(pts:int = -1) : Number
      {
         return (pts * 3 + Profile.skills[FURIOUSROAR] * 2) * (1 + FuryDamageBonus());
      }
      
      public static function FireballDamage(pts:int = -1) : Number
      {
         if(pts == -1)
         {
            pts = int(Profile.skills[BURNINGFURY]);
         }
         return pts * 0.5 * (1 + FuryDamageBonus());
      }
      
      public function Describe(pts:int) : String
      {
         if(pts == 0)
         {
            pts = 1;
         }
         switch(this.icon)
         {
            case PEDROPUNCH:
               return "Tap X to punch for " + Str(PunchDamage(pts)) + " damage. Tap or hold X to rapidly punch " + int(pts + 1).toString() + " times before you need a break.";
            case FISTOFFURY:
               return "Each punch has a " + int(pts * 10).toString() + "% chance to generate 2 Fury. Punches also do " + int(pts * 3).toString() + "% more damage.";
            case GALEFIST:
               return "Punching generates waves of wind to strike enemies " + int(pts * 2).toString() + " feet further away. Punches also do " + int(pts * 2).toString() + "% more damage.";
            case BURROBASH:
               return "Double-tap forward to smash through enemies for " + Str(BurroBashDamage(pts)) + " damage. This charge lasts " + Str(pts * 0.5) + " seconds, but you can stop early by tapping the opposite direction.";
            case MIGHTYGRAB:
               return "If you hold X when Burro Bash hits an enemy, you\'ll grab him!  Keep X held to carry him around. " + "Release X to throw him, doing " + Str(ThrowDamage(pts)) + " damage. Giant enemies can\'t be grabbed.";
            case COCONUTBONK:
               return "Thrown enemies bonk into other enemies, doing " + int(pts * 10).toString() + "% of the throw damage to the enemy hit. Bonked enemies may bonk other enemies as well. " + "Base throw damage is also increased by " + int(pts * 3).toString() + "%.";
            case PEDROKEN:
               return "Tap X while ducking to perform a rising uppercut for " + Str(PedrokenDamage(pts)) + " damage.  This knocks enemies very far away.";
            case PILEDRIVER:
               return "Tap down while carrying an enemy and jumping to slam him into the ground, doing " + Str(PiledriverDamage(pts)) + " damage, and " + "stunning him for " + Str(pts * 0.5) + " seconds.";
            case ATOMICPILEDRIVER:
               return "Piledriver causes an explosion, doing " + Str(AtomicDamage(pts)) + " damage to enemies within " + int(5 + pts * 3).toString() + " feet. " + "This costs " + int(pts).toString() + " Fury.";
            case FISTSOFFLAME:
               return "Pedroken launches a column of fire, adding " + Str(FistsOfFlameDamage(pts)) + " damage, makes you invulnerable, and has a " + int(pts * 20).toString() + "% chance to shatter armor. " + "But it now costs " + int(pts * 2).toString() + " Fury each time you do a Pedroken.";
            case RECOVERY:
               return "Tap Down when injured to drop to the ground safely. In addition, each time an enemy is defeated, you have a " + int(pts * 6).toString() + "% chance to heal 1 heart.";
            case PRESSUREPOINTS:
               return "Pedro Punches have a " + int(pts * 4).toString() + "% chance of doing triple damage and granting " + int(pts).toString() + " Fury.";
            case IRONFIST:
               return "All punch attacks inflict " + int(pts * 10).toString() + "% more damage.";
            case STRONGARM:
               return "All throws inflict " + int(pts * 10).toString() + "% more damage.";
            case LIGHTNINGFIST:
               return "Pedro Punches electrocute the victim, shooting lightning at up to " + int(pts).toString() + " other enemies within " + int(pts * 10).toString() + " feet for " + Str(0.2 + pts * 0.2) + " damage.";
            case FLYINGKICK:
               return "Press X in the air to jumpkick for " + Str(JumpkickDamage(pts)) + " damage.";
            case FEETOFFURY:
               return "Kicking an enemy generates " + int(pts).toString() + " Fury. This excludes Tornado Kick hits. Also boosts damage of all kicks by " + int(pts * 3).toString() + "%.";
            case POWERKICK:
               return "Jumpkicks knock enemies " + int(pts * 30).toString() + "% further away, and all kicks do " + int(pts * 3).toString() + "% more damage.";
            case DIVEKICK:
               return "Tap Down in the air to dive onto enemies below and bounce off for " + Str(DiveKickDamage()) + " damage. You can do this " + int(pts).toString() + " times in one jump.";
            case KOKICK:
               return "Dive Kicks hit so hard, they flatten the enemy for " + Str(0.4) + " seconds. Also increases Dive Kick damage by " + Str(pts * 0.5) + ".";
            case DODGE:
               return "Holding Down to duck also dodges all attacks for the first " + Str(0.2 * pts) + " seconds.";
            case CHARGEKICK:
               return "Tap X twice in the air to dash at the nearest enemy with a flying kick for " + Str(ChargeKickDamage(pts)) + " damage.  This knocks them far back.";
            case RETALIATE:
               return "Tap X when injured to instantly strike back with a Dragon Kick for " + Str(RetaliateDamage()) + " damage.  This costs " + int(20 - pts * 3).toString() + " Fury.";
            case FANCYFOOTWORK:
               return "Gain " + int(pts * 6).toString() + "% more XP when you defeat enemies.";
            case TORNADOKICK:
               return "Keep X held when a Flying Kick hits an enemy to perform a Tornado Kick, " + "striking up to " + int(pts).toString() + " more times for " + Str(TornadoKickDamage()) + " damage each time.";
            case WHIRLWIND:
               return "Tornado Kick sucks in enemies from up to " + int(pts * 5).toString() + " feet away, hitting them all.";
            case RAGINGBURRO:
               return "Getting injured induces a terrible rage in Pedro, with all damage increased by " + int(pts * 8).toString() + "% for " + int(pts).toString() + " seconds.";
            case LEADFOOT:
               return "All kicks except Tornado Kick have a " + int(pts * 3).toString() + "% chance of doing triple damage and shattering armor.";
            case STEELTOES:
               return "All kicks do " + int(pts * 10).toString() + "% more damage.";
            case COMBOBOMBO:
               return "Defeated enemies explode, doing " + int(pts * 2).toString() + " damage to all other nearby enemies.";
            case FURIOUSBLAST:
               return "Hold C and tap Down to blast all enemies onscreen for " + Str(FuriousBlastDamage(pts)) + " damage. This also shatters armor. This costs 100 Fury.";
            case HEARTOFFURY:
               return "Gain " + int(pts * 2).toString() + " Fury whenever you are injured. Also boosts the damage of abilities that cost Fury by " + int(pts * 3).toString() + "%.";
            case FURIOUSROAR:
               return "Furious Blast flings enemies away from you and destroys " + int(pts * 20) + "% of projectiles. Also increases the damage by " + int(pts * 2).toString() + ".";
            case FURIOUSFIX:
               return "Hold C, then hold Up to heal yourself.  This requires 100 Fury to start, but continues as long as you hold Up " + "and have remaining Fury. Heals 1 Heart for every " + int(20 - 3 * pts).toString() + " Fury spent.";
            case FURIOUSSHIELD:
               return "While Furious Fixing, you have " + int(20 * pts).toString() + "% chance to resist harm and reflect projectiles.";
            case FURIOUSBLOOD:
               return "Gain " + int(pts * 2).toString() + " Fury for each enemy defeated.";
            case FURIOUSFREEZE:
               return "Hold C and press Left to freeze all enemies for " + Str(pts * 1.5) + " seconds.  Frozen enemies thaw when hit.  This costs 100 Fury.";
            case DEEPFREEZE:
               return "Frozen enemies won\'t thaw until they are hit " + int(pts + 1).toString() + " times.  The hit that thaws them also does " + int(pts * 20).toString() + "% more damage.";
            case INNERFURY:
               return "Begin each level with " + int(20 * pts).toString() + " Fury and gain 1 Fury every " + Str(3 - 0.5 * pts).toString() + " seconds.";
            case FURIOUSFRENZY:
               return "Hold C and press Right to go berserk, doing double damage for " + int(pts * 2).toString() + " seconds.  This costs 100 Fury.";
            case BURNINGFURY:
               return "While in Furious Frenzy, each press of X launches a homing fireball that does " + Str(FireballDamage(pts)) + " damage.";
            case FURYOVERLOAD:
               return "Gaining Fury beyond your maximum limit will heal you 1 heart for every " + int(50 - 8 * pts).toString() + " excess Fury.";
            case CRUSHINGBLOW:
               return "Every hit has a " + int(pts * 2).toString() + "% chance of reducing the enemy\'s current health by 20% in addition to doing its regular damage.";
            case MAXIMUMFORCE:
               return "When both Fury and Health are at maximum, all attacks do " + int(pts * 6).toString() + "% more damage. Also always " + "boosts the damage of abilities that cost Fury by " + int(pts * 4).toString() + "%.";
            case FURYMASTER:
               return "All Fury abilities have a " + int(pts * 3).toString() + "% chance to cost no Fury. Furious Fix has this chance " + "each time it heals. Also boosts the damage of abilities that cost Fury by " + int(pts * 4).toString() + "%.";
            default:
               return "yay";
         }
      }
   }
}

