package xplor.Bullet
{
   import org.flixel.FlxG;
   
   public class PikeSlash extends BaseBullet
   {
      
      public static var BoomImage:Class = PikeSlash_BoomImage;
      
      public function PikeSlash()
      {
         super();
         loadGraphic(BoomImage,true,true,32,35,true);
         addAnimation("slice",[0,1,2,3],20,false);
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         if(a < 0)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         scale.x = 1;
         scale.y = 1;
         velocity.x = 100 - 200 * int(facing == LEFT);
         drag.x = 200;
         velocity.y = 0;
         play("slice",true);
      }
      
      override public function update() : void
      {
         alpha -= FlxG.elapsed * 4;
         if(finished)
         {
            exists = false;
         }
      }
      
      override public function Freeze(time:Number) : void
      {
      }
   }
}

