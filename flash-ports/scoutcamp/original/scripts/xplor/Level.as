package xplor
{
   import org.flixel.*;
   
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
      
      public function Level(param1:Class)
      {
         super();
         this.tilePic = param1;
         this.width = 32;
         this.height = 32;
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this.width * this.height)
         {
            _loc2_.push(0);
            _loc3_++;
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
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.width * this.height)
         {
            _loc1_.push(0);
            _loc2_++;
         }
         this.layers[LAYER_BACK].loadMap(FlxTilemap.arrayToCSV(_loc1_,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         _loc2_ = 0;
         while(_loc2_ < this.width * this.height)
         {
            if(_loc2_ % this.width == 0 || _loc2_ % this.width == this.width - 1 || int(_loc2_ / this.width) == 0 || int(_loc2_ / this.width) >= this.height - 3)
            {
               _loc1_[_loc2_] = 1;
            }
            else
            {
               _loc1_[_loc2_] = 0;
            }
            _loc2_++;
         }
         this.layers[LAYER_SOLID].loadMap(FlxTilemap.arrayToCSV(_loc1_,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         _loc2_ = 0;
         while(_loc2_ < this.width * this.height)
         {
            if(_loc1_[_loc2_] != 0)
            {
               this.layers[LAYER_SOLID].setTileByIndex(_loc2_,1);
            }
            _loc2_++;
         }
      }
      
      public function EditInit() : void
      {
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.width * this.height)
         {
            _loc1_.push(0);
            _loc2_++;
         }
         this.layers[LAYER_BACK].loadMap(FlxTilemap.arrayToCSV(_loc1_,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_SOLID].loadMap(FlxTilemap.arrayToCSV(_loc1_,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_DECOR].loadMap(FlxTilemap.arrayToCSV(_loc1_,this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_GOODIE] = new FlxTilemap();
         this.layers[LAYER_GOODIE].solid = false;
         this.layers[LAYER_GOODIE].loadMap(FlxTilemap.arrayToCSV(_loc1_,this.width),GoodieTilesImage,16,16,FlxTilemap.OFF,0,1,1);
      }
      
      public function LoadStore(param1:MapStore) : void
      {
         this.width = param1.width;
         this.height = param1.height;
         this.layers[LAYER_BACK].loadMap(FlxTilemap.arrayToCSV(param1.GetLayer(0),this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_SOLID].loadMap(FlxTilemap.arrayToCSV(param1.GetLayer(1),this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
         this.layers[LAYER_DECOR].loadMap(FlxTilemap.arrayToCSV(param1.GetLayer(2),this.width),this.tilePic,16,16,FlxTilemap.OFF,0,1,1);
      }
      
      public function GoodieMap() : void
      {
         this.layers[LAYER_GOODIE].loadMap(FlxTilemap.arrayToCSV(Global.mapStore.GetLayer(3),this.width),GoodieTilesImage,16,16,FlxTilemap.OFF,0,1,1);
      }
      
      public function GetLayer(param1:int) : FlxTilemap
      {
         if(param1 < 0 || param1 >= LAYERS)
         {
            return null;
         }
         return this.layers[param1];
      }
      
      public function Resize(param1:uint, param2:uint, param3:int, param4:int) : void
      {
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:FlxTilemap = null;
         var _loc12_:int = 0;
         var _loc13_:Class = null;
         _loc5_ = new Array();
         _loc6_ = 0;
         while(_loc6_ < LAYERS)
         {
            _loc7_ = 0;
            while(_loc7_ < param1)
            {
               _loc9_ = _loc7_ + param3;
               _loc8_ = 0;
               while(_loc8_ < param2)
               {
                  _loc10_ = _loc8_ + param4;
                  if(_loc9_ < 0 || _loc10_ < 0 || _loc9_ >= this.width || _loc10_ >= this.height)
                  {
                     _loc5_[_loc7_ + _loc8_ * param1] = 0;
                  }
                  else
                  {
                     _loc5_[_loc7_ + _loc8_ * param1] = (this.layers[_loc6_] as FlxTilemap).getTile(_loc9_,_loc10_);
                  }
                  _loc8_++;
               }
               _loc7_++;
            }
            _loc11_ = this.layers[_loc6_] as FlxTilemap;
            if(_loc6_ == LAYER_SOLID)
            {
               this.layers[_loc6_] = new FlxTilemapExt();
            }
            else
            {
               this.layers[_loc6_] = new FlxTilemap();
            }
            if(_loc6_ == LAYER_GOODIE)
            {
               _loc13_ = GoodieTilesImage;
            }
            else
            {
               _loc13_ = this.tilePic;
            }
            (this.layers[_loc6_] as FlxTilemap).loadMap(FlxTilemap.arrayToCSV(_loc5_,param1),_loc13_,Global.TILE_WIDTH,Global.TILE_HEIGHT);
            FlxG.state.replace(_loc11_,this.layers[_loc6_]);
            _loc6_++;
         }
         this.width = param1;
         this.height = param2;
      }
      
      public function IsEmpty(param1:int, param2:int) : Boolean
      {
         if(param1 < 0 || param2 < 0 || param1 >= this.width || param2 >= this.height)
         {
            return false;
         }
         var _loc3_:int = 0;
         while(_loc3_ < LAYERS)
         {
            if((this.layers[_loc3_] as FlxTilemap).getTile(param1,param2) != 0)
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function OnTheMap(param1:int, param2:int) : Boolean
      {
         return param1 >= 0 && param2 >= 0 && param1 < this.width && param2 < this.height;
      }
      
      public function ClearSpot(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < LAYERS)
         {
            this.layers[_loc3_].setTile(param1,param2,0);
            _loc3_++;
         }
      }
      
      public function Animate() : void
      {
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Array = this.layers[LAYER_DECOR].getData();
         ++this.animFlip;
         if(this.animFlip == 3)
         {
            this.animFlip = 0;
         }
      }
   }
}

