package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Tower extends BaseGuy
   {
      
      public static var UpgradeImage:Class = Tower_UpgradeImage;
      
      public static const FIRE:int = 2;
      
      public var reloadTime:Number;
      
      public var damage:Number;
      
      public var secondVal:Number;
      
      public var range:Number;
      
      public var level:int;
      
      public var spent:int;
      
      public var name:String;
      
      public var upgrade1:Class = null;
      
      public var upgrade2:Class = null;
      
      public var dmgBuff:Number;
      
      public var dmgBuffTime:Number;
      
      public var reload:Number;
      
      public var target:BaseMonster;
      
      public var upgrade:FlxSprite;
      
      public var builder:Builder = new Builder();
      
      public var buildTime:Number;
      
      public var shockLoad:Number;
      
      public var instaLoadLimit:Number;
      
      public var noFire:Number;
      
      public var prevReload:Number;
      
      public function Tower(param1:int, param2:int)
      {
         super(param1,param2);
         this.Init(param1,param2);
         this.upgrade = new FlxSprite();
         this.upgrade.loadGraphic(UpgradeImage,false,false,4,4,true);
      }
      
      public static function BasePrice() : int
      {
         return 50;
      }
      
      public static function DamageCalc(param1:int) : Number
      {
         return 4 * param1 + 7;
      }
      
      public static function SecondCalc(param1:int) : Number
      {
         return 1;
      }
      
      public static function RangeCalc(param1:int) : int
      {
         return 100 + param1 * 10;
      }
      
      public static function ReloadCalc(param1:int) : Number
      {
         return 2 - 0.3 * param1;
      }
      
      public static function RateCalc(param1:int) : Number
      {
         return Math.round(1 / ReloadCalc(param1) * 100) / 100;
      }
      
      override public function Init(param1:int, param2:int) : void
      {
         solid = false;
         super.Init(param1,param2);
      }
      
      public function DoneBeingBorn() : void
      {
         this.reload = 0;
         action = IDLE;
         this.target = null;
         velocity.x = 0;
         velocity.y = 0;
      }
      
      override public function draw() : void
      {
         var _loc1_:int = 0;
         super.draw();
         this.upgrade.x = x + width / 2 - 7;
         this.upgrade.y = y - 5;
         _loc1_ = 0;
         while(_loc1_ < 3)
         {
            if(this.level > _loc1_)
            {
               this.upgrade.draw();
               this.upgrade.x += 5;
            }
            _loc1_++;
         }
         this.upgrade.x = x + width / 2 - 5;
         this.upgrade.y = y - 5 - 5;
         _loc1_ = 0;
         while(_loc1_ < 2)
         {
            if(this.level > _loc1_ + 3)
            {
               this.upgrade.draw();
               this.upgrade.x += 6;
            }
            _loc1_++;
         }
         if(this.buildTime > 0)
         {
            this.builder.draw();
         }
      }
      
      override public function Reset() : void
      {
         this.builder.owner = this;
         super.Reset();
         action = BORN;
         scale.x = 1;
         scale.y = 0;
         origin.y = height;
         color = 16777215;
         this.shockLoad = 0;
         this.instaLoadLimit = 0;
         this.noFire = 0;
         if(Global.randRange(0,1) < 0.5)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         this.buildTime = 2;
         this.level = 0;
         this.dmgBuff = 1;
         this.dmgBuffTime = 0;
      }
      
      public function UpdateBorn() : void
      {
         scale.y += FlxG.elapsed;
         if(scale.y >= 1)
         {
            scale.x = 1;
            scale.y = 1;
            action = IDLE;
            angle = 0;
            this.DoneBeingBorn();
         }
      }
      
      override public function update() : void
      {
         var _loc1_:BaseMonster = null;
         super.update();
         if(this.noFire > 0)
         {
            this.noFire -= FlxG.elapsed;
            this.reload = this.reloadTime;
            if(this.noFire <= 0)
            {
               this.reload = this.prevReload;
               this.noFire = 0;
            }
         }
         if(this.target != null && this.target.immune && !(this is Tower_Crippler) && !(this is Tower_Snow))
         {
            this.target = null;
         }
         if(this.instaLoadLimit > 0)
         {
            this.instaLoadLimit -= FlxG.elapsed;
         }
         this.shockLoad += FlxG.elapsed;
         while(this.shockLoad >= 1)
         {
            --this.shockLoad;
            if(Profile.skills[SkillDef.SHOCKTRAP])
            {
               for each(_loc1_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
               {
                  if(_loc1_.exists && !_loc1_.immune && _loc1_.health > 0 && _loc1_.y + _loc1_.height > y - 6 && _loc1_.y < y + height + 6 && DistanceToGuy(_loc1_) < 8)
                  {
                     Global.bullets.AddBullet(Lightning,Bullets.NEUTRAL,x + width / 2,y + height / 2,0,0);
                     Global.bullets.lastAdded.target = _loc1_;
                     Global.bullets.lastAdded.update();
                     _loc1_.hurt(Profile.skills[SkillDef.SHOCKTRAP]);
                  }
               }
            }
         }
         if(this.dmgBuffTime > 0)
         {
            this.dmgBuffTime -= FlxG.elapsed;
            if(this.dmgBuffTime <= 0)
            {
               this.dmgBuff = 1;
            }
         }
         if(this.buildTime > 0)
         {
            this.builder.update();
            this.buildTime -= FlxG.elapsed;
            if(this.buildTime <= 0)
            {
               this.buildTime = 0;
            }
         }
         if(action == BORN)
         {
            this.UpdateBorn();
            return;
         }
         if(this.reload > 0)
         {
            this.reload -= FlxG.elapsed;
         }
         else
         {
            this.reload = 0;
         }
      }
      
      public function Upgrade() : Boolean
      {
         if(this.level == 5)
         {
            return false;
         }
         this.spent += this.UpgradePrice(this.level);
         ++this.level;
         this.SetStats();
         return true;
      }
      
      public function SetStats() : void
      {
         this.reloadTime = ReloadCalc(this.level);
         this.damage = DamageCalc(this.level);
         this.range = RangeCalc(this.level);
         this.secondVal = SecondCalc(this.level);
      }
      
      public function UpgradePrice(param1:int) : int
      {
         return param1 * param1 * 5 + 30;
      }
      
      public function UpgradePrice2(param1:int) : int
      {
         return this.UpgradePrice(param1);
      }
      
      public function SellPrice() : int
      {
         return int(this.spent / 2);
      }
      
      public function UpgradeText(param1:Array) : void
      {
         if(this.level < 5)
         {
            param1[0] = "Upgrade " + this.name + " - $" + this.UpgradePrice(this.level).toString();
            param1[1] = "";
            param1[2] = "Damage: " + DamageCalc(this.level).toString() + " > " + DamageCalc(this.level + 1).toString();
            param1[3] = "Rate: " + RateCalc(this.level).toString() + " > " + RateCalc(this.level + 1).toString();
            param1[4] = "Range: " + RangeCalc(this.level).toString() + " > " + RangeCalc(this.level + 1).toString();
            param1[5] = "";
         }
         else
         {
            this.Describe(param1);
         }
      }
      
      public function Describe(param1:Array) : void
      {
         param1[0] = "Rock Tower L" + (this.level + 1).toString();
         param1[1] = "";
         param1[2] = "Damage: " + DamageCalc(this.level).toString();
         param1[3] = "Rate: " + RateCalc(this.level).toString();
         param1[4] = "Range: " + RangeCalc(this.level).toString();
         param1[5] = "";
      }
      
      public function SellText(param1:Array) : void
      {
         this.Describe(param1);
         param1[0] = "Sell " + this.name + " - $" + this.SellPrice().toString();
      }
      
      public function FindBelow(param1:Boolean, param2:Number, param3:Number) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:BaseMonster = null;
         this.target = null;
         for each(_loc9_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(_loc9_ != null && !_loc9_.immune && _loc9_.exists && _loc9_.health > 0)
            {
               if(!param1 && _loc9_.y > y + height || param1 && _loc9_.y + _loc9_.height < y + height + 3)
               {
                  if(param3 == 0)
                  {
                     _loc8_ = 0;
                  }
                  else
                  {
                     _loc8_ = (_loc9_.y + _loc9_.height / 2 - (y + height)) / param3;
                  }
                  _loc4_ = _loc9_.x + _loc8_ * _loc9_.velocity.x + _loc9_.width / 2;
                  if(_loc4_ < x + width / 2 + param2 && _loc4_ > x + width / 2 - param2)
                  {
                     this.target = _loc9_;
                     return;
                  }
               }
            }
         }
      }
      
      public function FindTarget(param1:Boolean = true, param2:Boolean = true, param3:Boolean = true, param4:Boolean = false, param5:Boolean = false, param6:Boolean = true) : void
      {
         var _loc7_:BaseMonster = null;
         this.target = null;
         if(Global.player.boxMode == Player.FOCUSMONSTER)
         {
            if((param5 || !(Global.player.target as BaseMonster).immune) && DistanceToGuy(Global.player.target) <= this.range && (param4 || LineOfSight(this,Global.player.target)) && (param1 || (Global.player.target as BaseMonster).frozen <= 0) && (param2 || (Global.player.target as BaseMonster).slowed <= 0) && (param3 || (Global.player.target as BaseMonster).shocking <= 0) && (param6 || (Global.player.target as BaseMonster).crippled <= 0))
            {
               this.target = Global.player.target as BaseMonster;
               return;
            }
         }
         for each(_loc7_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(_loc7_ != null && (param5 || !_loc7_.immune) && _loc7_.exists && _loc7_.health > 0 && (param1 || _loc7_.frozen <= 0) && (param2 || _loc7_.slowed <= 0) && (param3 || _loc7_.shocking <= 0) && (param6 || _loc7_.crippled <= 0))
            {
               if(DistanceToGuy(_loc7_) <= this.range && (param4 || LineOfSight(this,_loc7_)))
               {
                  if(this.target == null)
                  {
                     this.target = _loc7_;
                  }
                  else if(_loc7_.escaping && !this.target.escaping)
                  {
                     this.target = _loc7_;
                  }
                  else if(_loc7_.traveled > this.target.traveled)
                  {
                     this.target = _loc7_;
                  }
               }
            }
         }
         if(this.target == null && !param3)
         {
            this.FindTarget(param1,param2,true,param4);
         }
      }
      
      public function ChainLightning(param1:BaseMonster) : void
      {
         var _loc3_:BaseMonster = null;
         var _loc4_:* = 0;
         var _loc5_:int = 0;
         var _loc2_:Array = new Array();
         if(Profile.skills[SkillDef.CHAINLIGHTNING] == 0)
         {
            return;
         }
         for each(_loc3_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(_loc3_ != null && _loc3_ != param1 && !_loc3_.immune && _loc3_.exists && _loc3_.health > 0 && param1.DistanceToGuy(_loc3_) < 30)
            {
               _loc2_.push(_loc3_);
            }
         }
         _loc4_ = int(Profile.skills[SkillDef.CHAINLIGHTNING] + 1);
         while(_loc4_ > 0 && _loc2_.length > 0)
         {
            _loc5_ = int(Global.randRange(0,_loc2_.length));
            _loc3_ = _loc2_[_loc5_];
            _loc2_.splice(_loc5_,1);
            _loc4_--;
            Global.bullets.AddBullet(Lightning,Bullets.NEUTRAL,Global.randRange(param1.x + param1.width / 4,param1.x + param1.width * 3 / 4),Global.randRange(param1.y + param1.height / 4,param1.y + param1.height * 3 / 4),0,0);
            Global.bullets.lastAdded.target = _loc3_;
            Global.bullets.lastAdded.update();
            _loc3_.hurt(Profile.skills[SkillDef.CHAINLIGHTNING] * 2);
         }
      }
      
      public function Str(param1:Number) : String
      {
         param1 = int(param1 * 100) / 100;
         return param1.toString();
      }
      
      public function InstaLoad() : void
      {
         if(this.instaLoadLimit <= 0 && this.reload > 0)
         {
            this.reload = 0;
            this.instaLoadLimit = 10 - Profile.skills[SkillDef.FREE_PEBBLES];
         }
      }
   }
}

