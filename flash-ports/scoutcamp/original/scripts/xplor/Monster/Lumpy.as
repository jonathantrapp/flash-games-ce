package xplor.Monster
{
   import xplor.Badguys;
   
   public class Lumpy extends BaseMonster
   {
      
      public static var SkellyImage:Class = Lumpy_SkellyImage;
      
      public function Lumpy(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SkellyImage,true,true,15,17,true);
         addAnimation("walk",[0,1,2,3,0,4,5,6],10,true);
         addAnimation("jump",[7],10,true);
         addAnimation("disabledwalk",[0,1,2,3,0,4,5,6],10,true);
         addAnimation("disabledjump",[7],10,true);
         width = 5;
         offset.x = 5;
         speed = 20;
         height = 16;
         name = "Lumpy";
         this.Init(param1,param2);
      }
      
      public static function Life(param1:int) : int
      {
         return 3 + param1 * 2;
      }
      
      public static function Money(param1:int) : int
      {
         return 5 + param1 * 0.75;
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

