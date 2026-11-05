package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Bullet.Eek;
   import xplor.Bullets;
   import xplor.Global;
   
   public class Scary extends BaseMonster
   {
      
      public static var SkellyImage:Class = Scary_SkellyImage;
      
      public var blockLoad:Number;
      
      public function Scary(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SkellyImage,true,true,16,15,true);
         addAnimation("walk",[0,1,2,3],10,true);
         addAnimation("disabledwalk",[4,5,6,7],10,true);
         addAnimation("disabledjump",[5],10,true);
         width = 5;
         offset.x = 5.5;
         speed = 20;
         height = 14;
         name = "Scary";
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
         this.blockLoad = 0;
      }
      
      override public function BasicUpdate() : void
      {
         var _loc1_:Tower = null;
         super.BasicUpdate();
         if(disabled <= 0)
         {
            this.blockLoad += FlxG.elapsed;
            if(this.blockLoad >= 0.25)
            {
               this.blockLoad -= 0.25;
               for each(_loc1_ in Global.badguys.GetGroup(Badguys.TOWERS).members)
               {
                  if(_loc1_ != null && _loc1_.exists && DistanceToGuy(_loc1_) < 60)
                  {
                     if(_loc1_.noFire <= 0)
                     {
                        _loc1_.prevReload = _loc1_.reload;
                     }
                     _loc1_.noFire = 0.3;
                     _loc1_.reload = _loc1_.reloadTime;
                     if(Global.randRange(0,1) < 0.5)
                     {
                        Global.bullets.AddBullet(Eek,Bullets.NEUTRAL,_loc1_.x - 3 + Global.randRange(0,_loc1_.width + 6),_loc1_.y + Global.randRange(0,_loc1_.height / 2),0,0);
                     }
                  }
               }
            }
         }
      }
   }
}

