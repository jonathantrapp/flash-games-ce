package xplor.Bullet
{
   import xplor.Global;
   
   public class HitSpark extends BaseBullet
   {
      
      public static var BoomImage:Class = HitSpark_BoomImage;
      
      public function HitSpark()
      {
         super();
         loadGraphic(BoomImage,true,false,25,30,true);
         addAnimation("blow",[0,1,2,3,4,5],20,false);
         addAnimation("crit",[0,1,0,2,1,3,2,4,3,5],30,false);
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         if(a == 0)
         {
            scale.x = 1;
            scale.y = 1;
            play("blow",true);
            angularVelocity = 0;
         }
         else
         {
            scale.x = 2;
            scale.y = 2;
            play("crit",true);
            angularVelocity = 360;
         }
         velocity.x = 0;
         velocity.y = 0;
         angle = Global.randRange(0,360);
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

