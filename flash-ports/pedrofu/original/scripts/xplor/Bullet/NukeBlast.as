package xplor.Bullet
{
   import org.flixel.FlxG;
   import xplor.Global;
   
   public class NukeBlast extends BaseBullet
   {
      
      public static var BoomImage:Class = NukeBlast_BoomImage;
      
      public function NukeBlast()
      {
         super();
         loadGraphic(BoomImage,true,true,157,157,true);
         blend = "add";
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
         velocity.x = 0;
         velocity.y = 0;
         angle = Global.randRange(0,360);
         angularVelocity = 1280;
      }
      
      override public function update() : void
      {
         scale.x += FlxG.elapsed * 5;
         scale.y = scale.x;
         alpha -= FlxG.elapsed;
         if(alpha <= 0)
         {
            exists = false;
         }
      }
   }
}

