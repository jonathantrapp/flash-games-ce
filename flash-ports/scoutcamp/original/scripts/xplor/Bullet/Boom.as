package xplor.Bullet
{
   import xplor.Sounds;
   
   public class Boom extends BaseBullet
   {
      
      public static var BoomImage:Class = Boom_BoomImage;
      
      public function Boom()
      {
         super();
         loadGraphic(BoomImage,true,false,32,32,true);
         addAnimation("boom",[0,1,2,3,4,5,6,7,8,9,10,11,12,13],20,false);
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         Sounds.play(Sounds.BoomSnd);
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         play("boom");
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

