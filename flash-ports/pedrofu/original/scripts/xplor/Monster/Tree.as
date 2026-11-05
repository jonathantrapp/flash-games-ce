package xplor.Monster
{
   import xplor.Global;
   
   public class Tree extends BaseGuy
   {
      
      public static var FireImage:Class = Tree_FireImage;
      
      public function Tree(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(FireImage,true,true,23,38,true);
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         this.x = tx * Global.TILE_WIDTH + 8 - 23 / 2;
         this.y = ty * Global.TILE_HEIGHT + 16 - 31;
      }
   }
}

