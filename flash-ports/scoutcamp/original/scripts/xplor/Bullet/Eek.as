package xplor.Bullet
{
   import org.flixel.FlxG;
   
   public class Eek extends BaseBullet
   {
      
      public static var BoomImage:Class = Eek_BoomImage;
      
      public function Eek()
      {
         super();
         loadGraphic(BoomImage,true,false,18,6,true);
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         velocity.y = -30;
      }
      
      override public function update() : void
      {
         scale.x -= FlxG.elapsed * 2;
         scale.y = scale.x;
         if(scale.x <= 0.1)
         {
            exists = false;
         }
      }
   }
}

