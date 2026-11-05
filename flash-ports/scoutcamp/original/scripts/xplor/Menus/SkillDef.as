package xplor.Menus
{
   public class SkillDef
   {
      
      public static const ROCKTOWER:uint = 0;
      
      public static const SLINGSHOT:uint = 1;
      
      public static const SOAPBOX:uint = 2;
      
      public static const HARDROCK:uint = 3;
      
      public static const FINISHHIM:uint = 4;
      
      public static const GATHEREDMOSS:uint = 5;
      
      public static const CONFUSION:uint = 6;
      
      public static const ENCOURAGEMENT:uint = 7;
      
      public static const BIGBUCKS:uint = 8;
      
      public static const SNOWFORT:uint = 9;
      
      public static const ICELAUNCHER:uint = 10;
      
      public static const SLUSHEE:uint = 11;
      
      public static const FROSTBITE:uint = 12;
      
      public static const REFRIGERATION:uint = 13;
      
      public static const BRAINFREEZE:uint = 14;
      
      public static const ICESHARDS:uint = 15;
      
      public static const BLUERAZZ:uint = 16;
      
      public static const CASHFLOW:uint = 17;
      
      public static const SHOCKER:uint = 18;
      
      public static const CRIPPLER:uint = 19;
      
      public static const LIGHTNINGROD:uint = 20;
      
      public static const CHAINLIGHTNING:uint = 21;
      
      public static const SHOCKTRAP:uint = 22;
      
      public static const ARCING:uint = 23;
      
      public static const MEGAWATT:uint = 24;
      
      public static const HEARTSTOPPER:uint = 25;
      
      public static const CONSTRUCTION:uint = 26;
      
      public static const ROLYPOLY:uint = 27;
      
      public static const CRUSHER:uint = 28;
      
      public static const QUAKE:uint = 29;
      
      public static const ROCKNROLL:uint = 30;
      
      public static const POISONTRAP:uint = 31;
      
      public static const ROLLBACK:uint = 32;
      
      public static const FLATTEN:uint = 33;
      
      public static const QUAKEUP:uint = 34;
      
      public static const ENHANCEMENT:uint = 35;
      
      public static const FIREPOWER:uint = 36;
      
      public static const EAGLEEYE:uint = 37;
      
      public static const RAPIDFIRE:uint = 38;
      
      public static const CRITICAL:uint = 39;
      
      public static const FREE_PEBBLES:uint = 40;
      
      public static const SHATTER:uint = 41;
      
      public static const SELL_TOWER:uint = 42;
      
      public static const CONDUCTANCE:uint = 43;
      
      public static const SHOCK_ROCK:uint = 44;
      
      public static const ROLLING_THUNDER:uint = 45;
      
      public static const BRITTLE_BONES:uint = 46;
      
      public static const ON_A_ROLL:uint = 47;
      
      public var name:String;
      
      public var group:int;
      
      public var rank:int;
      
      public var x:int;
      
      public var icon:int;
      
      public function SkillDef(param1:String, param2:int, param3:int, param4:int, param5:int)
      {
         super();
         this.name = param1;
         this.group = param2;
         this.rank = param3;
         this.x = param4;
         this.icon = param5;
      }
      
      public static function Str(param1:Number) : String
      {
         param1 = int(param1 * 100) / 100;
         return param1.toString();
      }
      
      public function Describe(param1:int) : String
      {
         if(param1 == 0)
         {
            param1 = 1;
         }
         switch(this.icon)
         {
            case ROCKTOWER:
               return "Build Rock Towers that throw rocks at aliens for " + Str(5.5 + param1 * 0.5) + " damage.";
            case SLINGSHOT:
               return "Build Slingshots that snipe aliens from great range for " + int(20 + param1 * 3).toString() + " damage.";
            case SOAPBOX:
               return "Build Soapboxes where Pee Wee encourages nearby towers to hit " + int(15 + param1 * 2).toString() + "% harder.";
            case HARDROCK:
               return "Rock Tower, Slingshot, Roly Poly, and Crusher do " + int(param1 * 5).toString() + "% more damage.";
            case FINISHHIM:
               return "Aliens below " + int(param1 * 8).toString() + "% life take 25% more damage from all attacks.";
            case GATHEREDMOSS:
               return "Rock Towers poison aliens for " + int(param1 * 3).toString() + " damage over 10 seconds.";
            case CONFUSION:
               return "Slingshots have " + int(param1 * 2).toString() + "% chance to disorient aliens into turning around.";
            case ENCOURAGEMENT:
               return "Upgrading a Soapbox has a " + int(param1 * 5).toString() + "% chance to upgrade another tower in its range.";
            case BIGBUCKS:
               return "Begin each level with " + int(param1 * 10).toString() + "% more money.";
            case SNOWFORT:
               return "Build Snow Forts that slow aliens by 30% for " + Str(3 + param1) + " seconds.";
            case ICELAUNCHER:
               return "Build Ice Launchers that freeze aliens for " + Str(0.25 + param1 * 0.25) + " seconds.";
            case SLUSHEE:
               return "Build Slushee Makers that slow all aliens under them by " + int(25 + param1 * 5).toString() + "%.";
            case FROSTBITE:
               return "Slowed aliens suffer " + Str(param1 * 0.5) + " damage per second. Frozen aliens take twice that.";
            case REFRIGERATION:
               return "Aliens carrying food are slowed by " + int(param1 * 5).toString() + "%.";
            case BRAINFREEZE:
               return "Snow Forts have " + int(param1 * 8).toString() + "% chance to disable alien abilities for the duration of their slow.";
            case ICESHARDS:
               return "Ice Launcher inflicts " + int(param1 * 2).toString() + " more damage.";
            case BLUERAZZ:
               return "Slushee Makers freeze aliens for " + Str(param1 * 0.1) + " seconds in addition to slowing.";
            case CASHFLOW:
               return "Earn " + int(param1 * 4).toString() + "% more money from aliens destroyed.";
            case SHOCKER:
               return "Build Shockers that zap aliens, making them shock their friends for " + Str(3 + param1 * 0.5) + " seconds.";
            case CRIPPLER:
               return "Build Cripplers that disable an alien\'s abilities and make it take " + int(25 + param1 * 5).toString() + "% more damage.";
            case LIGHTNINGROD:
               return "Build Lightning Rods that blast all aliens above them for " + int(35 + param1 * 15).toString() + " damage.";
            case CHAINLIGHTNING:
               return "Electric towers shock " + int(param1 + 1).toString() + " aliens nearby for " + int(param1 * 2).toString() + " damage when they hit.";
            case SHOCKTRAP:
               return "All towers shock aliens walking past them once per second for " + int(param1).toString() + " damage.";
            case ARCING:
               return "Aliens affected by the Shocker shock their friends up to " + int(param1 * 40).toString() + "% farther away.";
            case MEGAWATT:
               return "Aliens blown up while affected by the Crippler do " + int(param1 * 5).toString() + " damage to all nearby.";
            case HEARTSTOPPER:
               return "Lightning Rods have a " + int(param1 * 2).toString() + "% chance to annihilate their victims.";
            case CONSTRUCTION:
               return "All towers cost " + int(param1 * 4).toString() + "% less to build.";
            case ROLYPOLY:
               return "Build Roly Poly towers that roll boulders for " + int(5 + param1).toString() + " tiles, crushing all aliens.";
            case CRUSHER:
               return "Build Crushers that drop boulders on all aliens below every " + Str(3.75 - param1 * 0.25) + " seconds.";
            case QUAKE:
               return "Build Quake-O-Matics that constantly pound the area, over a radius of " + Str(1 + param1 * 0.3) + " tiles.";
            case ROCKNROLL:
               return "Roly Poly, Crusher, and Quake-O-Matic all fire " + int(param1 * 5).toString() + "% faster.";
            case POISONTRAP:
               return "Aliens carrying food suffer " + Str(param1 * 5) + "% more damage when hit.";
            case ROLLBACK:
               return "Aliens hit by Roly Poly boulders have a " + int(param1 * 10).toString() + "% chance to be knocked back.";
            case FLATTEN:
               return "Crusher boulders flatten aliens, paralyzing them for " + Str(param1 * 0.2) + " seconds.";
            case QUAKEUP:
               return "Quake-O-Matics have a " + int(param1 * 3).toString() + "% chance to critically hit for double damage. This stacks with Critical Strike.";
            case ENHANCEMENT:
               return "Upgrading towers costs " + int(param1 * 3).toString() + "% less.";
            case FIREPOWER:
               return "All towers do " + int(param1 * 2).toString() + "% more damage.";
            case EAGLEEYE:
               return "All towers have " + int(param1 * 2).toString() + "% longer range.";
            case RAPIDFIRE:
               return "All towers fire " + int(param1 * 2).toString() + "% faster.";
            case CRITICAL:
               return "All attacks have a " + int(param1 * 2).toString() + "% chance to critically hit for double damage.";
            case CONDUCTANCE:
               return "Shocked aliens suffer " + int(param1 * 5).toString() + "% more damage from Frostbite and Ice Launcher.";
            case SHATTER:
               return "Slowed and frozen aliens suffer " + int(param1 * 5).toString() + "% more damage from Rocks and Slingshots.";
            case BRITTLE_BONES:
               return "Roly Poly, Crusher, and Quake-O-Matic do " + int(param1 * 5).toString() + "% more damage to frozen/slowed aliens.";
            case FREE_PEBBLES:
               return "Boulders rolling or falling past a Slingshot reload it. This can happen to a tower once every " + int(10 - param1).toString() + " seconds.";
            case SHOCK_ROCK:
               return "Rock Towers next to Shockers throw rocks that shock " + int(param1 * 7).toString() + "% as much as their neighbor.";
            case ROLLING_THUNDER:
               return "Lightning Rods fire " + Str(param1 * 0.05) + " seconds sooner each time a Quake-O-Matic shakes them.";
            case ON_A_ROLL:
               return "Sending a wave early earns you $" + int(param1 * 2).toString() + " times the wave number.";
            case SELL_TOWER:
               return "Selling any tower freezes every alien for " + Str(param1 * 0.2) + " seconds per level of the tower.";
            default:
               return "yay";
         }
      }
   }
}

