package xplor.Monster
{
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower_Quake extends Tower
   {
      
      public static var TowerImage:Class = Tower_Quake_TowerImage;
      
      public var tick:Number;
      
      public var chainTick:Number;
      
      public function Tower_Quake(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(TowerImage,true,true,17,20,true);
         height = 18;
         width = 16;
         origin.y = height;
         name = "Quake-O-Matic";
      }
      
      public static function BasePrice() : int
      {
         return 100 * (1 - Profile.skills[SkillDef.CONSTRUCTION] * 0.04);
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return (3 + 1 * param1) * (1 + Profile.skills[SkillDef.FIREPOWER] * 0.02);
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return (16 + 4.8 * Profile.skills[SkillDef.QUAKE]) * (1 + Profile.skills[SkillDef.EAGLEEYE] * 0.02);
      }
      
      public static function SecondCalc(param1:int) : int
      {
         return 0;
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return (1.6 - param1 * 0.13) * (1 - Profile.skills[SkillDef.RAPIDFIRE] * 0.02 - Profile.skills[SkillDef.ROCKNROLL] * 0.05);
      }
      
      public static function UpgradePrice(param1:int) : int
      {
         return Tower_Roll.UpgradePrice(param1);
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
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:BaseMonster = null;
         var _loc8_:Number = NaN;
         var _loc9_:Tower = null;
         super.update();
         if(action == BORN)
         {
            return;
         }
         frame = 7 - int(reload * 8 / reloadTime);
         if(reload <= 0)
         {
            reload = reloadTime;
            _loc2_ = range * 2 / Profile.skills[SkillDef.QUAKE];
            _loc5_ = (y + height / 2) / 16;
            _loc1_ = 0;
            while(_loc1_ < Profile.skills[SkillDef.QUAKE] + 1)
            {
               _loc6_ = x + width / 2 - range + _loc2_ * _loc1_ + Global.randRange(-6,6);
               _loc3_ = _loc6_ / 16;
               _loc4_ = _loc5_ - 2;
               while(_loc4_ < _loc5_ + 3)
               {
                  if(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc3_,_loc4_) == 0 && Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc3_,_loc4_ + 1) != 0)
                  {
                     break;
                  }
                  _loc4_++;
               }
               if(_loc4_ < _loc5_ + 3)
               {
                  Global.bullets.AddBullet(SmokePuff,Bullets.BACKGD,_loc6_,_loc4_ * 16 + 16 + Global.randRange(-4,4),0,0);
               }
               _loc1_++;
            }
            for each(_loc7_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
            {
               if(_loc7_.exists && !_loc7_.immune && _loc7_.health > 0 && _loc7_.y + _loc7_.height > y - 16 && _loc7_.y < y + height + 16 && DistanceToGuy(_loc7_) < range)
               {
                  _loc8_ = damage;
                  if(_loc7_.frozen > 0 || _loc7_.slowed > 0)
                  {
                     _loc8_ *= 1 + Profile.skills[SkillDef.BRITTLE_BONES] * 0.05;
                  }
                  if(Global.randRange(0,1) < 0.03 * Profile.skills[SkillDef.QUAKEUP])
                  {
                     BaseMonster.noCrit = true;
                     Global.bullets.AddBullet(Critical,Bullets.NEUTRAL,_loc7_.x + Global.randRange(0,_loc7_.width),_loc7_.y + Global.randRange(0,_loc7_.height),0,0);
                     _loc7_.hurt(_loc8_ * 2);
                  }
                  else
                  {
                     _loc7_.hurt(_loc8_);
                  }
               }
            }
            if(Profile.skills[SkillDef.ROLLING_THUNDER])
            {
               for each(_loc9_ in Global.badguys.GetGroup(Badguys.TOWERS).members)
               {
                  if(_loc9_.exists && _loc9_ is Tower_LightningRod && _loc9_.y + _loc9_.height > y - 16 && _loc9_.y < y + height + 16 && DistanceToGuy(_loc9_) < range)
                  {
                     if(_loc9_.reload > 0)
                     {
                        _loc9_.reload -= Profile.skills[SkillDef.ROLLING_THUNDER] * 0.05;
                     }
                  }
               }
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
            param1[4] = "Range: " + Str(RangeCalc(level));
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
         return Tower_Roll.UpgradePrice(param1);
      }
   }
}

