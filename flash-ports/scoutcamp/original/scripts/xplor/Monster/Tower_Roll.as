package xplor.Monster
{
   import org.flixel.FlxTilemapExt;
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower_Roll extends Tower
   {
      
      public static var TowerImage:Class = Tower_Roll_TowerImage;
      
      public var thrown:Boolean;
      
      public function Tower_Roll(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(TowerImage,true,true,16,26,true);
         addAnimation("fire",[2,2,3,3,3,3,2,0],30,false);
         height = 24;
         origin.y = height;
         name = "Roly Poly";
      }
      
      public static function BasePrice() : int
      {
         return 100 * (1 - Profile.skills[SkillDef.CONSTRUCTION] * 0.04);
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return (4 * param1 + 15) * (1 + Profile.skills[SkillDef.HARDROCK] * 0.05 + Profile.skills[SkillDef.FIREPOWER] * 0.02);
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return (25 + param1 * 10) * (1 + Profile.skills[SkillDef.EAGLEEYE] * 0.02);
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return (5 - 0.4 * param1) * (1 - Profile.skills[SkillDef.RAPIDFIRE] * 0.02 - Profile.skills[SkillDef.ROCKNROLL] * 0.05);
      }
      
      public static function UpgradePrice(param1:int) : int
      {
         return (param1 + 1) * (param1 + 1) * (param1 + 1) * 8 + 100;
      }
      
      public static function RateCalc(param1:int) : Number
      {
         return Math.round(1 / ReloadCalc(param1) * 100) / 100;
      }
      
      public static function SecondCalc(param1:int) : Number
      {
         return Profile.skills[SkillDef.ROLYPOLY] + 5;
      }
      
      override public function Reset() : void
      {
         super.Reset();
         y -= 8;
         spent = BasePrice();
         damage = DamageCalc(level) * dmgBuff;
         reloadTime = ReloadCalc(level);
         range = RangeCalc(level);
         secondVal = SecondCalc(level);
      }
      
      override public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         super.update();
         if(action == BORN)
         {
            return;
         }
         FindTarget();
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
               _loc1_ = int((x + width / 2) / 16) + 1;
               if(facing == LEFT)
               {
                  _loc1_ = x - 1;
               }
               _loc2_ = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,int((y + height / 2) / 16)));
               if(_loc2_ == 0 || Boolean((Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[_loc2_]))
               {
                  action = FIRE;
                  this.thrown = false;
                  reload = reloadTime;
                  play("fire");
               }
            }
         }
         else if(action == FIRE)
         {
            if(_curFrame >= 4 && !this.thrown)
            {
               this.thrown = true;
               damage = DamageCalc(level) * dmgBuff;
               Global.bullets.AddBullet(Boulder,Bullets.GOOD,x + width / 2,y + height / 2,int(facing == LEFT),damage);
               (Global.bullets.lastAdded as Boulder).range = SecondCalc(level) * 16;
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
            param1[3] = "Distance: " + Str(SecondCalc(level)) + " tiles";
            param1[4] = "Rate: " + Str(RateCalc(level)) + " > " + Str(RateCalc(level + 1));
            param1[5] = "Range: " + Str(RangeCalc(level)) + " > " + Str(RangeCalc(level + 1));
         }
         else
         {
            this.Describe(param1);
         }
      }
      
      override public function Describe(param1:Array) : void
      {
         param1[0] = "Roly Poly L" + (level + 1).toString();
         param1[1] = "";
         param1[2] = "Damage: " + Str(DamageCalc(level) * dmgBuff);
         param1[3] = "Distance: " + Str(SecondCalc(level)) + " tiles";
         param1[4] = "Rate: " + Str(RateCalc(level));
         param1[5] = "Range: " + Str(RangeCalc(level));
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

