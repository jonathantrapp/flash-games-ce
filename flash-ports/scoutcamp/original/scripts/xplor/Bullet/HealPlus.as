package xplor.Bullet
{
   import org.flixel.FlxG;
   
   public class HealPlus extends BaseBullet
   {
      
      public static var BoomImage:Class = HealPlus_BoomImage;
      
      public function HealPlus()
      {
         super();
         loadGraphic(BoomImage,true,false,10,10,true);
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
         alpha -= FlxG.elapsed;
         scale.x -= FlxG.elapsed;
         scale.y = scale.x;
         if(alpha <= 0)
         {
            exists = false;
         }
      }
   }
}

