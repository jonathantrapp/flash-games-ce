package xplor.Monster
{
   import xplor.Global;
   
   public class BlimpEngine extends BaseGuy
   {
      
      public static var FireImage:Class = BlimpEngine_FireImage;
      
      public function BlimpEngine(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(FireImage,true,false,49,50,true);
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         this.x = tx * Global.TILE_WIDTH - 17;
         this.y = ty * Global.TILE_HEIGHT - 40;
      }
   }
}

