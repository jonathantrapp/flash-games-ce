package xplor.Bullet
{
   import org.flixel.FlxG;
   import xplor.Global;
   
   public class ArmorBit extends BaseBullet
   {
      
      public static var SmokeImage:Class = ArmorBit_SmokeImage;
      
      public function ArmorBit()
      {
         super();
         loadGraphic(SmokeImage,true,false,8,8,true);
         width = 2;
         height = 2;
         offset.x = 3;
         offset.y = 3;
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = true;
         alpha = 1;
         frame = Global.randRange(0,7);
         velocity.x = 0;
         velocity.y = 0;
         if(a != -1)
         {
            velocity.x = Global.Cosine(a) * 70;
            velocity.y = Global.Sine(a) * 70;
         }
         angularVelocity = Global.randRange(-720,720);
         acceleration.y = 150;
         angle = 0;
         scale.x = 1;
         scale.y = scale.x;
      }
      
      override public function update() : void
      {
         if(isTouching(WALL))
         {
            velocity.x = -velocity.x * 3 / 4;
            angularVelocity = Global.randRange(-720,720);
         }
         if(isTouching(CEILING | FLOOR))
         {
            velocity.y = -velocity.y * 3 / 4;
            angularVelocity = Global.randRange(-720,720);
         }
         scale.x -= FlxG.elapsed;
         scale.y = scale.x;
         if(scale.x <= 0)
         {
            exists = false;
         }
      }
   }
}

