package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower_Slushee extends Tower
   {
      
      public static var TowerImage:Class = Tower_Slushee_TowerImage;
      
      public var thrown:Boolean;
      
      public var miniReload:Number;
      
      public function Tower_Slushee(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(TowerImage,true,true,11,15,true);
         addAnimation("idle",[0,1,2,3,4,5,6,5,4,3,2,1],8,true);
         addAnimation("fire",[7,8,9,9,9,9,9,9,8,7],10,false);
         height = 13;
         origin.y = height;
         name = "Slushee Maker";
      }
      
      public static function BasePrice() : int
      {
         return 70 * (1 - Profile.skills[SkillDef.CONSTRUCTION] * 0.04);
      }
      
      public static function UpgradePrice(param1:int) : int
      {
         return Tower_Snow.UpgradePrice(param1);
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return 0.25 + Profile.skills[SkillDef.SLUSHEE] * 0.05;
      }
      
      public static function SecondCalc(param1:int) : Number
      {
         return 1.5 + param1 * 1.5;
      }
      
      public static function RateCalc(param1:int) : Number
      {
         return Math.round(1 / ReloadCalc(param1) * 100) / 100;
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return 10;
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return (4 - 0.4 * param1) * (1 - Profile.skills[SkillDef.RAPIDFIRE] * 0.02);
      }
      
      override public function Reset() : void
      {
         super.Reset();
         x += 2;
         y += 2;
         spent = BasePrice();
         damage = DamageCalc(level);
         reloadTime = ReloadCalc(level);
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
      }
      
      override public function update() : void
      {
         super.update();
         if(action == BORN)
         {
            return;
         }
         if(action == IDLE)
         {
            play("idle");
            if(reload == 0)
            {
               FindBelow(false,10,150);
               if(target != null)
               {
                  action = FIRE;
                  this.thrown = false;
                  reload = reloadTime;
                  this.miniReload = 0.05;
                  play("fire");
               }
            }
         }
         else if(action == FIRE)
         {
            if(_curFrame >= 0 && _curFrame < 7)
            {
               this.miniReload -= FlxG.elapsed;
               while(this.miniReload < 0)
               {
                  Global.bullets.AddBullet(Slushball,Bullets.GOOD,x + Global.randRange(0,width),y + height + 5,0,damage);
                  Global.bullets.lastAdded.power = SecondCalc(level);
                  this.miniReload += 0.05;
               }
            }
            if(finished)
            {
               action = IDLE;
               play("idle");
            }
         }
      }
      
      override public function UpgradeText(param1:Array) : void
      {
         if(level < 5)
         {
            param1[0] = "Upgrade " + name + " - $" + int(this.UpgradePrice2(level) * (1 - Profile.skills[SkillDef.ENHANCEMENT] * 0.03)).toString();
            param1[1] = "";
            param1[2] = "Slow: " + Str(DamageCalc(level) * 100) + "%";
            param1[3] = "Time: " + Str(SecondCalc(level)) + "s > " + Str(SecondCalc(level + 1)) + "s";
            param1[4] = "Rate: " + Str(RateCalc(level)) + " > " + Str(RateCalc(level + 1));
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
         param1[2] = "Slow: " + Str(DamageCalc(level) * 100) + "%";
         param1[3] = "Time: " + Str(SecondCalc(level)) + "s";
         param1[4] = "Rate: " + Str(RateCalc(level));
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
         damage = DamageCalc(level);
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
         damage = DamageCalc(level);
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
      }
      
      override public function UpgradePrice2(param1:int) : int
      {
         return Tower_Snow.UpgradePrice(param1);
      }
   }
}

