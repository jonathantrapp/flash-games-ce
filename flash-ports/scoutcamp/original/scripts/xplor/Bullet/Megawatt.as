package xplor.Bullet
{
   import org.flixel.FlxG;
   
   public class Megawatt extends BaseBullet
   {
      
      public static var BoomImage:Class = Megawatt_BoomImage;
      
      public function Megawatt()
      {
         super();
         loadGraphic(BoomImage,false,false,40,40,true);
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         scale.x = 0.1;
         scale.y = 0.1;
         play("boom");
      }
      
      override public function update() : void
      {
         scale.x += FlxG.elapsed * 5;
         scale.y = scale.x;
         alpha -= FlxG.elapsed * 2;
         if(alpha <= 0)
         {
            exists = false;
         }
      }
   }
}

