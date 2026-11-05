package xplor.Monster
{
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower_Sling extends Tower
   {
      
      public static var TowerImage:Class = Tower_Sling_TowerImage;
      
      public var thrown:Boolean;
      
      public function Tower_Sling(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(TowerImage,true,true,16,16,true);
         addAnimation("fire",[2,3,4,5,6,7,7,7,7,8,9,10,11,0],30,false);
         height = 14;
         origin.y = height;
         name = "Slingshot Tower";
      }
      
      public static function BasePrice() : int
      {
         return 150 * (1 - Profile.skills[SkillDef.CONSTRUCTION] * 0.04);
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return (7.5 * param1 + 20 + Profile.skills[SkillDef.SLINGSHOT] * 3) * (1 + Profile.skills[SkillDef.HARDROCK] * 0.05 + Profile.skills[SkillDef.FIREPOWER] * 0.02);
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return (120 + param1 * 30) * (1 + Profile.skills[SkillDef.EAGLEEYE] * 0.02);
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return (6 - 0.6 * param1) * (1 - Profile.skills[SkillDef.RAPIDFIRE] * 0.02);
      }
      
      public static function UpgradePrice(param1:int) : int
      {
         return Tower_Rock.UpgradePrice(param1);
      }
      
      public static function RateCalc(param1:int) : Number
      {
         return Math.round(1 / ReloadCalc(param1) * 100) / 100;
      }
      
      override public function Reset() : void
      {
         super.Reset();
         y += 2;
         spent = BasePrice();
         damage = DamageCalc(level) * dmgBuff;
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
         FindTarget(true,true,true,true);
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
            if(reload == 0 && target != null)
            {
               action = FIRE;
               this.thrown = false;
               reload = reloadTime;
               play("fire");
            }
         }
         else if(action == FIRE)
         {
            if(target == null)
            {
               action = IDLE;
               frame = 0;
               return;
            }
            if(_curFrame >= 8 && !this.thrown)
            {
               this.thrown = true;
               damage = DamageCalc(level) * dmgBuff;
               Global.bullets.AddBullet(SlingBullet,Bullets.GOOD,x + width / 2,y + 3,Global.AngleBetweenGuys(this,target),damage);
               Global.bullets.lastAdded.target = target;
            }
            if(finished)
            {
               action = IDLE;
            }
         }
      }
      
      override public function UpgradeText(param1:Array) : void
      {
         if(level < 5)
         {
            param1[0] = "Upgrade " + name + " - $" + int(this.UpgradePrice2(level) * (1 - Profile.skills[SkillDef.ENHANCEMENT] * 0.03)).toString();
            param1[1] = "";
            param1[2] = "Damage: " + Str(DamageCalc(level) * dmgBuff) + " > " + Str(DamageCalc(level + 1) * dmgBuff);
            param1[3] = "Rate: " + Str(RateCalc(level)) + " > " + Str(RateCalc(level + 1));
            param1[4] = "Range: " + Str(RangeCalc(level)) + " > " + Str(RangeCalc(level + 1));
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
         param1[2] = "Damage: " + Str(DamageCalc(level) * dmgBuff);
         param1[3] = "Rate: " + Str(RateCalc(level));
         param1[4] = "Range: " + Str(RangeCalc(level));
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
         return Tower_Rock.UpgradePrice(param1);
      }
   }
}

