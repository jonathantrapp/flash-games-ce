package xplor.TileSets
{
   import org.flixel.FlxTilemapExt;
   import xplor.*;
   
   public class TileSet_Grave extends TileSet
   {
      
      public static var TileImage:Class = TileSet_Grave_TileImage;
      
      public static var TileImage2:Class = TileSet_Grave_TileImage2;
      
      public static var TileImage3:Class = TileSet_Grave_TileImage3;
      
      public static var TileImage4:Class = TileSet_Grave_TileImage4;
      
      public function TileSet_Grave()
      {
         var _loc1_:TileDef = null;
         super();
         _loc1_ = new TileDef(Level.LAYER_SOLID,1,4);
         _loc1_.Set(TileDef.TOP,15,2);
         _loc1_.Set(TileDef.BOTTOM,20,2);
         _loc1_.Set(TileDef.TOPLEFT,13,2);
         _loc1_.Set(TileDef.TOPRIGHT,17,2);
         properties[14] = FlxTilemapExt.SLOPE_FLOOR_LEFT;
         properties[18] = FlxTilemapExt.SLOPE_FLOOR_RIGHT;
         _loc1_.Set(TileDef.LEFT,23,2);
         _loc1_.Set(TileDef.RIGHT,25,2);
         _loc1_.Set(TileDef.BOTTOMLEFT,19,1);
         _loc1_.Set(TileDef.BOTTOMRIGHT,22,1);
         _loc1_.Set(TileDef.TOPANDBOTTOM,6,2);
         _loc1_.Set(TileDef.TOPBOTTOMLEFT,5,1);
         _loc1_.Set(TileDef.TOPBOTTOMRIGHT,8,1);
         _loc1_.Set(TileDef.LEFTRIGHTTOP,10,1);
         _loc1_.Set(TileDef.LEFTRIGHTBOTTOM,11,1);
         _loc1_.Set(TileDef.LEFTANDRIGHT,12,1);
         _loc1_.Set(TileDef.SOLO,9,1);
         _loc1_.Set(TileDef.EXTRA,33,1);
         tools.push(_loc1_);
         _loc1_ = new TileDef(Level.LAYER_BACK,46,2);
         _loc1_.Set(TileDef.TOPLEFT,34,1);
         _loc1_.Set(TileDef.TOP,35,2);
         _loc1_.Set(TileDef.TOPRIGHT,37,1);
         _loc1_.Set(TileDef.LEFT,38,2);
         _loc1_.Set(TileDef.RIGHT,40,2);
         _loc1_.Set(TileDef.BOTTOMLEFT,42,1);
         _loc1_.Set(TileDef.BOTTOM,43,2);
         _loc1_.Set(TileDef.BOTTOMRIGHT,45,1);
         _loc1_.Set(TileDef.TOPBOTTOMLEFT,48,1);
         _loc1_.Set(TileDef.TOPANDBOTTOM,49,1);
         _loc1_.Set(TileDef.TOPBOTTOMRIGHT,50,1);
         _loc1_.Set(TileDef.LEFTRIGHTTOP,51,1);
         _loc1_.Set(TileDef.LEFTANDRIGHT,52,1);
         _loc1_.Set(TileDef.LEFTRIGHTBOTTOM,53,1);
         _loc1_.Set(TileDef.SOLO,54,1);
         tools.push(_loc1_);
         _loc1_ = new TileDef(Level.LAYER_BACK,28,3);
         tools.push(_loc1_);
         _loc1_ = new TileDef(Level.LAYER_BACK,31,2);
         tools.push(_loc1_);
         _loc1_ = new TileDef(Level.LAYER_BACK,55,1);
         tools.push(_loc1_);
         var _loc2_:int = 1;
         while(_loc2_ <= 12)
         {
            _loc1_ = new TileDef(Level.LAYER_GOODIE,_loc2_,1);
            tools.push(_loc1_);
            _loc2_++;
         }
      }
      
      override public function Image() : Class
      {
         if(Global.levelNum == 16)
         {
            return TileImage3;
         }
         if(Global.levelNum > 11)
         {
            return TileImage4;
         }
         if(Global.levelNum > 7)
         {
            return TileImage3;
         }
         if(Global.levelNum > 3)
         {
            return TileImage2;
         }
         return TileImage;
      }
   }
}

