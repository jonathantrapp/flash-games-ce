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
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         velocity.x = 0;
         velocity.y = 0;
         if(param3 != -1)
         {
            velocity.x = Global.Cosine(param3) * 20;
            velocity.y = Global.Sine(param3) * 20;
         }
         angle = Global.randRange(0,360);
         scale.x = Global.randRange(0.5,1.25);
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

