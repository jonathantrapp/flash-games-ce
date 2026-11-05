package xplor.Monster
{
   import xplor.Global;
   
   public class Tree_Wall extends BaseGuy
   {
      
      public static var FireImage:Class = Tree_Wall_FireImage;
      
      public function Tree_Wall(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(FireImage,true,true,36,14,true);
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         this.x = tx * Global.TILE_WIDTH - 32;
         this.y = ty * Global.TILE_HEIGHT - 5;
      }
   }
}

