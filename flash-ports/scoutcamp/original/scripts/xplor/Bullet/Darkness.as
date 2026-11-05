package xplor.Bullet
{
   import org.flixel.FlxG;
   import xplor.Global;
   
   public class Darkness extends BaseBullet
   {
      
      public static var BoomImage:Class = Darkness_BoomImage;
      
      public function Darkness()
      {
         super();
         loadGraphic(BoomImage,true,false,32,32,true);
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         angle = Global.randRange(0,360);
         angularVelocity = Global.randRange(200,720);
         scale.x = 0.1;
         scale.y = 0.1;
         velocity.x = Global.Cosine(param3) * 10;
         velocity.y = Global.Sine(param3) * 10;
      }
      
      override public function update() : void
      {
         alpha -= FlxG.elapsed;
         scale.x += FlxG.elapsed;
         scale.y = scale.x;
         if(alpha <= 0)
         {
            exists = false;
         }
      }
   }
}

