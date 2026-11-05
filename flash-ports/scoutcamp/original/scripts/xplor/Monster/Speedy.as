package xplor.Monster
{
   import xplor.Badguys;
   import xplor.Global;
   
   public class Speedy extends BaseMonster
   {
      
      public static var SquirmyImage:Class = Speedy_SquirmyImage;
      
      public function Speedy(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SquirmyImage,true,true,16,14,true);
         addAnimation("walk",[0,1,2,3],10,true);
         addAnimation("jump",[4],10,true);
         addAnimation("disabledwalk",[5,6,7,8],10,true);
         addAnimation("disabledjump",[9],10,true);
         width = 5;
         offset.x = 7.5;
         height = 13;
         name = "Speedy";
         speed = 40;
         this.Init(param1,param2);
      }
      
      public static function Life(param1:int) : int
      {
         return 3 + param1 * 2;
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
      
      override public function update() : void
      {
         var _loc1_:BaseMonster = null;
         super.update();
         if(!disabled)
         {
            for each(_loc1_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
            {
               if(_loc1_ != this && _loc1_ != null && !(_loc1_ is Speedy) && _loc1_.exists && _loc1_.health > 0 && DistanceToGuy(_loc1_) < 40)
               {
                  _loc1_.speedUp = 0.5;
               }
            }
         }
      }
   }
}

