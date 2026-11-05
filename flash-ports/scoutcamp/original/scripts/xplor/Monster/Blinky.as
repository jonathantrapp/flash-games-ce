package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Bullet.HealPlus;
   import xplor.Bullets;
   import xplor.Global;
   
   public class Blinky extends BaseMonster
   {
      
      public static var SkellyImage:Class = Blinky_SkellyImage;
      
      public var healLoad:Number;
      
      public function Blinky(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SkellyImage,true,true,13,17,true);
         addAnimation("walk",[0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,4,5,6,7,6,5,4],16,true);
         addAnimation("jump",[0,1,2,3],10,true);
         addAnimation("disabledwalk",[8,9,10,11],16,true);
         addAnimation("disabledjump",[8,9,10,11],10,true);
         width = 5;
         offset.x = 4;
         speed = 20;
         height = 16;
         name = "Blinky";
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
         this.healLoad = 0;
         super.Reset();
      }
      
      override public function BasicUpdate() : void
      {
         var _loc1_:BaseMonster = null;
         super.BasicUpdate();
         if(!disabled)
         {
            this.healLoad -= FlxG.elapsed;
            while(this.healLoad <= 0)
            {
               this.healLoad += 0.5;
               for each(_loc1_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
               {
                  if(_loc1_ != this && _loc1_ != null && _loc1_.exists && _loc1_.health > 0 && DistanceToGuy(_loc1_) < 60)
                  {
                     _loc1_.health += level;
                     if(_loc1_.health > _loc1_.maxHealth)
                     {
                        _loc1_.health = _loc1_.maxHealth;
                     }
                     Global.bullets.AddBullet(HealPlus,Bullets.NEUTRAL,_loc1_.x - 3 + Global.randRange(0,_loc1_.width + 6),_loc1_.y + Global.randRange(0,_loc1_.height / 2),0,0);
                  }
               }
            }
         }
      }
   }
}

