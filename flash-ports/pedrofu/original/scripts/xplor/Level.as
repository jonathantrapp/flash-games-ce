package xplor
{
   import org.flixel.*;
   import xplor.Bullet.FireBit;
   
   public class Level
   {
      
      public static var GoodieTilesImage:Class = Level_GoodieTilesImage;
      
      public static const LAYER_BACK:uint = 0;
      
      public static const LAYER_SOLID:uint = 1;
      
      public static const LAYER_DECOR:uint = 2;
      
      public static const LAYER_GOODIE:uint = 3;
      
      public static const LAYERS:int = 4;
      
      public var layers:Array;
      
      public var width:int;
      
      public var height:int;
      
      public var startx:int;
      
      public var starty:int;
      
      public var animFlip:int;
      
      public var tilePic:Class;
      
      public var jumps:Array;
      
      public var level2Spot:int;
      
      public function Level(tilePic:Class)
      {
         super();
         this.tilePic = tilePic;
         this.width = 32;
         this.height = 32;
         var a:Array = new Array();
         for(var i:int = 0; i < this.width * this.height; i++)
         {
            a.push(0);
         }
         this.layers = new Array();
         this.layers[LAYER_BACK] = new FlxTilemap();
         this.layers[LAYER_BACK].solid = false;
         this.layers[LAYER_SOLID] = new FlxTilemapExt();
         this.layers[LAYER_DECOR] = new FlxTilemap();
         this.layers[LAYER_DECOR].solid = false;
         this.startx = 0;
         this.starty = 0;
         this.animFlip = 0;
      }
      
      public function EditClear() : void
      {
         var a:Array = new Array();
         for(var i:int = 0; i < this.width * this.height; i++)
         {
            a.push(0);
         }
         this.layers[LAYER_BACK].loadMap(FlxTilemap.arrayToCSV(a,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         for(i = 0; i < this.width * this.height; i++)
         {
            if(i % this.width == 0 || i % this.width == this.width - 1 || int(i / this.width) == 0 || int(i / this.width) >= this.height - 3)
            {
               a[i] = 1;
            }
            else
            {
               a[i] = 0;
            }
         }
         this.layers[LAYER_SOLID].loadMap(FlxTilemap.arrayToCSV(a,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         for(i = 0; i < this.width * this.height; i++)
         {
            if(a[i] != 0)
            {
               this.layers[LAYER_SOLID].setTileByIndex(i,1);
            }
         }
      }
      
      public function EditInit() : void
      {
         var a:Array = new Array();
         for(var i:int = 0; i < this.width * this.height; i++)
         {
            a.push(0);
         }
         this.layers[LAYER_BACK].loadMap(FlxTilemap.arrayToCSV(a,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_SOLID].loadMap(FlxTilemap.arrayToCSV(a,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_DECOR].loadMap(FlxTilemap.arrayToCSV(a,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_GOODIE] = new FlxTilemap();
         this.layers[LAYER_GOODIE].solid = false;
         this.layers[LAYER_GOODIE].loadMap(FlxTilemap.arrayToCSV(a,this.width),GoodieTilesImage,16,16,FlxTilemap.OFF,0,1,1);
      }
      
      public function LoadStore(m:MapStore) : void
      {
         this.width = m.width;
         this.height = m.height;
         this.layers[LAYER_BACK].loadMap(FlxTilemap.arrayToCSV(m.GetLayer(0),this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_SOLID].loadMap(FlxTilemap.arrayToCSV(m.GetLayer(1),this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_DECOR].loadMap(FlxTilemap.arrayToCSV(m.GetLayer(2),this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
      }
      
      public function GoodieMap() : void
      {
         this.layers[LAYER_GOODIE].loadMap(FlxTilemap.arrayToCSV(Global.mapStore.GetLayer(3),this.width),GoodieTilesImage,16,16,FlxTilemap.OFF,0,1,1);
      }
      
      public function GetLayer(i:int) : FlxTilemap
      {
         if(i < 0 || i >= LAYERS)
         {
            return null;
         }
         return this.layers[i];
      }
      
      public function Resize(newWid:uint, newHei:uint, slideX:int, slideY:int) : void
      {
         var m:Array = null;
         var i:int = 0;
         var x:int = 0;
         var y:int = 0;
         var sx:int = 0;
         var sy:int = 0;
         var t:FlxTilemap = null;
         var layer:int = 0;
         var c:Class = null;
         m = new Array();
         for(i = 0; i < LAYERS; i++)
         {
            for(x = 0; x < newWid; x++)
            {
               sx = x + slideX;
               for(y = 0; y < newHei; y++)
               {
                  sy = y + slideY;
                  if(sx < 0 || sy < 0 || sx >= this.width || sy >= this.height)
                  {
                     m[x + y * newWid] = 0;
                  }
                  else
                  {
                     m[x + y * newWid] = (this.layers[i] as FlxTilemap).getTile(sx,sy);
                  }
               }
            }
            t = this.layers[i] as FlxTilemap;
            if(i == LAYER_SOLID)
            {
               this.layers[i] = new FlxTilemapExt();
            }
            else
            {
               this.layers[i] = new FlxTilemap();
            }
            if(i == LAYER_GOODIE)
            {
               c = GoodieTilesImage;
            }
            else
            {
               c = this.tilePic;
            }
            (this.layers[i] as FlxTilemap).loadMap(FlxTilemap.arrayToCSV(m,newWid),c,Global.TILE_WIDTH,Global.TILE_HEIGHT);
            FlxG.state.replace(t,this.layers[i]);
         }
         this.width = newWid;
         this.height = newHei;
      }
      
      public function IsEmpty(tx:int, ty:int) : Boolean
      {
         if(tx < 0 || ty < 0 || tx >= this.width || ty >= this.height)
         {
            return false;
         }
         for(var i:int = 0; i < LAYERS; i++)
         {
            if((this.layers[i] as FlxTilemap).getTile(tx,ty) != 0)
            {
               return false;
            }
         }
         return true;
      }
      
      public function OnTheMap(tx:int, ty:int) : Boolean
      {
         return tx >= 0 && ty >= 0 && tx < this.width && ty < this.height;
      }
      
      public function ClearSpot(tx:int, ty:int) : void
      {
         for(var i:int = 0; i < LAYERS; i++)
         {
            this.layers[i].setTile(tx,ty,0);
         }
      }
      
      public function Animate() : void
      {
         var i:int = 0;
         var t:int = 0;
         var x:int = 0;
         var y:int = 0;
         var a:Array = this.layers[LAYER_DECOR].getData();
         ++this.animFlip;
         for(i = 0; i < this.width * this.height; i++)
         {
            if((this.layers[LAYER_SOLID] as FlxTilemapExt).getTileByIndex(i) == 63 && Global.randRange(0,1) < 0.3)
            {
               x = i % this.width * Global.TILE_WIDTH + Global.randRange(0,Global.TILE_WIDTH);
               y = i / this.width * Global.TILE_HEIGHT;
               if(x >= FlxG.camera.scroll.x && x < FlxG.camera.scroll.x + FlxG.width && y >= FlxG.camera.scroll.y && y < FlxG.camera.scroll.y + FlxG.height)
               {
                  Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x,y,90,0);
               }
            }
         }
         this.animFlip = 0;
      }
      
      public function TagTripped(t:int) : void
      {
         var i:int = 0;
         var tripped:Boolean = false;
         for(i = 0; i < this.width * this.height; i++)
         {
            if((this.layers[LAYER_SOLID] as FlxTilemapExt).getTileByIndex(i) == 55 + t)
            {
               tripped = true;
               (this.layers[LAYER_SOLID] as FlxTilemapExt).setTileByIndex(i,0);
               if(Global.levelNum == 2 && t == 2)
               {
                  this.level2Spot = i;
               }
            }
         }
         if(tripped)
         {
            FlxG.flash(4278255615,0.2);
            Sounds.play(Sounds.WallDownSnd);
         }
      }
   }
}

