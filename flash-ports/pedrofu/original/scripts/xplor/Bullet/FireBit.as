package xplor.Bullet
{
   import org.flixel.FlxG;
   import xplor.Global;
   
   public class FireBit extends BaseBullet
   {
      
      public static var SmokeImage:Class = FireBit_SmokeImage;
      
      public var crazy:Boolean;
      
      public function FireBit()
      {
         super();
         loadGraphic(SmokeImage,true,false,6,6,true);
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
         velocity.x = 0;
         velocity.y = 0;
         if(a != -1)
         {
            velocity.x = Global.Cosine(a) * 20;
            velocity.y = Global.Sine(a) * 20;
         }
         acceleration.y = 150;
         angle = 0;
         if(dmg == 1)
         {
            scale.x = Global.randRange(1,3);
            scale.y = scale.x;
            velocity.x = Global.Cosine(a) * 80;
            velocity.y = Global.Sine(a) * 80;
            this.crazy = true;
         }
         else
         {
            scale.x = 1;
            scale.y = scale.x;
            this.crazy = false;
         }
      }
      
      override public function update() : void
      {
         alpha -= FlxG.elapsed;
         if(this.crazy)
         {
            scale.x -= FlxG.elapsed * 4;
            scale.y = scale.x;
         }
         else
         {
            scale.x -= FlxG.elapsed * 2;
            scale.y = scale.x;
         }
         if(scale.x <= 0)
         {
            exists = false;
         }
      }
   }
}

