package xplor.Monster
{
   import xplor.Global;
   
   public class BlimpChunk extends BaseGuy
   {
      
      public static var FireImage:Class = BlimpChunk_FireImage;
      
      public function BlimpChunk(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(FireImage,true,false,93,77,true);
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         this.x = tx * Global.TILE_WIDTH + 8;
         this.y = ty * Global.TILE_HEIGHT + 16 - 75;
      }
   }
}

