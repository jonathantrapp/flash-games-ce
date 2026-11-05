package xplor.Monster
{
   import xplor.Badguys;
   
   public class Squirmy extends BaseMonster
   {
      
      public static var SquirmyImage:Class = Squirmy_SquirmyImage;
      
      public function Squirmy(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SquirmyImage,true,true,16,14,true);
         addAnimation("walk",[0,1,2,3],10,true);
         addAnimation("jump",[4],10,true);
         addAnimation("disabledwalk",[0,1,2,3],10,true);
         addAnimation("disabledjump",[4],10,true);
         width = 5;
         offset.x = 7.5;
         height = 13;
         name = "Squirmy";
         speed = 40;
         this.Init(param1,param2);
      }
      
      public static function Life(param1:int) : int
      {
         return 1 + param1 * 1;
      }
      
      public static function Money(param1:int) : int
      {
         return 1 + param1 * 0.25;
      }
      
      override public function Init(param1:int, param2:int) : void
      {
         solid = true;
         super.Init(param1,param2);
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
      }
   }
}

