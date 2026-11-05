package xplor.Bullet
{
   import xplor.Global;
   import xplor.Sounds;
   
   public class Boom extends BaseBullet
   {
      
      public static var BoomImage:Class = Boom_BoomImage;
      
      public var big:Boolean;
      
      public function Boom()
      {
         super();
         loadGraphic(BoomImage,true,false,32,32,true);
         addAnimation("boom",[0,1,2,3,4,5,6,7,8,9,10,11,12,13],20,false);
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.x = x - width / 2;
         this.y = y - height / 2;
         Sounds.play(Sounds.BoomSnd);
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         if(a == 1)
         {
            this.big = true;
            scale.x = 1.5;
            scale.y = 1.5;
         }
         else
         {
            this.big = false;
         }
         play("boom");
      }
      
      override public function update() : void
      {
         if(this.big)
         {
            scale.x = Global.randRange(0.5,2);
            scale.y = Global.randRange(0.5,2);
         }
         if(finished)
         {
            exists = false;
         }
      }
   }
}

