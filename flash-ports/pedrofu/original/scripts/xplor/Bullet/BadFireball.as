package xplor.Bullet
{
   import org.flixel.FlxG;
   import org.flixel.FlxObject;
   import xplor.Bullets;
   import xplor.Global;
   
   public class BadFireball extends BaseBullet
   {
      
      public var fireTime:Number;
      
      public var life:Number;
      
      public function BadFireball()
      {
         super();
         loadGraphic(Fireball.ArrowImage,true,false,13,7,true);
         width = 7;
         offset.x = 3;
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         reflected = false;
         frozen = 0;
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = true;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         angle = a;
         velocity.x = Global.Cosine(a) * 60;
         velocity.y = Global.Sine(a) * 60;
         acceleration.x = 0;
         acceleration.y = 0;
         this.fireTime = 0;
         target = null;
         this.life = 6;
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
         this.hurt(1);
      }
      
      override public function update() : void
      {
         super.update();
         if(reflected)
         {
            this.hurt(1);
            return;
         }
         this.life -= FlxG.elapsed;
         if(this.life <= 0)
         {
            this.hurt(1);
         }
         if(Global.pedro.Vulnerable())
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
            this.fireTime += 0.1;
         }
         velocity.x = Global.Cosine(angle) * 60;
         velocity.y = Global.Sine(angle) * 60;
         angle = Global.TurnToward(angle,Global.AngleBetweenGuys(this,Global.pedro),FlxG.elapsed * 100);
      }
   }
}

