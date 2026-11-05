package xplor
{
   import org.flixel.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.*;
   
   public class Badguys
   {
      
      public static var levelToMake:int;
      
      public static const DEADLY:uint = 0;
      
      public static const FOOD:uint = 1;
      
      public static const TOWERS:uint = 2;
      
      public static const NUM_GROUPS:uint = 3;
      
      public var groups:Array;
      
      public function Badguys(param1:PlayState)
      {
         super();
         this.groups = new Array(new FlxGroup(),new FlxGroup(),new FlxGroup());
      }
      
      public function GetGroup(param1:int) : FlxGroup
      {
         if(param1 < 0 || param1 >= NUM_GROUPS)
         {
            return null;
         }
         return this.groups[param1];
      }
      
      public function AddToState(param1:uint, param2:PlayState) : void
      {
         param2.add(this.groups[param1] as FlxGroup);
      }
      
      public function AddGuy(param1:Class, param2:uint, param3:int, param4:int) : BaseGuy
      {
         var _loc5_:BaseGuy = new param1(param3,param4);
         (this.groups[param2] as FlxGroup).add(_loc5_);
         return _loc5_;
      }
      
      public function OnPlatform(param1:FlxObject, param2:FlxObject) : void
      {
      }
      
      public function GrabFood(param1:BaseMonster, param2:Food) : void
      {
         if(param2.holder == null && param1.escaping == false)
         {
            if(param2.Taken(param1))
            {
               param1.GotFood();
               if(param1 is Hungry)
               {
                  Sounds.play(Sounds.EatFoodSnd);
                  --Global.foodLeft;
                  param2.exists = false;
               }
               else
               {
                  Sounds.play(Sounds.TookFoodSnd);
               }
            }
         }
      }
      
      public function FoodIsGone(param1:BaseGuy) : void
      {
         var _loc2_:Food = null;
         for each(_loc2_ in (this.groups[FOOD] as FlxGroup).members)
         {
            if(_loc2_ != null && _loc2_.exists && _loc2_.holder == param1)
            {
               --Global.foodLeft;
               _loc2_.exists = false;
            }
         }
      }
      
      public function Collide() : void
      {
         FlxG.collide(PlayState(FlxG.state).border,this.groups[DEADLY] as FlxGroup);
         FlxG.collide(Global.level.GetLayer(Level.LAYER_SOLID),this.groups[FOOD] as FlxGroup);
         FlxG.collide(Global.level.GetLayer(Level.LAYER_SOLID),this.groups[DEADLY] as FlxGroup);
      }
      
      public function TargetEnemy(param1:FlxSprite, param2:int = 0) : FlxSprite
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:FlxSprite = null;
         var _loc8_:FlxSprite = null;
         _loc5_ = null;
         var _loc6_:FlxPoint = new FlxPoint(param1.x + param1.width / 2,param1.y + param1.height / 2);
         var _loc7_:FlxPoint = new FlxPoint();
         for each(_loc8_ in (this.groups[DEADLY] as FlxGroup).members)
         {
            if(_loc8_ != null && _loc8_.health > 0 && _loc8_.exists)
            {
               _loc7_.x = _loc8_.x + _loc8_.width / 2;
               _loc7_.y = _loc8_.y + _loc8_.height / 2;
               if((param2 == 0 || param2 == 1 && _loc7_.x < _loc6_.x || param2 == 2 && _loc7_.x > _loc6_.x) && Global.level.GetLayer(Level.LAYER_SOLID).ray(_loc6_,_loc7_,null,1))
               {
                  _loc3_ = Global.Distance(_loc6_.x,_loc6_.y,_loc7_.x,_loc7_.y);
                  if(_loc5_ == null || _loc3_ < _loc4_)
                  {
                     _loc5_ = _loc8_;
                     _loc4_ = _loc3_;
                  }
               }
            }
         }
         return _loc5_;
      }
      
      public function ResetAll() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            _loc2_ = 0;
            while(_loc2_ < (this.groups[_loc1_] as FlxGroup).length)
            {
               BaseGuy((this.groups[_loc1_] as FlxGroup).members[_loc2_]).Reset();
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function BadguysLeft() : int
      {
         var _loc1_:int = 0;
         var _loc2_:BaseGuy = null;
         _loc1_ = 0;
         for each(_loc2_ in this.groups[DEADLY].members)
         {
            if(_loc2_ != null && _loc2_.exists && _loc2_.health > 0)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function CursorOn(param1:uint, param2:int, param3:int) : BaseGuy
      {
         var _loc4_:BaseGuy = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         for each(_loc4_ in this.groups[param1].members)
         {
            if(_loc4_.exists && _loc4_.health > 0)
            {
               _loc5_ = _loc4_.x + _loc4_.width / 2;
               _loc6_ = _loc4_.y + _loc4_.height / 2;
               if(param2 > _loc5_ - 9 && param2 < _loc5_ + 9 && param3 > _loc6_ - 9 && param3 < _loc6_ + 9)
               {
                  return _loc4_;
               }
            }
         }
         return null;
      }
      
      public function BoxOn(param1:uint, param2:int, param3:int) : BaseGuy
      {
         var _loc4_:BaseGuy = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         for each(_loc4_ in this.groups[param1].members)
         {
            if(_loc4_.exists && _loc4_.health > 0)
            {
               _loc5_ = (_loc4_.x + _loc4_.width / 2) / 16;
               _loc6_ = (_loc4_.y + _loc4_.height / 2) / 16;
               if(_loc5_ == param2 && _loc6_ == param3)
               {
                  return _loc4_;
               }
            }
         }
         return null;
      }
      
      public function DeepFreeze(param1:int) : void
      {
         var _loc2_:BaseMonster = null;
         if(Profile.skills[SkillDef.SELL_TOWER] == 0)
         {
            return;
         }
         for each(_loc2_ in this.groups[DEADLY].members)
         {
            if(_loc2_.exists && _loc2_.health > 0)
            {
               _loc2_.ExtendaFreeze(Profile.skills[SkillDef.SELL_TOWER] * 0.2 * (param1 + 1));
            }
         }
      }
      
      public function TowerLoad(param1:FlxSprite) : void
      {
         var _loc2_:Tower = null;
         for each(_loc2_ in this.groups[TOWERS].members)
         {
            if(_loc2_.exists && _loc2_ is Tower_Sling && _loc2_.reload > 0 && _loc2_.DistanceToGuy(param1) < 8)
            {
               _loc2_.InstaLoad();
            }
         }
      }
      
      public function ShockNeighborPower(param1:FlxSprite) : Number
      {
         var _loc3_:Tower = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in this.groups[TOWERS].members)
         {
            if(_loc3_.exists && _loc3_ is Tower_Shock && _loc3_.DistanceToGuy(param1) < 19)
            {
               if(_loc2_ < _loc3_.damage)
               {
                  _loc2_ = _loc3_.damage;
               }
            }
         }
         return _loc2_;
      }
   }
}

