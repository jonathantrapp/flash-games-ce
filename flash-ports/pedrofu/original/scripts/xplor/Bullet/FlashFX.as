package xplor.Bullet
{
   import org.flixel.FlxG;
   
   public class FlashFX extends BaseBullet
   {
      
      public static var BoomImage:Class = FlashFX_BoomImage;
      
      public var big:Boolean;
      
      public function FlashFX()
      {
         super();
         loadGraphic(BoomImage,true,false,32,32,true);
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         scale.x = 0;
         scale.y = 0;
         frame = a;
         blend = "add";
         origin.y = 16;
         velocity.x = 0;
         velocity.y = 0;
         if(frame == 1)
         {
            scale.x = 1;
            origin.y = 32;
            velocity.y = -10;
            this.y -= 10;
         }
      }
      
      override public function update() : void
      {
         if(frame == 0)
         {
            scale.x += FlxG.elapsed * 6;
            scale.y += FlxG.elapsed * 6;
            alpha -= FlxG.elapsed;
            if(alpha <= 0)
            {
               exists = false;
            }
         }
         else if(frame == 1)
         {
            scale.x -= FlxG.elapsed;
            scale.y += FlxG.elapsed * 6;
            alpha -= FlxG.elapsed;
            if(alpha <= 0)
            {
               exists = false;
            }
         }
      }
   }
}

