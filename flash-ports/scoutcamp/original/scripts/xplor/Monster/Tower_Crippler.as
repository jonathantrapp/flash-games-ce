package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower_Crippler extends Tower
   {
      
      public static var TowerImage:Class = Tower_Crippler_TowerImage;
      
      public var tick:Number;
      
      public var chainTick:Number;
      
      public function Tower_Crippler(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(TowerImage,true,true,16,20,true);
         addAnimation("fire",[2,3],18,true);
         height = 18;
         origin.y = height;
         name = "Crippler";
      }
      
      public static function BasePrice() : int
      {
         return 120 * (1 - Profile.skills[SkillDef.CONSTRUCTION] * 0.04);
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return 25 + 5 * Profile.skills[SkillDef.CRIPPLER];
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return (20 + param1 * 20) * (1 + Profile.skills[SkillDef.EAGLEEYE] * 0.02);
      }
      
      public static function SecondCalc(param1:int) : int
      {
         return 0;
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return 0;
      }
      
      public static function UpgradePrice(param1:int) : int
      {
         return Tower_Shock.UpgradePrice(param1);
      }
      
      public static function RateCalc(param1:int) : Number
      {
         return Math.round(1 / ReloadCalc(param1) * 100) / 100;
      }
      
      override public function Reset() : void
      {
         super.Reset();
         y -= 2;
         spent = BasePrice();
         damage = DamageCalc(level) * dmgBuff;
         reloadTime = ReloadCalc(level);
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
         this.chainTick = 0;
      }
      
      override public function update() : void
      {
         super.update();
         if(action == BORN)
         {
            return;
         }
         if(noFire > 0)
         {
            action = IDLE;
            target = null;
            return;
         }
         if(Global.player.boxMode == Player.FOCUSMONSTER && target != Global.player.target && DistanceToGuy(Global.player.target) <= range && (Global.player.target as BaseMonster).crippled <= 0)
         {
            target = Global.player.target as BaseMonster;
            action = FIRE;
            this.tick = 0;
            play("fire");
         }
         if(target == null || target.exists == false || target.health == 0)
         {
            FindTarget(true,true,true,true,true,false);
         }
         if(target != null && target.x + target.width / 2 < x + width / 2)
         {
            facing = LEFT;
         }
         else if(target != null)
         {
            facing = RIGHT;
         }
         if(action == IDLE)
         {
            if(Global.randRange(0,1) < 0.01 + 0.1 * int(frame == 1))
            {
               frame = int(Global.randRange(0,2));
            }
            if(target != null)
            {
               action = FIRE;
               this.tick = 0;
               play("fire");
            }
         }
         else if(action == FIRE)
         {
            if(target == null || target.exists == false || target.health == 0 || DistanceToGuy(target) > range)
            {
               target = null;
               action = IDLE;
               frame = 0;
               return;
            }
            this.chainTick += FlxG.elapsed;
            while(this.chainTick > 2)
            {
               this.chainTick -= 2;
               ChainLightning(target);
            }
            if(this.tick <= 0)
            {
               this.tick += 0.4;
               Global.bullets.AddBullet(CrippleBeam,Bullets.NEUTRAL,x + width / 2,y + 2,0,0);
               Global.bullets.lastAdded.target = target;
               Global.bullets.lastAdded.update();
               target.Cripple();
            }
            else
            {
               this.tick -= FlxG.elapsed;
            }
         }
      }
      
      override public function UpgradeText(param1:Array) : void
      {
         if(level < 5)
         {
            param1[0] = "Upgrade " + name + " - $" + int(this.UpgradePrice2(level) * (1 - Profile.skills[SkillDef.ENHANCEMENT] * 0.03)).toString();
            param1[1] = "";
            param1[2] = "Damage Bonus: " + Str(DamageCalc(level) * dmgBuff) + "%";
            param1[3] = "Range: " + Str(RangeCalc(level)) + " > " + Str(RangeCalc(level + 1));
            param1[4] = "";
            param1[5] = "";
         }
         else
         {
            this.Describe(param1);
         }
      }
      
      override public function Describe(param1:Array) : void
      {
         param1[0] = name + " L" + (level + 1).toString();
         param1[1] = "";
         param1[2] = "Damage Bonus: " + Str(DamageCalc(level) * dmgBuff) + "%";
         param1[3] = "Range: " + Str(RangeCalc(level));
         param1[4] = "";
         param1[5] = "";
      }
      
      override public function Upgrade() : Boolean
      {
         if(level == 5)
         {
            return false;
         }
         spent += this.UpgradePrice2(level);
         ++level;
         reloadTime = ReloadCalc(level);
         damage = DamageCalc(level) * dmgBuff;
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
         if(buildTime <= 0)
         {
            buildTime = 1;
         }
         return true;
      }
      
      override public function SetStats() : void
      {
         reloadTime = ReloadCalc(level);
         damage = DamageCalc(level) * dmgBuff;
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
      }
      
      override public function UpgradePrice2(param1:int) : int
      {
         return Tower_Shock.UpgradePrice(param1);
      }
   }
}

