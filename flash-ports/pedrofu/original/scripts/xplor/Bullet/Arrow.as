package xplor.Bullet
{
   import org.flixel.FlxG;
   import org.flixel.FlxObject;
   import xplor.Badguys;
   import xplor.Bullets;
   import xplor.Global;
   import xplor.Monster.BaseMonster;
   
   public class Arrow extends BaseBullet
   {
      
      public static var ArrowImage:Class = Arrow_ArrowImage;
      
      public var fireTime:Number;
      
      public function Arrow()
      {
         super();
         loadGraphic(ArrowImage,true,false,11,3,true);
         width = 3;
         offset.x = 4;
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         reflected = false;
         frozen = 0;
         this.damage = 1;
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = true;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         angle = a;
         velocity.x = Global.Cosine(a) * 140;
         velocity.y = Global.Sine(a) * 140;
         acceleration.y = 100;
         if(dmg == 2)
         {
            acceleration.y = 0;
         }
         this.fireTime = 0;
      }
      
      override public function hurt(n:Number) : void
      {
         exists = false;
         for(var i:int = 0; i < 8; i++)
         {
            Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + width / 2,y + height / 2,Global.randRange(0,360),0);
         }
      }
      
      public function Hit(me:FlxObject, you:FlxObject) : void
      {
         Global.pedro.hurt(1);
         if(Global.pedro.reflect)
         {
            reflected = true;
            if(angle < 180)
            {
               angle = 180 - angle;
            }
            else
            {
               angle = 360 - angle;
            }
            velocity.x = Global.Cosine(angle) * 140;
            velocity.y = Global.Sine(angle) * 140;
            Global.pedro.reflect = false;
         }
         else
         {
            this.hurt(1);
         }
      }
      
      public function HitEvil(me:FlxObject, you:BaseMonster) : void
      {
         you.hurt(10);
         this.hurt(1);
      }
      
      override public function update() : void
      {
         super.update();
         if(frozen > 0)
         {
            angle += FlxG.elapsed * 360;
            return;
         }
         angle = Global.AngleBetween(0,0,velocity.x,velocity.y);
         if(reflected)
         {
            FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.HitEvil);
         }
         else if(Global.pedro.Vulnerable())
         {
            FlxG.overlap(this,Global.pedro,this.Hit);
         }
         if(isTouching(ANY))
         {
            this.hurt(1);
         }
         this.fireTime -= FlxG.elapsed;
         if(this.fireTime <= 0)
         {
            Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + width / 2,y + height / 2,Global.randRange(0,360),0);
            this.fireTime += 0.05;
         }
      }
   }
}

