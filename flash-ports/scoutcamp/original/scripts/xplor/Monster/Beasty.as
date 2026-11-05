package xplor.Monster
{
   import xplor.Badguys;
   
   public class Beasty extends BaseMonster
   {
      
      public static var SkellyImage:Class = Beasty_SkellyImage;
      
      public function Beasty(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SkellyImage,true,true,25,23,true);
         addAnimation("walk",[1,2,3,4,5,6],10,true);
         addAnimation("jump",[7],10,true);
         addAnimation("disabledwalk",[1,2,3,4,5,6],10,true);
         addAnimation("disabledjump",[7],10,true);
         width = 5;
         offset.x = 10;
         speed = 10;
         height = 14;
         offset.y = 8;
         name = "Beasty";
         this.Init(param1,param2);
      }
      
      public static function Life(param1:int) : int
      {
         return 100 + param1 * 30;
      }
      
      public static function Money(param1:int) : int
      {
         return 50 + param1 * 5;
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

