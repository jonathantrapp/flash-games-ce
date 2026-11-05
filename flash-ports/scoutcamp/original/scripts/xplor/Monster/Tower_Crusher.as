package xplor.Monster
{
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower_Crusher extends Tower
   {
      
      public static var TowerImage:Class = Tower_Crusher_TowerImage;
      
      public var thrown:Boolean;
      
      public function Tower_Crusher(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(TowerImage,true,true,16,16,true);
         addAnimation("fire",[5,6,7,7,7,7,7,7,6,5,0],30,false);
         height = 14;
         origin.y = height;
         name = "Crusher";
      }
      
      public static function BasePrice() : int
      {
         return 100 * (1 - Profile.skills[SkillDef.CONSTRUCTION] * 0.04);
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return (8 * param1 + 15) * (1 + Profile.skills[SkillDef.HARDROCK] * 0.05 + Profile.skills[SkillDef.FIREPOWER] * 0.02);
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return 0;
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return (3.75 - 0.25 * Profile.skills[SkillDef.CRUSHER]) * (1 - Profile.skills[SkillDef.RAPIDFIRE] * 0.02 - Profile.skills[SkillDef.ROCKNROLL] * 0.05);
      }
      
      public static function UpgradePrice(param1:int) : int
      {
         return Tower_Roll.UpgradePrice(param1);
      }
      
      public static function RateCalc(param1:int) : Number
      {
         return Math.round(1 / ReloadCalc(param1) * 100) / 100;
      }
      
      public static function SecondCalc(param1:int) : Number
      {
         return Profile.skills[SkillDef.ROLYPOLY] * 2;
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
         facing = RIGHT;
      }
      
      override public function update() : void
      {
         var _loc1_:Number = NaN;
         super.update();
         if(action == BORN)
         {
            return;
         }
         FindBelow(false,10,200);
         if(action == IDLE)
         {
            _loc1_ = 1 - reload / reloadTime;
            if(reload <= 0)
            {
               frame = 4;
            }
            else if(_loc1_ >= 0.75)
            {
               frame = 3;
            }
            else if(_loc1_ >= 0.5)
            {
               frame = 2;
            }
            else if(_loc1_ >= 0.25)
            {
               frame = 1;
            }
            else
            {
               frame = 0;
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
            if(!this.thrown)
            {
               this.thrown = true;
               damage = DamageCalc(level) * dmgBuff;
               Global.bullets.AddBullet(BoulderDrop,Bullets.GOOD,x + width / 2,y + height / 2,0,damage);
            }
            if(finished)
            {
               action = IDLE;
               frame = 0;
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
            param1[3] = "Rate: " + Str(RateCalc(level));
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
         param1[2] = "Damage: " + Str(DamageCalc(level) * dmgBuff);
         param1[3] = "Rate: " + Str(RateCalc(level));
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
         return Tower_Roll.UpgradePrice(param1);
      }
   }
}

