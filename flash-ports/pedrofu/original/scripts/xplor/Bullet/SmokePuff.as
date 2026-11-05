package xplor.Bullet
{
   import xplor.Global;
   
   public class SmokePuff extends BaseBullet
   {
      
      public static var SmokeImage:Class = SmokePuff_SmokeImage;
      
      public function SmokePuff()
      {
         super();
         loadGraphic(SmokeImage,true,false,16,16,true);
         addAnimation("poof",[0,1,2,3,4,5,6],20,false);
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
         angle = Global.randRange(0,360);
         scale.x = 2;
         scale.y = scale.x;
         play("poof");
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

