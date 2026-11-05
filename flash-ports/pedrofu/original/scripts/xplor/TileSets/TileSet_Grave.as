package xplor.TileSets
{
   import org.flixel.*;
   import xplor.*;
   
   public class TileSet_Grave extends TileSet
   {
      
      public static var TileImage:Class = TileSet_Grave_TileImage;
      
      public function TileSet_Grave()
      {
         var dirtDef:TileDef = null;
         super();
         this.DirtMaker(0,60,38);
         this.DirtMaker(72,1,26);
         dirtDef = new TileDef(Level.LAYER_DECOR,99,4);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_BACK,46,2);
         dirtDef.Set(TileDef.TOPLEFT,34,1);
         dirtDef.Set(TileDef.TOP,35,2);
         dirtDef.Set(TileDef.TOPRIGHT,37,1);
         dirtDef.Set(TileDef.LEFT,38,2);
         dirtDef.Set(TileDef.RIGHT,40,2);
         dirtDef.Set(TileDef.BOTTOMLEFT,42,1);
         dirtDef.Set(TileDef.BOTTOM,43,2);
         dirtDef.Set(TileDef.BOTTOMRIGHT,45,1);
         dirtDef.Set(TileDef.TOPBOTTOMLEFT,48,1);
         dirtDef.Set(TileDef.TOPANDBOTTOM,49,1);
         dirtDef.Set(TileDef.TOPBOTTOMRIGHT,50,1);
         dirtDef.Set(TileDef.LEFTRIGHTTOP,51,1);
         dirtDef.Set(TileDef.LEFTANDRIGHT,52,1);
         dirtDef.Set(TileDef.LEFTRIGHTBOTTOM,53,1);
         dirtDef.Set(TileDef.SOLO,54,1);
         dirtDef.Set(TileDef.EXTRA,141,20);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_SOLID,117,3);
         dirtDef.Set(TileDef.SOLO,103,1);
         dirtDef.Set(TileDef.LEFTRIGHTTOP,104,1);
         dirtDef.Set(TileDef.LEFTRIGHTBOTTOM,105,1);
         dirtDef.Set(TileDef.LEFTANDRIGHT,106,1);
         dirtDef.Set(TileDef.TOPLEFT,107,1);
         dirtDef.Set(TileDef.TOP,108,2);
         dirtDef.Set(TileDef.TOPRIGHT,110,1);
         dirtDef.Set(TileDef.LEFT,111,1);
         dirtDef.Set(TileDef.RIGHT,112,1);
         dirtDef.Set(TileDef.BOTTOMLEFT,113,1);
         dirtDef.Set(TileDef.BOTTOM,114,2);
         dirtDef.Set(TileDef.BOTTOMRIGHT,116,1);
         dirtDef.Set(TileDef.TOPANDBOTTOM,138,2);
         dirtDef.Set(TileDef.TOPBOTTOMLEFT,137,1);
         dirtDef.Set(TileDef.TOPBOTTOMRIGHT,140,1);
         dirtDef.Set(TileDef.EXTRA,73,25);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_BACK,155,3);
         dirtDef.Set(TileDef.SOLO,141,1);
         dirtDef.Set(TileDef.LEFTRIGHTTOP,142,1);
         dirtDef.Set(TileDef.LEFTRIGHTBOTTOM,143,1);
         dirtDef.Set(TileDef.LEFTANDRIGHT,144,1);
         dirtDef.Set(TileDef.TOPLEFT,145,1);
         dirtDef.Set(TileDef.TOP,146,2);
         dirtDef.Set(TileDef.TOPRIGHT,148,1);
         dirtDef.Set(TileDef.LEFT,149,1);
         dirtDef.Set(TileDef.RIGHT,150,1);
         dirtDef.Set(TileDef.BOTTOMLEFT,151,1);
         dirtDef.Set(TileDef.BOTTOM,152,2);
         dirtDef.Set(TileDef.BOTTOMRIGHT,154,1);
         dirtDef.Set(TileDef.TOPANDBOTTOM,159,2);
         dirtDef.Set(TileDef.TOPBOTTOMLEFT,158,1);
         dirtDef.Set(TileDef.TOPBOTTOMRIGHT,161,1);
         dirtDef.Set(TileDef.EXTRA,34,20);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_SOLID,55,1);
         properties[55] = FlxObject.CEILING;
         tools.push(dirtDef);
         for(var i:int = 1; i <= 19; i++)
         {
            dirtDef = new TileDef(Level.LAYER_GOODIE,i,1);
            tools.push(dirtDef);
         }
         for(i = 36; i <= 47; i++)
         {
            dirtDef = new TileDef(Level.LAYER_GOODIE,i,1);
            tools.push(dirtDef);
         }
         dirtDef = new TileDef(Level.LAYER_GOODIE,20,6);
         tools.push(dirtDef);
         for(i = 26; i <= 35; i++)
         {
            dirtDef = new TileDef(Level.LAYER_GOODIE,i,1);
            tools.push(dirtDef);
         }
         for(i = 56; i <= 58; i++)
         {
            dirtDef = new TileDef(Level.LAYER_SOLID,i,1);
            tools.push(dirtDef);
         }
         dirtDef = new TileDef(Level.LAYER_SOLID,60,1);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_BACK,61,1);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_BACK,67,3);
         tools.push(dirtDef);
         for(i = 62; i <= 66; i++)
         {
            properties[i] = FlxObject.CEILING;
            dirtDef = new TileDef(Level.LAYER_SOLID,i,1);
            tools.push(dirtDef);
         }
         dirtDef = new TileDef(Level.LAYER_SOLID,70,3);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_SOLID,120,1);
         dirtDef.SetAll(TileDef.ALL_LEFTS,121,1);
         dirtDef.SetAll(TileDef.ALL_RIGHTS,122,1);
         properties[121] = FlxTilemapExt.SLOPE_FLOOR_LEFT;
         properties[122] = FlxTilemapExt.SLOPE_FLOOR_RIGHT;
         dirtDef.Set(TileDef.BOTTOMLEFT,123,1);
         dirtDef.Set(TileDef.TOPBOTTOMLEFT,123,1);
         dirtDef.Set(TileDef.BOTTOM,124,1);
         dirtDef.Set(TileDef.TOPANDBOTTOM,124,1);
         dirtDef.Set(TileDef.BOTTOMRIGHT,125,1);
         dirtDef.Set(TileDef.TOPBOTTOMRIGHT,125,1);
         properties[123] = FlxTilemapExt.SLOPE_FLOOR_LEFT;
         properties[125] = FlxTilemapExt.SLOPE_FLOOR_RIGHT;
         tools.push(dirtDef);
         for(i = 126; i < 126 + 8; i++)
         {
            dirtDef = new TileDef(Level.LAYER_DECOR,i,1);
            tools.push(dirtDef);
         }
         dirtDef = new TileDef(Level.LAYER_BACK,136,1);
         dirtDef.SetAll(TileDef.ALL_TOPS,134,1);
         dirtDef.SetAll(TileDef.ALL_BOTTOMS,135,1);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_BACK,162,1);
         tools.push(dirtDef);
         for(i = 163; i <= 169; i++)
         {
            dirtDef = new TileDef(Level.LAYER_BACK,i,1);
            tools.push(dirtDef);
         }
         dirtDef = new TileDef(Level.LAYER_BACK,203,1);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_BACK,204,1);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_SOLID,170,1);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_SOLID,171,1);
         tools.push(dirtDef);
         properties[170] = FlxTilemapExt.SLOPE_FLOOR_RIGHT;
         properties[171] = FlxTilemapExt.SLOPE_FLOOR_LEFT;
         dirtDef = new TileDef(Level.LAYER_SOLID,176,1);
         dirtDef.Set(TileDef.TOPLEFT,172,1);
         dirtDef.Set(TileDef.TOP,173,1);
         dirtDef.Set(TileDef.TOPRIGHT,174,1);
         dirtDef.Set(TileDef.LEFT,175,1);
         dirtDef.Set(TileDef.RIGHT,177,1);
         dirtDef.Set(TileDef.BOTTOMLEFT,178,1);
         dirtDef.Set(TileDef.BOTTOM,179,1);
         dirtDef.Set(TileDef.BOTTOMRIGHT,180,1);
         dirtDef.Set(TileDef.TOPBOTTOMLEFT,181,1);
         dirtDef.Set(TileDef.TOPANDBOTTOM,182,1);
         dirtDef.Set(TileDef.TOPBOTTOMRIGHT,183,1);
         dirtDef.Set(TileDef.LEFTRIGHTTOP,184,1);
         dirtDef.Set(TileDef.LEFTANDRIGHT,185,1);
         dirtDef.Set(TileDef.LEFTRIGHTBOTTOM,186,1);
         dirtDef.Set(TileDef.INSIDEALL,187,1);
         dirtDef.Set(TileDef.INSIDETOPLEFT,188,1);
         dirtDef.Set(TileDef.INSIDEBOTTOMLEFT,189,1);
         dirtDef.Set(TileDef.INSIDEBOTTOMRIGHT,190,1);
         dirtDef.Set(TileDef.INSIDETOPRIGHT,191,1);
         dirtDef.Set(TileDef.INSIDETOPBOTH,192,1);
         dirtDef.Set(TileDef.INSIDETOPLEFT_BOTTOMRIGHT,193,1);
         dirtDef.Set(TileDef.INSIDELEFTBOTH,194,1);
         dirtDef.Set(TileDef.INSIDERIGHTBOTH,195,1);
         dirtDef.Set(TileDef.INSIDETOPRIGHT_BOTTOMLEFT,196,1);
         dirtDef.Set(TileDef.INSIDEBOTTOMBOTH,197,1);
         dirtDef.Set(TileDef.INSIDEALLBUT_TOPRIGHT,198,1);
         dirtDef.Set(TileDef.INSIDEALLBUT_BOTTOMRIGHT,199,1);
         dirtDef.Set(TileDef.INSIDEALLBUT_TOPLEFT,200,1);
         dirtDef.Set(TileDef.INSIDEALLBUT_BOTTOMLEFT,201,1);
         dirtDef.Set(TileDef.SOLO,202,1);
         tools.push(dirtDef);
         dirtDef = new TileDef(Level.LAYER_DECOR,120,1);
         tools.push(dirtDef);
      }
      
      public function DirtMaker(base:int, extra:int, extrasize:int) : void
      {
         var dirtDef:TileDef = null;
         dirtDef = new TileDef(Level.LAYER_SOLID,base + 1,4);
         dirtDef.Set(TileDef.TOP,base + 15,2);
         dirtDef.Set(TileDef.BOTTOM,base + 20,2);
         dirtDef.Set(TileDef.TOPLEFT,base + 13,2);
         dirtDef.Set(TileDef.TOPRIGHT,base + 17,2);
         properties[base + 14] = FlxTilemapExt.SLOPE_FLOOR_LEFT;
         properties[base + 18] = FlxTilemapExt.SLOPE_FLOOR_RIGHT;
         dirtDef.Set(TileDef.LEFT,base + 23,2);
         dirtDef.Set(TileDef.RIGHT,base + 25,2);
         dirtDef.Set(TileDef.BOTTOMLEFT,base + 19,1);
         dirtDef.Set(TileDef.BOTTOMRIGHT,base + 22,1);
         dirtDef.Set(TileDef.TOPANDBOTTOM,base + 6,2);
         dirtDef.Set(TileDef.TOPBOTTOMLEFT,base + 5,1);
         dirtDef.Set(TileDef.TOPBOTTOMRIGHT,base + 8,1);
         dirtDef.Set(TileDef.LEFTRIGHTTOP,base + 10,1);
         dirtDef.Set(TileDef.LEFTRIGHTBOTTOM,base + 11,1);
         dirtDef.Set(TileDef.LEFTANDRIGHT,base + 12,1);
         dirtDef.Set(TileDef.SOLO,base + 9,1);
         if(extra != 0)
         {
            dirtDef.Set(TileDef.EXTRA,extra,extrasize);
         }
         tools.push(dirtDef);
      }
      
      override public function Image() : Class
      {
         return TileImage;
      }
   }
}

