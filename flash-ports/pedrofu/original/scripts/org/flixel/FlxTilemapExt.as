package org.flixel
{
   import org.flixel.system.FlxTile;
   
   public class FlxTilemapExt extends FlxTilemap
   {
      
      public static const SLOPE_FLOOR_LEFT:int = 268439825;
      
      public static const SLOPE_FLOOR_RIGHT:int = 536875281;
      
      public static const SLOPE_CEIL_LEFT:int = 805310737;
      
      public static const SLOPE_CEIL_RIGHT:int = 1073746193;
      
      private var _snapping:uint = 2;
      
      private var _slopePoint:FlxPoint = new FlxPoint();
      
      private var _objPoint:FlxPoint = new FlxPoint();
      
      public var isSlope:Array = new Array();
      
      public function FlxTilemapExt()
      {
         super();
      }
      
      override public function setTileProperties(Tile:uint, AllowCollisions:uint = 4369, Callback:Function = null, CallbackFilter:Class = null, Range:uint = 1) : void
      {
         switch(AllowCollisions)
         {
            case SLOPE_FLOOR_LEFT:
               this.isSlope[Tile] = true;
               super.setTileProperties(Tile,RIGHT | FLOOR,this.solveCollisionSlopeFloorLeft,CallbackFilter,Range);
               break;
            case SLOPE_FLOOR_RIGHT:
               this.isSlope[Tile] = true;
               super.setTileProperties(Tile,LEFT | FLOOR,this.solveCollisionSlopeFloorRight,CallbackFilter,Range);
               break;
            case SLOPE_CEIL_LEFT:
               this.isSlope[Tile] = true;
               super.setTileProperties(Tile,RIGHT | CEILING,this.solveCollisionSlopeCeilLeft,CallbackFilter,Range);
               break;
            case SLOPE_CEIL_RIGHT:
               this.isSlope[Tile] = true;
               super.setTileProperties(Tile,LEFT | CEILING,this.solveCollisionSlopeCeilRight,CallbackFilter,Range);
               break;
            default:
               super.setTileProperties(Tile,AllowCollisions,Callback,CallbackFilter,Range);
         }
      }
      
      override public function overlapsWithCallback(Object:FlxObject, Callback:Function = null, FlipCallbackParams:Boolean = false, Position:FlxPoint = null) : Boolean
      {
         var column:uint = 0;
         var tile:FlxTile = null;
         var overlapFound:Boolean = false;
         var deltaX:Number = NaN;
         var deltaY:Number = NaN;
         var results:Boolean = false;
         var X:Number = x;
         var Y:Number = y;
         if(Position != null)
         {
            X = Position.x;
            Y = Position.y;
         }
         var selectionX:int = FlxU.floor((Object.x - X) / _tileWidth);
         var selectionY:int = FlxU.floor((Object.y - Y) / _tileHeight);
         var selectionWidth:uint = selectionX + FlxU.ceil(Object.width / _tileWidth) + 1;
         var selectionHeight:uint = selectionY + FlxU.ceil(Object.height / _tileHeight) + 1;
         if(selectionX < 0)
         {
            selectionX = 0;
         }
         if(selectionY < 0)
         {
            selectionY = 0;
         }
         if(selectionWidth > widthInTiles)
         {
            selectionWidth = widthInTiles;
         }
         if(selectionHeight > heightInTiles)
         {
            selectionHeight = heightInTiles;
         }
         var rowStart:uint = selectionY * widthInTiles;
         var row:uint = uint(selectionY);
         deltaX = X - last.x;
         deltaY = Y - last.y;
         while(row < selectionHeight)
         {
            column = uint(selectionX);
            while(column < selectionWidth)
            {
               overlapFound = false;
               tile = _tileObjects[_data[rowStart + column]] as FlxTile;
               if(Boolean(tile.allowCollisions))
               {
                  tile.x = X + column * _tileWidth;
                  tile.y = Y + row * _tileHeight;
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
                  if(overlapFound || Boolean(!overlapFound) && Boolean(this.isSlope[tile.index]))
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
            rowStart += widthInTiles;
            row++;
         }
         return results;
      }
      
      final private function fixSlopePoint(slope:FlxTile) : void
      {
         this._slopePoint.x = FlxU.bound(this._slopePoint.x,slope.x,slope.x + _tileWidth);
         this._slopePoint.y = FlxU.bound(this._slopePoint.y,slope.y,slope.y + _tileHeight);
      }
      
      protected function onCollideFloorSlope(slope:FlxTile, obj:FlxObject) : void
      {
         obj.touching |= FLOOR;
         obj.velocity.y = 0;
         obj.y = this._slopePoint.y - obj.height;
         if(obj.y < slope.y - obj.height)
         {
            obj.y = slope.y - obj.height;
         }
      }
      
      protected function onCollideCeilSlope(slope:FlxTile, obj:FlxObject) : void
      {
         obj.touching |= CEILING;
         obj.velocity.y = 0;
         obj.y = this._slopePoint.y;
         if(obj.y > slope.y + _tileHeight)
         {
            obj.y = slope.y + _tileHeight;
         }
      }
      
      final private function solveCollisionSlopeFloorLeft(slope:FlxTile, obj:FlxObject) : void
      {
         this._objPoint.x = FlxU.floor(obj.x + obj.width + this._snapping);
         this._objPoint.y = FlxU.floor(obj.y + obj.height);
         this._slopePoint.x = this._objPoint.x;
         this._slopePoint.y = slope.y + _tileHeight - (this._slopePoint.x - slope.x);
         this.fixSlopePoint(slope);
         if(this._objPoint.x > slope.x + this._snapping && this._objPoint.x < slope.x + _tileWidth + obj.width + this._snapping && this._objPoint.y >= this._slopePoint.y && this._objPoint.y <= slope.y + _tileHeight)
         {
            this.onCollideFloorSlope(slope,obj);
         }
      }
      
      final private function solveCollisionSlopeFloorRight(slope:FlxTile, obj:FlxObject) : void
      {
         this._objPoint.x = FlxU.floor(obj.x - this._snapping);
         this._objPoint.y = FlxU.floor(obj.y + obj.height);
         this._slopePoint.x = this._objPoint.x;
         this._slopePoint.y = slope.y + _tileHeight - (slope.x - this._slopePoint.x + _tileWidth);
         this.fixSlopePoint(slope);
         if(this._objPoint.x > slope.x - obj.width - this._snapping && this._objPoint.x < slope.x + _tileWidth + this._snapping && this._objPoint.y >= this._slopePoint.y && this._objPoint.y <= slope.y + _tileHeight)
         {
            this.onCollideFloorSlope(slope,obj);
         }
      }
      
      final private function solveCollisionSlopeCeilLeft(slope:FlxTile, obj:FlxObject) : void
      {
         this._objPoint.x = FlxU.floor(obj.x + obj.width + this._snapping);
         this._objPoint.y = FlxU.ceil(obj.y);
         this._slopePoint.x = this._objPoint.x;
         this._slopePoint.y = slope.y + (this._slopePoint.x - slope.x);
         this.fixSlopePoint(slope);
         if(this._objPoint.x > slope.x + this._snapping && this._objPoint.x < slope.x + _tileWidth + obj.width + this._snapping && this._objPoint.y <= this._slopePoint.y && this._objPoint.y >= slope.y)
         {
            this.onCollideCeilSlope(slope,obj);
         }
      }
      
      final private function solveCollisionSlopeCeilRight(slope:FlxTile, obj:FlxObject) : void
      {
         this._objPoint.x = FlxU.floor(obj.x - this._snapping);
         this._objPoint.y = FlxU.ceil(obj.y);
         this._slopePoint.x = this._objPoint.x;
         this._slopePoint.y = slope.y + (slope.x - this._slopePoint.x + _tileWidth);
         this.fixSlopePoint(slope);
         if(this._objPoint.x > slope.x - obj.width - this._snapping && this._objPoint.x < slope.x + _tileWidth + this._snapping && this._objPoint.y <= this._slopePoint.y && this._objPoint.y >= slope.y)
         {
            this.onCollideCeilSlope(slope,obj);
         }
      }
   }
}

