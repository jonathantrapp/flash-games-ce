package xplor.Bullet
{
   public class GaleWind extends BaseBullet
   {
      
      public static var BoomImage:Class = GaleWind_BoomImage;
      
      public function GaleWind()
      {
         super();
         loadGraphic(BoomImage,true,true,16,16,true);
         addAnimation("blow",[0,1,2,3,4,5,6,7,8,9],20,false);
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
            velocity.x = 10 * a;
         }
         else
         {
            facing = RIGHT;
            velocity.x = 10 * a;
         }
         scale.x = Math.abs(a);
         scale.y = 1;
         velocity.y = 0;
         play("blow",true);
      }
      
      override public function update() : void
      {
         if(finished)
         {
            exists = false;
         }
      }
   }
}

