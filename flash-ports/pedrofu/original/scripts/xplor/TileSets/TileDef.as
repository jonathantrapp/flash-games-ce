package xplor.TileSets
{
   import org.flixel.FlxTilemap;
   import xplor.Global;
   
   public class TileDef
   {
      
      public static const MIDDLE:uint = 0;
      
      public static const TOP:uint = 1;
      
      public static const BOTTOM:uint = 2;
      
      public static const LEFT:uint = 3;
      
      public static const RIGHT:uint = 4;
      
      public static const TOPLEFT:uint = 5;
      
      public static const TOPRIGHT:uint = 6;
      
      public static const BOTTOMLEFT:uint = 7;
      
      public static const BOTTOMRIGHT:uint = 8;
      
      public static const LEFTANDRIGHT:uint = 9;
      
      public static const LEFTRIGHTTOP:uint = 10;
      
      public static const LEFTRIGHTBOTTOM:uint = 11;
      
      public static const SOLO:uint = 12;
      
      public static const INSIDETOPLEFT:uint = 13;
      
      public static const INSIDETOPRIGHT:uint = 14;
      
      public static const INSIDEBOTTOMLEFT:uint = 15;
      
      public static const INSIDEBOTTOMRIGHT:uint = 16;
      
      public static const INSIDETOPBOTH:uint = 17;
      
      public static const INSIDEBOTTOMBOTH:uint = 18;
      
      public static const INSIDELEFTBOTH:uint = 19;
      
      public static const INSIDERIGHTBOTH:uint = 20;
      
      public static const INSIDETOPLEFT_BOTTOMRIGHT:uint = 21;
      
      public static const INSIDETOPRIGHT_BOTTOMLEFT:uint = 22;
      
      public static const INSIDEALLBUT_TOPLEFT:uint = 23;
      
      public static const INSIDEALLBUT_TOPRIGHT:uint = 24;
      
      public static const INSIDEALLBUT_BOTTOMLEFT:uint = 25;
      
      public static const INSIDEALLBUT_BOTTOMRIGHT:uint = 26;
      
      public static const INSIDEALL:uint = 27;
      
      public static const TOPANDBOTTOM:uint = 28;
      
      public static const TOPBOTTOMLEFT:uint = 29;
      
      public static const TOPBOTTOMRIGHT:uint = 30;
      
      public static const EXTRA:uint = 31;
      
      public static const TOTAL_DEFS:uint = 32;
      
      public static const ALL_LEFTS:uint = 0;
      
      public static const ALL_RIGHTS:uint = 1;
      
      public static const ALL_TOPS:uint = 2;
      
      public static const ALL_BOTTOMS:uint = 3;
      
      public var tiles:Array;
      
      public var layer:uint;
      
      public var connectsToAny:Boolean;
      
      public function TileDef(layer:uint, defaultTile:int, defaultVars:int)
      {
         var i:int = 0;
         super();
         this.layer = layer;
         this.tiles = new Array();
         for(i = 0; i < TOTAL_DEFS; i++)
         {
            this.tiles[i * 2] = defaultTile;
            this.tiles[i * 2 + 1] = defaultVars;
         }
         this.connectsToAny = false;
      }
      
      public function Set(def:uint, tile:int, vars:int) : void
      {
         this.tiles[def * 2] = tile;
         this.tiles[def * 2 + 1] = vars;
      }
      
      public function SetAll(allType:uint, tile:int, vars:int) : void
      {
         var i:int = 0;
         var leftArray:Array = new Array(LEFT,TOPLEFT,BOTTOMLEFT,TOPBOTTOMLEFT);
         var rightArray:Array = new Array(RIGHT,TOPRIGHT,BOTTOMRIGHT,TOPBOTTOMRIGHT);
         var topArray:Array = new Array(TOP,TOPLEFT,TOPRIGHT,TOPBOTTOMLEFT,TOPBOTTOMRIGHT,TOPANDBOTTOM,LEFTRIGHTTOP);
         var bottomArray:Array = new Array(BOTTOM,BOTTOMLEFT,BOTTOMRIGHT,TOPBOTTOMLEFT,TOPBOTTOMRIGHT,TOPANDBOTTOM,LEFTRIGHTBOTTOM);
         switch(allType)
         {
            case ALL_TOPS:
               for each(i in topArray)
               {
                  this.Set(i,tile,vars);
               }
               break;
            case ALL_BOTTOMS:
               for each(i in bottomArray)
               {
                  this.Set(i,tile,vars);
               }
               break;
            case ALL_LEFTS:
               for each(i in leftArray)
               {
                  this.Set(i,tile,vars);
               }
               break;
            case ALL_RIGHTS:
               for each(i in rightArray)
               {
                  this.Set(i,tile,vars);
               }
         }
      }
      
      public function IsThis(x:int, y:int, anyOK:Boolean = false, notExtra:Boolean = false) : Boolean
      {
         if(x < 0 || y < 0 || x >= Global.level.width || y >= Global.level.height)
         {
            return true;
         }
         return this.IsThis2((Global.level.layers[this.layer] as FlxTilemap).getTile(x,y),anyOK,notExtra);
      }
      
      public function IsThis2(a:int, anyOK:Boolean = false, notExtra:Boolean = false) : Boolean
      {
         var i:int = 0;
         if(anyOK && this.connectsToAny && a != 0)
         {
            return true;
         }
         if(notExtra && a >= this.tiles[EXTRA * 2] && a < this.tiles[EXTRA * 2] + this.tiles[EXTRA * 2 + 1])
         {
            return false;
         }
         for(i = 0; i < TOTAL_DEFS; i++)
         {
            if(a >= this.tiles[i * 2] && a < this.tiles[i * 2] + this.tiles[i * 2 + 1])
            {
               return true;
            }
         }
         return false;
      }
      
      public function GetIt(kind:int) : int
      {
         return this.tiles[kind * 2] + int(Global.randRange(0,this.tiles[kind * 2 + 1]));
      }
      
      public function ChooseTile(x:int, y:int) : int
      {
         var t:int = 0;
         var n:Array = new Array();
         n[0] = this.IsThis(x + 1,y,true);
         n[1] = this.IsThis(x + 1,y + 1,true);
         n[2] = this.IsThis(x,y + 1,true);
         n[3] = this.IsThis(x - 1,y + 1,true);
         n[4] = this.IsThis(x - 1,y,true);
         n[5] = this.IsThis(x - 1,y - 1,true);
         n[6] = this.IsThis(x,y - 1,true);
         n[7] = this.IsThis(x + 1,y - 1,true);
         if(Boolean(n[0]) && Boolean(n[2]) && Boolean(n[4]) && Boolean(n[6]))
         {
            if(Boolean(n[1]) && Boolean(n[3]) && Boolean(n[5]) && Boolean(n[7]))
            {
               return this.GetIt(MIDDLE);
            }
            if(Boolean(n[1]) && Boolean(n[3]) && Boolean(n[5]))
            {
               return this.GetIt(INSIDETOPRIGHT);
            }
            if(Boolean(n[1]) && Boolean(n[3]) && Boolean(n[7]))
            {
               return this.GetIt(INSIDETOPLEFT);
            }
            if(Boolean(n[1]) && Boolean(n[5]) && Boolean(n[7]))
            {
               return this.GetIt(INSIDEBOTTOMLEFT);
            }
            if(Boolean(n[3]) && Boolean(n[5]) && Boolean(n[7]))
            {
               return this.GetIt(INSIDEBOTTOMRIGHT);
            }
            if(Boolean(n[1]) && Boolean(n[3]))
            {
               return this.GetIt(INSIDETOPBOTH);
            }
            if(Boolean(n[3]) && Boolean(n[5]))
            {
               return this.GetIt(INSIDERIGHTBOTH);
            }
            if(Boolean(n[5]) && Boolean(n[7]))
            {
               return this.GetIt(INSIDEBOTTOMBOTH);
            }
            if(Boolean(n[1]) && Boolean(n[7]))
            {
               return this.GetIt(INSIDELEFTBOTH);
            }
            if(Boolean(n[1]) && Boolean(n[5]))
            {
               return this.GetIt(INSIDETOPRIGHT_BOTTOMLEFT);
            }
            if(Boolean(n[3]) && Boolean(n[7]))
            {
               return this.GetIt(INSIDETOPLEFT_BOTTOMRIGHT);
            }
            if(Boolean(n[1]))
            {
               return this.GetIt(INSIDEALLBUT_BOTTOMRIGHT);
            }
            if(Boolean(n[3]))
            {
               return this.GetIt(INSIDEALLBUT_BOTTOMLEFT);
            }
            if(Boolean(n[5]))
            {
               return this.GetIt(INSIDEALLBUT_TOPLEFT);
            }
            if(Boolean(n[7]))
            {
               return this.GetIt(INSIDEALLBUT_TOPRIGHT);
            }
            return this.GetIt(INSIDEALL);
         }
         if(Boolean(n[0]) && Boolean(n[2]) && Boolean(n[4]))
         {
            return this.GetIt(TOP);
         }
         if(Boolean(n[0]) && Boolean(n[4]) && Boolean(n[6]))
         {
            return this.GetIt(BOTTOM);
         }
         if(Boolean(n[0]) && Boolean(n[2]) && Boolean(n[6]))
         {
            return this.GetIt(LEFT);
         }
         if(Boolean(n[2]) && Boolean(n[4]) && Boolean(n[6]))
         {
            return this.GetIt(RIGHT);
         }
         if(Boolean(n[0]) && Boolean(n[2]))
         {
            return this.GetIt(TOPLEFT);
         }
         if(Boolean(n[0]) && Boolean(n[4]))
         {
            return this.GetIt(TOPANDBOTTOM);
         }
         if(Boolean(n[0]) && Boolean(n[6]))
         {
            return this.GetIt(BOTTOMLEFT);
         }
         if(Boolean(n[2]) && Boolean(n[4]))
         {
            return this.GetIt(TOPRIGHT);
         }
         if(Boolean(n[2]) && Boolean(n[6]))
         {
            return this.GetIt(LEFTANDRIGHT);
         }
         if(Boolean(n[4]) && Boolean(n[6]))
         {
            return this.GetIt(BOTTOMRIGHT);
         }
         if(Boolean(n[0]))
         {
            return this.GetIt(TOPBOTTOMLEFT);
         }
         if(Boolean(n[2]))
         {
            return this.GetIt(LEFTRIGHTTOP);
         }
         if(Boolean(n[4]))
         {
            return this.GetIt(TOPBOTTOMRIGHT);
         }
         if(Boolean(n[6]))
         {
            return this.GetIt(LEFTRIGHTBOTTOM);
         }
         return this.GetIt(SOLO);
      }
   }
}

