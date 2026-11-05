package xplor.Bullet
{
   public class PedroFlame extends BaseBullet
   {
      
      public static var SmokeImage:Class = PedroFlame_SmokeImage;
      
      public function PedroFlame()
      {
         super();
         loadGraphic(SmokeImage,true,true,20,36,true);
         addAnimation("burn",[0,1,2,3,4,5,6,7,8,9,10,11,12],30,false);
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1 - 0.6 * int(dmg > 0);
         if(a == 0)
         {
            facing = RIGHT;
         }
         else
         {
            facing = LEFT;
         }
         if(dmg > 0)
         {
            facing = LEFT + RIGHT - facing;
         }
         velocity.x = 30 - 60 * int(a > 0);
         velocity.y = 0;
         acceleration.y = -50;
         play("burn");
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

