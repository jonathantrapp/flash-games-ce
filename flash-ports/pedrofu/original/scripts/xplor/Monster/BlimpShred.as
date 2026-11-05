package xplor.Monster
{
   import xplor.Global;
   
   public class BlimpShred extends BaseGuy
   {
      
      public static var FireImage:Class = BlimpShred_FireImage;
      
      public function BlimpShred(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(FireImage,true,false,28,42,true);
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         this.x = tx * Global.TILE_WIDTH;
         this.y = ty * Global.TILE_HEIGHT - 3;
      }
   }
}

