package xplor.Monster
{
   public class Campfire extends BaseGuy
   {
      
      public static var FireImage:Class = Campfire_FireImage;
      
      public function Campfire(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(FireImage,true,false,13,11,true);
         addAnimation("idle",[0,1,2],10,true);
         height = 10;
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         super.Init(tx,ty);
         play("idle");
      }
   }
}

