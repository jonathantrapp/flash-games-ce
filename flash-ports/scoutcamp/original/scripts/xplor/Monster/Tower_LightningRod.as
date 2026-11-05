package xplor.Monster
{
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower_LightningRod extends Tower
   {
      
      public static var TowerImage:Class = Tower_LightningRod_TowerImage;
      
      public var thrown:Boolean;
      
      public function Tower_LightningRod(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(TowerImage,true,true,10,21,true);
         height = 20;
         origin.y = height;
         name = "Lightning Rod";
      }
      
      public static function BasePrice() : int
      {
         return 100 * (1 - Profile.skills[SkillDef.CONSTRUCTION] * 0.04);
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return (Profile.skills[SkillDef.LIGHTNINGROD] * 15 + 35 + 10 * param1) * (1 + Profile.skills[SkillDef.FIREPOWER] * 0.02);
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return 0;
      }
      
      public static function SecondCalc(param1:int) : int
      {
         return 0;
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return (7 - param1 * 0.5) * (1 - Profile.skills[SkillDef.RAPIDFIRE] * 0.02);
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
         y -= 4;
         x += 3;
         spent = BasePrice();
         damage = DamageCalc(level) * dmgBuff;
         reloadTime = ReloadCalc(level);
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
         reload = reloadTime;
      }
      
      override public function update() : void
      {
         var _loc2_:BaseMonster = null;
         var _loc3_:BaseMonster = null;
         super.update();
         if(action == BORN)
         {
            return;
         }
         var _loc1_:Number = 1 - reload / reloadTime;
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
         FindBelow(true,10,0);
         if(action == IDLE)
         {
            if(reload == 0 && target != null)
            {
               action = FIRE;
               this.thrown = false;
               reload = reloadTime;
            }
         }
         else if(action == FIRE)
         {
            action = IDLE;
            Global.bullets.AddBullet(SuperLightning,Bullets.NEUTRAL,x + width / 2,y + 2,0,0);
            _loc2_ = null;
            Sounds.play(Sounds.LightningSnd);
            for each(_loc3_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
            {
               if(_loc3_ != null && !_loc3_.immune && _loc3_.exists && _loc3_.health > 0 && _loc3_.y + _loc3_.height < y + height + 3 && _loc3_.x < x + width / 2 + 10 && _loc3_.x + _loc3_.width > x + width / 2 - 10)
               {
                  if(Global.randRange(0,1) < Profile.skills[SkillDef.HEARTSTOPPER] * 0.02)
                  {
                     _loc3_.health = 1;
                     Global.bullets.AddBullet(Megawatt,Bullets.NEUTRAL,_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2,0,0);
                  }
                  _loc3_.hurt(damage);
                  _loc2_ = _loc3_;
               }
            }
            if(_loc2_ != null)
            {
               ChainLightning(_loc2_);
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
            param1[4] = "Range: To the moon!";
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
         param1[4] = "Range: To the moon!";
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

