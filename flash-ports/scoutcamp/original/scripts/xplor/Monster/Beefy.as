package xplor.Monster
{
   import xplor.Badguys;
   
   public class Beefy extends BaseMonster
   {
      
      public static var SkellyImage:Class = Beefy_SkellyImage;
      
      public function Beefy(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SkellyImage,true,true,20,21,true);
         addAnimation("walk",[0,1,2,3,4,5,6],10,true);
         addAnimation("jump",[7],10,true);
         addAnimation("disabledwalk",[0,1,2,3,4,5,6],10,true);
         addAnimation("disabledjump",[7],10,true);
         width = 5;
         offset.x = 7.5;
         speed = 15;
         height = 14;
         offset.y = 6;
         name = "Beefy";
         this.Init(param1,param2);
      }
      
      public static function Life(param1:int) : int
      {
         return 15 + param1 * 6;
      }
      
      public static function Money(param1:int) : int
      {
         return 10 + param1 * 1.5;
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

