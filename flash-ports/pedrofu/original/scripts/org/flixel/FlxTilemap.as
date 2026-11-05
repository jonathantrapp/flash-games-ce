package org.flixel
{
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.flixel.system.FlxTile;
   import org.flixel.system.FlxTilemapBuffer;
   
   public class FlxTilemap extends FlxObject
   {
      
      public static var ImgAuto:Class = FlxTilemap_ImgAuto;
      
      public static var ImgAutoAlt:Class = FlxTilemap_ImgAutoAlt;
      
      public static const OFF:uint = 0;
      
      public static const AUTO:uint = 1;
      
      public static const ALT:uint = 2;
      
      public var auto:uint;
      
      public var widthInTiles:uint;
      
      public var heightInTiles:uint;
      
      public var totalTiles:uint;
      
      protected var _flashPoint:Point;
      
      protected var _flashRect:Rectangle;
      
      protected var _tiles:BitmapData;
      
      protected var _buffers:Array;
      
      protected var _data:Array;
      
      protected var _rects:Array;
      
      protected var _tileWidth:uint;
      
      protected var _tileHeight:uint;
      
      protected var _tileObjects:Array;
      
      protected var _debugTileNotSolid:BitmapData;
      
      protected var _debugTilePartial:BitmapData;
      
      protected var _debugTileSolid:BitmapData;
      
      protected var _debugRect:Rectangle;
      
      protected var _lastVisualDebug:Boolean;
      
      protected var _startingIndex:uint;
      
      public function FlxTilemap()
      {
         super();
         this.auto = OFF;
         this.widthInTiles = 0;
         this.heightInTiles = 0;
         this.totalTiles = 0;
         this._buffers = new Array();
         this._flashPoint = new Point();
         this._flashRect = null;
         this._data = null;
         this._tileWidth = 0;
         this._tileHeight = 0;
         this._rects = null;
         this._tiles = null;
         this._tileObjects = null;
         immovable = true;
         cameras = null;
         this._debugTileNotSolid = null;
         this._debugTilePartial = null;
         this._debugTileSolid = null;
         this._debugRect = null;
         this._lastVisualDebug = FlxG.visualDebug;
         this._startingIndex = 0;
      }
      
      public static function arrayToCSV(Data:Array, Width:int, Invert:Boolean = false) : String
      {
         var column:uint = 0;
         var csv:String = null;
         var index:int = 0;
         var row:uint = 0;
         var Height:int = Data.length / Width;
         while(row < Height)
         {
            column = 0;
            while(column < Width)
            {
               index = int(Data[row * Width + column]);
               if(Invert)
               {
                  if(index == 0)
                  {
                     index = 1;
                  }
                  else if(index == 1)
                  {
                     index = 0;
                  }
               }
               if(column == 0)
               {
                  if(row == 0)
                  {
                     csv += index;
                  }
                  else
                  {
                     csv += "\n" + index;
                  }
               }
               else
               {
                  csv += ", " + index;
               }
               column++;
            }
            row++;
         }
         return csv;
      }
      
      public static function bitmapToCSV(bitmapData:BitmapData, Invert:Boolean = false, Scale:uint = 1) : String
      {
         var column:uint = 0;
         var pixel:uint = 0;
         var bd:BitmapData = null;
         var mtx:Matrix = null;
         if(Scale > 1)
         {
            bd = bitmapData;
            bitmapData = new BitmapData(bitmapData.width * Scale,bitmapData.height * Scale);
            mtx = new Matrix();
            mtx.scale(Scale,Scale);
            bitmapData.draw(bd,mtx);
         }
         var row:uint = 0;
         var csv:String = "";
         var bitmapWidth:uint = uint(bitmapData.width);
         var bitmapHeight:uint = uint(bitmapData.height);
         while(row < bitmapHeight)
         {
            column = 0;
            while(column < bitmapWidth)
            {
               pixel = bitmapData.getPixel(column,row);
               if(Invert && pixel > 0 || !Invert && pixel == 0)
               {
                  pixel = 1;
               }
               else
               {
                  pixel = 0;
               }
               if(column == 0)
               {
                  if(row == 0)
                  {
                     csv += pixel;
                  }
                  else
                  {
                     csv += "\n" + pixel;
                  }
               }
               else
               {
                  csv += ", " + pixel;
               }
               column++;
            }
            row++;
         }
         return csv;
      }
      
      public static function imageToCSV(ImageFile:Class, Invert:Boolean = false, Scale:uint = 1) : String
      {
         return bitmapToCSV(new ImageFile().bitmapData,Invert,Scale);
      }
      
      override public function destroy() : void
      {
         this._flashPoint = null;
         this._flashRect = null;
         this._tiles = null;
         var i:uint = 0;
         var l:uint = this._tileObjects.length;
         while(i < l)
         {
            (this._tileObjects[i++] as FlxTile).destroy();
         }
         this._tileObjects = null;
         i = 0;
         l = this._buffers.length;
         while(i < l)
         {
            (this._buffers[i++] as FlxTilemapBuffer).destroy();
         }
         this._buffers = null;
         this._data = null;
         this._rects = null;
         this._debugTileNotSolid = null;
         this._debugTilePartial = null;
         this._debugTileSolid = null;
         this._debugRect = null;
         super.destroy();
      }
      
      public function loadMap(MapData:String, TileGraphic:Class, TileWidth:uint = 0, TileHeight:uint = 0, AutoTile:uint = 0, StartingIndex:uint = 0, DrawIndex:uint = 1, CollideIndex:uint = 1) : FlxTilemap
      {
         var columns:Array = null;
         var column:uint = 0;
         var i:uint = 0;
         var ac:uint = 0;
         this.auto = AutoTile;
         this._startingIndex = StartingIndex;
         var rows:Array = MapData.split("\n");
         this.heightInTiles = rows.length;
         this._data = new Array();
         var row:uint = 0;
         while(row < this.heightInTiles)
         {
            columns = rows[row++].split(",");
            if(columns.length <= 1)
            {
               this.heightInTiles -= 1;
            }
            else
            {
               this.widthInTiles = columns.length;
               column = 0;
               while(column < this.widthInTiles)
               {
                  this._data.push(uint(columns[column++]));
               }
            }
         }
         this.totalTiles = this.widthInTiles * this.heightInTiles;
         if(this.auto > OFF)
         {
            this._startingIndex = 1;
            DrawIndex = 1;
            CollideIndex = 1;
            i = 0;
            while(i < this.totalTiles)
            {
               this.autoTile(i++);
            }
         }
         this._tiles = FlxG.addBitmap(TileGraphic);
         this._tileWidth = TileWidth;
         if(this._tileWidth == 0)
         {
            this._tileWidth = this._tiles.height;
         }
         this._tileHeight = TileHeight;
         if(this._tileHeight == 0)
         {
            this._tileHeight = this._tileWidth;
         }
         i = 0;
         var l:uint = this._tiles.width / this._tileWidth * (this._tiles.height / this._tileHeight);
         if(this.auto > OFF)
         {
            l++;
         }
         this._tileObjects = new Array(l);
         while(i < l)
         {
            this._tileObjects[i] = new FlxTile(this,i,this._tileWidth,this._tileHeight,i >= DrawIndex,i >= CollideIndex ? allowCollisions : NONE);
            i++;
         }
         this._debugTileNotSolid = this.makeDebugTile(FlxG.BLUE);
         this._debugTilePartial = this.makeDebugTile(FlxG.PINK);
         this._debugTileSolid = this.makeDebugTile(FlxG.GREEN);
         this._debugRect = new Rectangle(0,0,this._tileWidth,this._tileHeight);
         width = this.widthInTiles * this._tileWidth;
         height = this.heightInTiles * this._tileHeight;
         this._rects = new Array(this.totalTiles);
         i = 0;
         while(i < this.totalTiles)
         {
            this.updateTile(i++);
         }
         return this;
      }
      
      protected function makeDebugTile(Color:uint) : BitmapData
      {
         var debugTile:BitmapData = null;
         debugTile = new BitmapData(this._tileWidth,this._tileHeight,true,0);
         var gfx:Graphics = FlxG.flashGfx;
         gfx.clear();
         gfx.moveTo(0,0);
         gfx.lineStyle(1,Color,0.5);
         gfx.lineTo(this._tileWidth - 1,0);
         gfx.lineTo(this._tileWidth - 1,this._tileHeight - 1);
         gfx.lineTo(0,this._tileHeight - 1);
         gfx.lineTo(0,0);
         debugTile.draw(FlxG.flashGfxSprite);
         return debugTile;
      }
      
      override public function update() : void
      {
         if(this._lastVisualDebug != FlxG.visualDebug)
         {
            this._lastVisualDebug = FlxG.visualDebug;
            this.setDirty();
         }
      }
      
      protected function drawTilemap(Buffer:FlxTilemapBuffer, Camera:FlxCamera) : void
      {
         var column:uint = 0;
         var columnIndex:uint = 0;
         var tile:FlxTile = null;
         var debugTile:BitmapData = null;
         Buffer.fill();
         _point.x = int(Camera.scroll.x * scrollFactor.x) - x;
         _point.y = int(Camera.scroll.y * scrollFactor.y) - y;
         var screenXInTiles:int = (_point.x + (_point.x > 0 ? 1e-7 : -1e-7)) / this._tileWidth;
         var screenYInTiles:int = (_point.y + (_point.y > 0 ? 1e-7 : -1e-7)) / this._tileHeight;
         var screenRows:uint = Buffer.rows;
         var screenColumns:uint = Buffer.columns;
         if(screenXInTiles < 0)
         {
            screenXInTiles = 0;
         }
         if(screenXInTiles > this.widthInTiles - screenColumns)
         {
            screenXInTiles = this.widthInTiles - screenColumns;
         }
         if(screenYInTiles < 0)
         {
            screenYInTiles = 0;
         }
         if(screenYInTiles > this.heightInTiles - screenRows)
         {
            screenYInTiles = this.heightInTiles - screenRows;
         }
         var rowIndex:int = screenYInTiles * this.widthInTiles + screenXInTiles;
         this._flashPoint.y = 0;
         var row:uint = 0;
         while(row < screenRows)
         {
            columnIndex = uint(rowIndex);
            column = 0;
            this._flashPoint.x = 0;
            while(column < screenColumns)
            {
               this._flashRect = this._rects[columnIndex] as Rectangle;
               if(this._flashRect != null)
               {
                  Buffer.pixels.copyPixels(this._tiles,this._flashRect,this._flashPoint,null,null,true);
                  if(FlxG.visualDebug && !ignoreDrawDebug)
                  {
                     tile = this._tileObjects[this._data[columnIndex]];
                     if(tile != null)
                     {
                        if(tile.allowCollisions <= NONE)
                        {
                           debugTile = this._debugTileNotSolid;
                        }
                        else if(tile.allowCollisions != ANY)
                        {
                           debugTile = this._debugTilePartial;
                        }
                        else
                        {
                           debugTile = this._debugTileSolid;
                        }
                        Buffer.pixels.copyPixels(debugTile,this._debugRect,this._flashPoint,null,null,true);
                     }
                  }
               }
               this._flashPoint.x += this._tileWidth;
               column++;
               columnIndex++;
            }
            rowIndex += this.widthInTiles;
            this._flashPoint.y += this._tileHeight;
            row++;
         }
         Buffer.x = screenXInTiles * this._tileWidth;
         Buffer.y = screenYInTiles * this._tileHeight;
      }
      
      override public function draw() : void
      {
         var camera:FlxCamera = null;
         var buffer:FlxTilemapBuffer = null;
         if(_flickerTimer != 0)
         {
            _flicker = !_flicker;
            if(_flicker)
            {
               return;
            }
         }
         if(cameras == null)
         {
            cameras = FlxG.cameras;
         }
         var i:uint = 0;
         var l:uint = cameras.length;
         while(i < l)
         {
            camera = cameras[i];
            if(this._buffers[i] == null)
            {
               this._buffers[i] = new FlxTilemapBuffer(this._tileWidth,this._tileHeight,this.widthInTiles,this.heightInTiles,camera);
            }
            buffer = this._buffers[i++] as FlxTilemapBuffer;
            if(!buffer.dirty)
            {
               _point.x = x - int(camera.scroll.x * scrollFactor.x) + buffer.x;
               _point.y = y - int(camera.scroll.y * scrollFactor.y) + buffer.y;
               buffer.dirty = _point.x > 0 || _point.y > 0 || _point.x + buffer.width < camera.width || _point.y + buffer.height < camera.height;
            }
            if(buffer.dirty)
            {
               this.drawTilemap(buffer,camera);
               buffer.dirty = false;
            }
            this._flashPoint.x = x - int(camera.scroll.x * scrollFactor.x) + buffer.x;
            this._flashPoint.y = y - int(camera.scroll.y * scrollFactor.y) + buffer.y;
            this._flashPoint.x += this._flashPoint.x > 0 ? 1e-7 : -1e-7;
            this._flashPoint.y += this._flashPoint.y > 0 ? 1e-7 : -1e-7;
            buffer.draw(camera,this._flashPoint);
            ++_VISIBLECOUNT;
         }
      }
      
      public function getData(Simple:Boolean = false) : Array
      {
         if(!Simple)
         {
            return this._data;
         }
         var i:uint = 0;
         var l:uint = this._data.length;
         var data:Array = new Array(l);
         while(i < l)
         {
            data[i] = (this._tileObjects[this._data[i]] as FlxTile).allowCollisions > 0 ? 1 : 0;
            i++;
         }
         return data;
      }
      
      public function setDirty(Dirty:Boolean = true) : void
      {
         var i:uint = 0;
         var l:uint = this._buffers.length;
         while(i < l)
         {
            (this._buffers[i++] as FlxTilemapBuffer).dirty = Dirty;
         }
      }
      
      public function findPath(Start:FlxPoint, End:FlxPoint, Simplify:Boolean = true, RaySimplify:Boolean = false) : FlxPath
      {
         var node:FlxPoint = null;
         var startIndex:uint = int((Start.y - y) / this._tileHeight) * this.widthInTiles + int((Start.x - x) / this._tileWidth);
         var endIndex:uint = int((End.y - y) / this._tileHeight) * this.widthInTiles + int((End.x - x) / this._tileWidth);
         if((this._tileObjects[this._data[startIndex]] as FlxTile).allowCollisions > 0 || (this._tileObjects[this._data[endIndex]] as FlxTile).allowCollisions > 0)
         {
            return null;
         }
         var distances:Array = this.computePathDistance(startIndex,endIndex);
         if(distances == null)
         {
            return null;
         }
         var points:Array = new Array();
         this.walkPath(distances,endIndex,points);
         node = points[points.length - 1] as FlxPoint;
         node.x = Start.x;
         node.y = Start.y;
         node = points[0] as FlxPoint;
         node.x = End.x;
         node.y = End.y;
         if(Simplify)
         {
            this.simplifyPath(points);
         }
         if(RaySimplify)
         {
            this.raySimplifyPath(points);
         }
         var path:FlxPath = new FlxPath();
         var i:int = points.length - 1;
         while(i >= 0)
         {
            node = points[i--] as FlxPoint;
            if(node != null)
            {
               path.addPoint(node,true);
            }
         }
         return path;
      }
      
      protected function simplifyPath(Points:Array) : void
      {
         var deltaPrevious:Number = NaN;
         var deltaNext:Number = NaN;
         var node:FlxPoint = null;
         var last:FlxPoint = Points[0];
         var i:uint = 1;
         var l:uint = Points.length - 1;
         while(i < l)
         {
            node = Points[i];
            deltaPrevious = (node.x - last.x) / (node.y - last.y);
            deltaNext = (node.x - Points[i + 1].x) / (node.y - Points[i + 1].y);
            if(last.x == Points[i + 1].x || last.y == Points[i + 1].y || deltaPrevious == deltaNext)
            {
               Points[i] = null;
            }
            else
            {
               last = node;
            }
            i++;
         }
      }
      
      protected function raySimplifyPath(Points:Array) : void
      {
         var node:FlxPoint = null;
         var source:FlxPoint = Points[0];
         var lastIndex:int = -1;
         var i:uint = 1;
         var l:uint = Points.length;
         while(i < l)
         {
            node = Points[i++];
            if(node != null)
            {
               if(this.ray(source,node,_point))
               {
                  if(lastIndex >= 0)
                  {
                     Points[lastIndex] = null;
                  }
               }
               else
               {
                  source = Points[lastIndex];
               }
               lastIndex = i - 1;
            }
         }
      }
      
      protected function computePathDistance(StartIndex:uint, EndIndex:uint) : Array
      {
         var current:Array = null;
         var currentIndex:uint = 0;
         var left:Boolean = false;
         var right:Boolean = false;
         var up:Boolean = false;
         var down:Boolean = false;
         var currentLength:uint = 0;
         var index:uint = 0;
         var mapSize:uint = this.widthInTiles * this.heightInTiles;
         var distances:Array = new Array(mapSize);
         var i:int = 0;
         while(i < mapSize)
         {
            if(Boolean((this._tileObjects[this._data[i]] as FlxTile).allowCollisions))
            {
               distances[i] = -2;
            }
            else
            {
               distances[i] = -1;
            }
            i++;
         }
         distances[StartIndex] = 0;
         var distance:uint = 1;
         var neighbors:Array = [StartIndex];
         var foundEnd:Boolean = false;
         while(neighbors.length > 0)
         {
            current = neighbors;
            neighbors = new Array();
            i = 0;
            currentLength = current.length;
            while(i < currentLength)
            {
               currentIndex = uint(current[i++]);
               if(currentIndex == EndIndex)
               {
                  foundEnd = true;
                  neighbors.length = 0;
                  break;
               }
               left = currentIndex % this.widthInTiles > 0;
               right = currentIndex % this.widthInTiles < this.widthInTiles - 1;
               up = currentIndex / this.widthInTiles > 0;
               down = currentIndex / this.widthInTiles < this.heightInTiles - 1;
               if(up)
               {
                  index = currentIndex - this.widthInTiles;
                  if(distances[index] == -1)
                  {
                     distances[index] = distance;
                     neighbors.push(index);
                  }
               }
               if(right)
               {
                  index = currentIndex + 1;
                  if(distances[index] == -1)
                  {
                     distances[index] = distance;
                     neighbors.push(index);
                  }
               }
               if(down)
               {
                  index = currentIndex + this.widthInTiles;
                  if(distances[index] == -1)
                  {
                     distances[index] = distance;
                     neighbors.push(index);
                  }
               }
               if(left)
               {
                  index = currentIndex - 1;
                  if(distances[index] == -1)
                  {
                     distances[index] = distance;
                     neighbors.push(index);
                  }
               }
               if(up && right)
               {
                  index = currentIndex - this.widthInTiles + 1;
                  if(distances[index] == -1 && distances[currentIndex - this.widthInTiles] >= -1 && distances[currentIndex + 1] >= -1)
                  {
                     distances[index] = distance;
                     neighbors.push(index);
                  }
               }
               if(right && down)
               {
                  index = currentIndex + this.widthInTiles + 1;
                  if(distances[index] == -1 && distances[currentIndex + this.widthInTiles] >= -1 && distances[currentIndex + 1] >= -1)
                  {
                     distances[index] = distance;
                     neighbors.push(index);
                  }
               }
               if(left && down)
               {
                  index = currentIndex + this.widthInTiles - 1;
                  if(distances[index] == -1 && distances[currentIndex + this.widthInTiles] >= -1 && distances[currentIndex - 1] >= -1)
                  {
                     distances[index] = distance;
                     neighbors.push(index);
                  }
               }
               if(up && left)
               {
                  index = currentIndex - this.widthInTiles - 1;
                  if(distances[index] == -1 && distances[currentIndex - this.widthInTiles] >= -1 && distances[currentIndex - 1] >= -1)
                  {
                     distances[index] = distance;
                     neighbors.push(index);
                  }
               }
            }
            distance++;
         }
         if(!foundEnd)
         {
            distances = null;
         }
         return distances;
      }
      
      protected function walkPath(Data:Array, Start:uint, Points:Array) : void
      {
         var i:uint = 0;
         Points.push(new FlxPoint(x + uint(Start % this.widthInTiles) * this._tileWidth + this._tileWidth * 0.5,y + uint(Start / this.widthInTiles) * this._tileHeight + this._tileHeight * 0.5));
         if(Data[Start] == 0)
         {
            return;
         }
         var left:Boolean = Start % this.widthInTiles > 0;
         var right:Boolean = Start % this.widthInTiles < this.widthInTiles - 1;
         var up:Boolean = Start / this.widthInTiles > 0;
         var down:Boolean = Start / this.widthInTiles < this.heightInTiles - 1;
         var current:uint = uint(Data[Start]);
         if(up)
         {
            i = Start - this.widthInTiles;
            if(Data[i] >= 0 && Data[i] < current)
            {
               this.walkPath(Data,i,Points);
               return;
            }
         }
         if(right)
         {
            i = Start + 1;
            if(Data[i] >= 0 && Data[i] < current)
            {
               this.walkPath(Data,i,Points);
               return;
            }
         }
         if(down)
         {
            i = Start + this.widthInTiles;
            if(Data[i] >= 0 && Data[i] < current)
            {
               this.walkPath(Data,i,Points);
               return;
            }
         }
         if(left)
         {
            i = Start - 1;
            if(Data[i] >= 0 && Data[i] < current)
            {
               this.walkPath(Data,i,Points);
               return;
            }
         }
         if(up && right)
         {
            i = Start - this.widthInTiles + 1;
            if(Data[i] >= 0 && Data[i] < current)
            {
               this.walkPath(Data,i,Points);
               return;
            }
         }
         if(right && down)
         {
            i = Start + this.widthInTiles + 1;
            if(Data[i] >= 0 && Data[i] < current)
            {
               this.walkPath(Data,i,Points);
               return;
            }
         }
         if(left && down)
         {
            i = Start + this.widthInTiles - 1;
            if(Data[i] >= 0 && Data[i] < current)
            {
               this.walkPath(Data,i,Points);
               return;
            }
         }
         if(up && left)
         {
            i = Start - this.widthInTiles - 1;
            if(Data[i] >= 0 && Data[i] < current)
            {
               this.walkPath(Data,i,Points);
               return;
            }
         }
      }
      
      override public function overlaps(ObjectOrGroup:FlxBasic, InScreenSpace:Boolean = false, Camera:FlxCamera = null) : Boolean
      {
         var results:Boolean = false;
         var basic:FlxBasic = null;
         var i:uint = 0;
         var members:Array = null;
         if(ObjectOrGroup is FlxGroup)
         {
            results = false;
            i = 0;
            members = (ObjectOrGroup as FlxGroup).members;
            while(i < length)
            {
               basic = members[i++] as FlxBasic;
               if(basic is FlxObject)
               {
                  if(this.overlapsWithCallback(basic as FlxObject))
                  {
                     results = true;
                  }
               }
               else if(this.overlaps(basic,InScreenSpace,Camera))
               {
                  results = true;
               }
            }
            return results;
         }
         if(ObjectOrGroup is FlxObject)
         {
            return this.overlapsWithCallback(ObjectOrGroup as FlxObject);
         }
         return false;
      }
      
      override public function overlapsAt(X:Number, Y:Number, ObjectOrGroup:FlxBasic, InScreenSpace:Boolean = false, Camera:FlxCamera = null) : Boolean
      {
         var results:Boolean = false;
         var basic:FlxBasic = null;
         var i:uint = 0;
         var members:Array = null;
         if(ObjectOrGroup is FlxGroup)
         {
            results = false;
            i = 0;
            members = (ObjectOrGroup as FlxGroup).members;
            while(i < length)
            {
               basic = members[i++] as FlxBasic;
               if(basic is FlxObject)
               {
                  _point.x = X;
                  _point.y = Y;
                  if(this.overlapsWithCallback(basic as FlxObject,null,false,_point))
                  {
                     results = true;
                  }
               }
               else if(this.overlapsAt(X,Y,basic,InScreenSpace,Camera))
               {
                  results = true;
               }
            }
            return results;
         }
         if(ObjectOrGroup is FlxObject)
         {
            _point.x = X;
            _point.y = Y;
            return this.overlapsWithCallback(ObjectOrGroup as FlxObject,null,false,_point);
         }
         return false;
      }
      
      public function overlapsWithCallback(Object:FlxObject, Callback:Function = null, FlipCallbackParams:Boolean = false, Position:FlxPoint = null) : Boolean
      {
         var column:uint = 0;
         var tile:FlxTile = null;
         var overlapFound:Boolean = false;
         var results:Boolean = false;
         var X:Number = x;
         var Y:Number = y;
         if(Position != null)
         {
            X = Position.x;
            Y = Position.y;
         }
         var selectionX:int = FlxU.floor((Object.x - X) / this._tileWidth);
         var selectionY:int = FlxU.floor((Object.y - Y) / this._tileHeight);
         var selectionWidth:uint = selectionX + FlxU.ceil(Object.width / this._tileWidth) + 1;
         var selectionHeight:uint = selectionY + FlxU.ceil(Object.height / this._tileHeight) + 1;
         if(selectionX < 0)
         {
            selectionX = 0;
         }
         if(selectionY < 0)
         {
            selectionY = 0;
         }
         if(selectionWidth > this.widthInTiles)
         {
            selectionWidth = this.widthInTiles;
         }
         if(selectionHeight > this.heightInTiles)
         {
            selectionHeight = this.heightInTiles;
         }
         var rowStart:uint = selectionY * this.widthInTiles;
         var row:uint = uint(selectionY);
         var deltaX:Number = X - last.x;
         var deltaY:Number = Y - last.y;
         while(row < selectionHeight)
         {
            column = uint(selectionX);
            while(column < selectionWidth)
            {
               overlapFound = false;
               tile = this._tileObjects[this._data[rowStart + column]] as FlxTile;
               if(Boolean(tile.allowCollisions))
               {
                  tile.x = X + column * this._tileWidth;
                  tile.y = Y + row * this._tileHeight;
                  tile.last.x = tile.x - deltaX;
                  tile.last.y = tile.y - deltaY;
                  if(Callback != null)
                  {
                     if(FlipCallbackParams)
                     {
                        overlapFound = Callback(Object,tile);
                     }
                     else
                     {
                        overlapFound = Callback(tile,Object);
                     }
                  }
                  else
                  {
                     overlapFound = Object.x + Object.width > tile.x && Object.x < tile.x + tile.width && Object.y + Object.height > tile.y && Object.y < tile.y + tile.height;
                  }
                  if(overlapFound)
                  {
                     if(tile.callback != null && (tile.filter == null || Object is tile.filter))
                     {
                        tile.mapIndex = rowStart + column;
                        tile.callback(tile,Object);
                     }
                     results = true;
                  }
               }
               else if(tile.callback != null && (tile.filter == null || Object is tile.filter))
               {
                  tile.mapIndex = rowStart + column;
                  tile.callback(tile,Object);
               }
               column++;
            }
            rowStart += this.widthInTiles;
            row++;
         }
         return results;
      }
      
      override public function overlapsPoint(Point:FlxPoint, InScreenSpace:Boolean = false, Camera:FlxCamera = null) : Boolean
      {
         if(!InScreenSpace)
         {
            return (this._tileObjects[this._data[uint(uint((Point.y - y) / this._tileHeight) * this.widthInTiles + (Point.x - x) / this._tileWidth)]] as FlxTile).allowCollisions > 0;
         }
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         Point.x -= Camera.scroll.x;
         Point.y -= Camera.scroll.y;
         getScreenXY(_point,Camera);
         return (this._tileObjects[this._data[uint(uint((Point.y - _point.y) / this._tileHeight) * this.widthInTiles + (Point.x - _point.x) / this._tileWidth)]] as FlxTile).allowCollisions > 0;
      }
      
      public function getTile(X:uint, Y:uint) : uint
      {
         return this._data[Y * this.widthInTiles + X] as uint;
      }
      
      public function getTileByIndex(Index:uint) : uint
      {
         return this._data[Index] as uint;
      }
      
      public function getTileInstances(Index:uint) : Array
      {
         var array:Array = null;
         var i:uint = 0;
         var l:uint = this.widthInTiles * this.heightInTiles;
         while(i < l)
         {
            if(this._data[i] == Index)
            {
               if(array == null)
               {
                  array = new Array();
               }
               array.push(i);
            }
            i++;
         }
         return array;
      }
      
      public function getTileCoords(Index:uint, Midpoint:Boolean = true) : Array
      {
         var point:FlxPoint = null;
         var array:Array = null;
         var i:uint = 0;
         var l:uint = this.widthInTiles * this.heightInTiles;
         while(i < l)
         {
            if(this._data[i] == Index)
            {
               point = new FlxPoint(x + uint(i % this.widthInTiles) * this._tileWidth,y + uint(i / this.widthInTiles) * this._tileHeight);
               if(Midpoint)
               {
                  point.x += this._tileWidth * 0.5;
                  point.y += this._tileHeight * 0.5;
               }
               if(array == null)
               {
                  array = new Array();
               }
               array.push(point);
            }
            i++;
         }
         return array;
      }
      
      public function setTile(X:uint, Y:uint, Tile:uint, UpdateGraphics:Boolean = true) : Boolean
      {
         if(X >= this.widthInTiles || Y >= this.heightInTiles)
         {
            return false;
         }
         return this.setTileByIndex(Y * this.widthInTiles + X,Tile,UpdateGraphics);
      }
      
      public function setTileByIndex(Index:uint, Tile:uint, UpdateGraphics:Boolean = true) : Boolean
      {
         var i:uint = 0;
         if(Index >= this._data.length)
         {
            return false;
         }
         var ok:Boolean = true;
         this._data[Index] = Tile;
         if(!UpdateGraphics)
         {
            return ok;
         }
         this.setDirty();
         if(this.auto == OFF)
         {
            this.updateTile(Index);
            return ok;
         }
         var row:int = int(Index / this.widthInTiles) - 1;
         var rowLength:int = row + 3;
         var column:int = Index % this.widthInTiles - 1;
         var columnHeight:int = column + 3;
         while(row < rowLength)
         {
            column = columnHeight - 3;
            while(column < columnHeight)
            {
               if(row >= 0 && row < this.heightInTiles && column >= 0 && column < this.widthInTiles)
               {
                  i = row * this.widthInTiles + column;
                  this.autoTile(i);
                  this.updateTile(i);
               }
               column++;
            }
            row++;
         }
         return ok;
      }
      
      public function setTileProperties(Tile:uint, AllowCollisions:uint = 4369, Callback:Function = null, CallbackFilter:Class = null, Range:uint = 1) : void
      {
         var tile:FlxTile = null;
         if(Range <= 0)
         {
            Range = 1;
         }
         var i:uint = Tile;
         var l:uint = Tile + Range;
         while(i < l)
         {
            tile = this._tileObjects[i++] as FlxTile;
            tile.allowCollisions = AllowCollisions;
            tile.callback = Callback;
            tile.filter = CallbackFilter;
         }
      }
      
      public function getTileProperties(Tile:uint) : FlxTile
      {
         return this._tileObjects[Tile];
      }
      
      public function follow(Camera:FlxCamera = null, Border:int = 0, UpdateWorld:Boolean = true) : void
      {
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         Camera.setBounds(x + Border * this._tileWidth,y + Border * this._tileHeight,width - Border * this._tileWidth * 2,height - Border * this._tileHeight * 2,UpdateWorld);
      }
      
      public function getBounds(Bounds:FlxRect = null) : FlxRect
      {
         if(Bounds == null)
         {
            Bounds = new FlxRect();
         }
         return Bounds.make(x,y,width,height);
      }
      
      public function ray(Start:FlxPoint, End:FlxPoint, Result:FlxPoint = null, Resolution:Number = 1) : Boolean
      {
         var tileX:uint = 0;
         var tileY:uint = 0;
         var rx:Number = NaN;
         var ry:Number = NaN;
         var q:Number = NaN;
         var lx:Number = NaN;
         var ly:Number = NaN;
         var step:Number = this._tileWidth;
         if(this._tileHeight < this._tileWidth)
         {
            step = this._tileHeight;
         }
         step /= Resolution;
         var deltaX:Number = End.x - Start.x;
         var deltaY:Number = End.y - Start.y;
         var distance:Number = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
         var steps:uint = Math.ceil(distance / step);
         var stepX:Number = deltaX / steps;
         var stepY:Number = deltaY / steps;
         var curX:Number = Start.x - stepX - x;
         var curY:Number = Start.y - stepY - y;
         var i:uint = 0;
         while(i < steps)
         {
            curX += stepX;
            curY += stepY;
            if(curX < 0 || curX > width || curY < 0 || curY > height)
            {
               i++;
            }
            else
            {
               tileX = curX / this._tileWidth;
               tileY = curY / this._tileHeight;
               if(Boolean((this._tileObjects[this._data[tileY * this.widthInTiles + tileX]] as FlxTile).allowCollisions))
               {
                  tileX *= this._tileWidth;
                  tileY *= this._tileHeight;
                  rx = 0;
                  ry = 0;
                  lx = curX - stepX;
                  ly = curY - stepY;
                  q = tileX;
                  if(deltaX < 0)
                  {
                     q += this._tileWidth;
                  }
                  rx = q;
                  ry = ly + stepY * ((q - lx) / stepX);
                  if(ry > tileY && ry < tileY + this._tileHeight)
                  {
                     if(Result == null)
                     {
                        Result = new FlxPoint();
                     }
                     Result.x = rx;
                     Result.y = ry;
                     return false;
                  }
                  q = tileY;
                  if(deltaY < 0)
                  {
                     q += this._tileHeight;
                  }
                  rx = lx + stepX * ((q - ly) / stepY);
                  ry = q;
                  if(rx > tileX && rx < tileX + this._tileWidth)
                  {
                     if(Result == null)
                     {
                        Result = new FlxPoint();
                     }
                     Result.x = rx;
                     Result.y = ry;
                     return false;
                  }
                  return true;
               }
               i++;
            }
         }
         return true;
      }
      
      protected function autoTile(Index:uint) : void
      {
         if(this._data[Index] == 0)
         {
            return;
         }
         this._data[Index] = 0;
         if(Index - this.widthInTiles < 0 || this._data[Index - this.widthInTiles] > 0)
         {
            this._data[Index] += 1;
         }
         if(Index % this.widthInTiles >= this.widthInTiles - 1 || this._data[Index + 1] > 0)
         {
            this._data[Index] += 2;
         }
         if(Index + this.widthInTiles >= this.totalTiles || this._data[Index + this.widthInTiles] > 0)
         {
            this._data[Index] += 4;
         }
         if(Index % this.widthInTiles <= 0 || this._data[Index - 1] > 0)
         {
            this._data[Index] += 8;
         }
         if(this.auto == ALT && this._data[Index] == 15)
         {
            if(Index % this.widthInTiles > 0 && Index + this.widthInTiles < this.totalTiles && this._data[Index + this.widthInTiles - 1] <= 0)
            {
               this._data[Index] = 1;
            }
            if(Index % this.widthInTiles > 0 && Index - this.widthInTiles >= 0 && this._data[Index - this.widthInTiles - 1] <= 0)
            {
               this._data[Index] = 2;
            }
            if(Index % this.widthInTiles < this.widthInTiles - 1 && Index - this.widthInTiles >= 0 && this._data[Index - this.widthInTiles + 1] <= 0)
            {
               this._data[Index] = 4;
            }
            if(Index % this.widthInTiles < this.widthInTiles - 1 && Index + this.widthInTiles < this.totalTiles && this._data[Index + this.widthInTiles + 1] <= 0)
            {
               this._data[Index] = 8;
            }
         }
         this._data[Index] += 1;
      }
      
      protected function updateTile(Index:uint) : void
      {
         var tile:FlxTile = this._tileObjects[this._data[Index]] as FlxTile;
         if(tile == null || !tile.visible)
         {
            this._rects[Index] = null;
            return;
         }
         var rx:uint = (this._data[Index] - this._startingIndex) * this._tileWidth;
         var ry:uint = 0;
         if(rx >= this._tiles.width)
         {
            ry = uint(rx / this._tiles.width) * this._tileHeight;
            rx %= this._tiles.width;
         }
         this._rects[Index] = new Rectangle(rx,ry,this._tileWidth,this._tileHeight);
      }
   }
}

