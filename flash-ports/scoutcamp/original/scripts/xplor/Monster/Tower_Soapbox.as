package xplor.Monster
{
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower_Soapbox extends Tower
   {
      
      public static var TowerImage:Class = Tower_Soapbox_TowerImage;
      
      public var thrown:Boolean;
      
      public function Tower_Soapbox(param1:int, param2:int)
      {
         super(param1,param2);
         upgrade1 = Tower_Sling;
         loadGraphic(TowerImage,true,true,13,22,true);
         addAnimation("fire",[0,1,0,2,3,4,5,6,7,6,5,4,3,2],18,true);
         height = 20;
         origin.y = height;
         name = "Soapbox";
      }
      
      public static function BasePrice() : int
      {
         return 200 * (1 - Profile.skills[SkillDef.CONSTRUCTION] * 0.04);
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return 2 * param1 + 15 + Profile.skills[SkillDef.SOAPBOX] * 2;
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return (20 + param1 * 10) * (1 + Profile.skills[SkillDef.EAGLEEYE] * 0.02);
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return 0.5;
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
         y -= 4;
         spent = BasePrice();
         damage = DamageCalc(level);
         reloadTime = ReloadCalc(level);
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
         play("fire");
      }
      
      override public function SetStats() : void
      {
         reloadTime = ReloadCalc(level);
         damage = DamageCalc(level);
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
      }
      
      override public function update() : void
      {
         var _loc1_:Tower = null;
         super.update();
         if(action == BORN)
         {
            return;
         }
         play("fire");
         if(reload == 0)
         {
            for each(_loc1_ in Global.badguys.GetGroup(Badguys.TOWERS).members)
            {
               if(_loc1_ != this && _loc1_.exists && Global.Distance(_loc1_.x + _loc1_.width / 2,_loc1_.y + _loc1_.height / 2,x + width / 2,y + height / 2) <= range)
               {
                  _loc1_.dmgBuff = 1 + damage * 0.01;
                  _loc1_.dmgBuffTime = 0.7;
               }
            }
            reload = reloadTime;
         }
      }
      
      override public function UpgradeText(param1:Array) : void
      {
         if(level < 5)
         {
            param1[0] = "Upgrade " + name + " - $" + int(this.UpgradePrice2(level) * (1 - Profile.skills[SkillDef.ENHANCEMENT] * 0.03)).toString();
            param1[1] = "";
            param1[2] = "Damage Bonus: " + Str(DamageCalc(level)) + "% > " + Str(DamageCalc(level + 1)) + "%";
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
         param1[2] = "Damage Bonus: " + Str(DamageCalc(level)) + "%";
         param1[3] = "Range: " + Str(RangeCalc(level));
         param1[4] = "";
         param1[5] = "";
      }
      
      override public function Upgrade() : Boolean
      {
         var _loc1_:Tower = null;
         var _loc2_:Tower = null;
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
         if(Global.randRange(0,1) < Profile.skills[SkillDef.ENCOURAGEMENT] * 0.05)
         {
            _loc1_ = null;
            for each(_loc2_ in Global.badguys.GetGroup(Badguys.TOWERS).members)
            {
               if(_loc2_ != this && _loc2_.exists && Global.Distance(_loc2_.x + _loc2_.width / 2,_loc2_.y + _loc2_.height / 2,x + width / 2,y + height / 2) <= range)
               {
                  if(_loc1_ == null || Global.randRange(0,1) < 0.5)
                  {
                     _loc1_ = _loc2_;
                  }
               }
            }
            if(_loc1_ != null)
            {
               _loc1_.Upgrade();
            }
         }
         return true;
      }
      
      override public function UpgradePrice2(param1:int) : int
      {
         return Tower_Rock.UpgradePrice(param1);
      }
   }
}

