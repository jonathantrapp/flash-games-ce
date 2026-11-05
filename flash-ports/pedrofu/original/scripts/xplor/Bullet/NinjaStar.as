package xplor.Bullet
{
   import org.flixel.FlxG;
   import org.flixel.FlxObject;
   import xplor.Badguys;
   import xplor.Bullets;
   import xplor.Global;
   import xplor.Level;
   import xplor.Monster.BaseMonster;
   
   public class NinjaStar extends BaseBullet
   {
      
      public static var ArrowImage:Class = NinjaStar_ArrowImage;
      
      public var aimAng:Number;
      
      public function NinjaStar()
      {
         super();
         loadGraphic(ArrowImage,true,false,5,5,true);
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         reflected = false;
         this.damage = dmg;
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         this.aimAng = a;
         angle = Global.randRange(0,360);
         velocity.x = Global.Cosine(a) * 100;
         velocity.y = Global.Sine(a) * 100;
         if(velocity.x > 0)
         {
            angularVelocity = 480;
         }
         else
         {
            angularVelocity = -480;
         }
         acceleration.y = 0;
         frozen = 0;
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
            velocity.x = -Global.Cosine(this.aimAng) * 140;
            velocity.y = -Global.Sine(this.aimAng) * 140;
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
         var tx:int = 0;
         var ty:int = 0;
         super.update();
         if(frozen > 0)
         {
            return;
         }
         solid = true;
         if(reflected)
         {
            FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.HitEvil);
         }
         else if(Global.pedro.Vulnerable())
         {
            FlxG.overlap(this,Global.pedro,this.Hit);
         }
         solid = false;
         tx = (x + width / 2) / 16;
         ty = (y + height / 2) / 16;
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx,ty)).allowCollisions == ANY)
         {
            this.hurt(1);
         }
      }
   }
}

