package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   
   public class FireMan extends BaseMonster
   {
      
      public static var YakImage:Class = FireMan_YakImage;
      
      public var bitTime:Number;
      
      public function FireMan(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,15,32,true);
         addAnimation("idle",[0,1,2,3],10,true);
         width = 11;
         offset.x = 2;
         speed = 15;
         height = 14;
         offset.y = 17;
         name = "Fire Man";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 5 + lvl * 6;
      }
      
      public static function Money(lvl:int) : int
      {
         return 10 + lvl * 1.5;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         super.Init(tx,ty);
         throwable = false;
      }
      
      override public function hurt(n:Number) : void
      {
      }
      
      override public function Knockback(facing:int, xspd:Number, yspd:Number) : void
      {
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         solid = false;
         acceleration.y = 0;
         velocity.y = 0;
         this.bitTime = Global.randRange(0,0.4);
         play("idle");
         reload = 0;
      }
      
      override public function BasicUpdate() : void
      {
         var tx:int = 0;
         var ty:int = 0;
         if(WillBumpWall() || WillFall() || isTouching(WALL))
         {
            facing = LEFT + RIGHT - facing;
         }
         tx = (x + width / 2) / Global.TILE_WIDTH;
         ty = (y + height / 2) / Global.TILE_HEIGHT;
         var p:int = int(Global.level.jumps[tx + ty * Global.level.width]);
         if(p == 10)
         {
            facing = RIGHT;
         }
         else if(p == 11)
         {
            facing = LEFT;
         }
         velocity.x = 30 - 60 * int(facing == LEFT);
         this.bitTime -= FlxG.elapsed;
         if(this.bitTime <= 0)
         {
            if(onScreen())
            {
               Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + width / 2,y + height / 4,Global.randRange(0,360),0);
            }
            this.bitTime += Global.randRange(0.02,0.1);
         }
         if(reload > 0)
         {
            reload -= FlxG.elapsed;
         }
         if(reload <= 0 && DistanceToGuy(Global.pedro) < 12)
         {
            reload = 0.5;
            Global.pedro.hurt(1);
            if(Global.pedro.x + Global.pedro.width / 2 < x + width / 2)
            {
               Global.pedro.Knockback(LEFT,40,-40);
            }
            else
            {
               Global.pedro.Knockback(RIGHT,40,-40);
            }
         }
      }
   }
}

