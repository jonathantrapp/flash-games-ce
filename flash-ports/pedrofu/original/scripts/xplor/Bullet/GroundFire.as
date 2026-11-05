package xplor.Bullet
{
   import org.flixel.FlxG;
   import org.flixel.FlxObject;
   import xplor.Bullets;
   import xplor.Global;
   import xplor.Sounds;
   
   public class GroundFire extends BaseBullet
   {
      
      public static var ArrowImage:Class = GroundFire_ArrowImage;
      
      public var fireTime:Number;
      
      public var burnedYet:Boolean;
      
      public function GroundFire()
      {
         super();
         loadGraphic(ArrowImage,true,false,16,16,true);
         addAnimation("burn",[0,1,2,3,4,5,6,7,8,9],14,false);
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
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
         velocity.x = 0;
         velocity.y = 0;
         acceleration.y = 400;
         play("burn",true);
         this.burnedYet = false;
         if(onScreen())
         {
            Sounds.play(Sounds.BurnSnd);
         }
      }
      
      override public function hurt(n:Number) : void
      {
         exists = false;
         for(var i:int = 0; i < 8; i++)
         {
            Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + width / 2,y + height / 2,270,0);
         }
      }
      
      public function Hit(me:FlxObject, you:FlxObject) : void
      {
         Global.pedro.hurt(1);
         if(Global.pedro.reflect)
         {
            this.hurt(1);
            Global.pedro.reflect = false;
         }
      }
      
      override public function update() : void
      {
         super.update();
         if(frozen > 0 || finished)
         {
            exists = false;
            return;
         }
         if(_curFrame >= 1 && !this.burnedYet)
         {
            if(Global.pedro.Vulnerable())
            {
               this.burnedYet = true;
               FlxG.overlap(this,Global.pedro,this.Hit);
            }
         }
      }
   }
}

