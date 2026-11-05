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
      
      override public function setTileProperties(param1:uint, param2:uint = 4369, param3:Function = null, param4:Class = null, param5:uint = 1) : void
      {
         switch(param2)
         {
            case SLOPE_FLOOR_LEFT:
               this.isSlope[param1] = true;
               super.setTileProperties(param1,RIGHT | FLOOR,this.solveCollisionSlopeFloorLeft,param4,param5);
               break;
            case SLOPE_FLOOR_RIGHT:
               this.isSlope[param1] = true;
               super.setTileProperties(param1,LEFT | FLOOR,this.solveCollisionSlopeFloorRight,param4,param5);
               break;
            case SLOPE_CEIL_LEFT:
               this.isSlope[param1] = true;
               super.setTileProperties(param1,RIGHT | CEILING,this.solveCollisionSlopeCeilLeft,param4,param5);
               break;
            case SLOPE_CEIL_RIGHT:
               this.isSlope[param1] = true;
               super.setTileProperties(param1,LEFT | CEILING,this.solveCollisionSlopeCeilRight,param4,param5);
               break;
            default:
               super.setTileProperties(param1,param2,param3,param4,param5);
         }
      }
      
      override public function overlapsWithCallback(param1:FlxObject, param2:Function = null, param3:Boolean = false, param4:FlxPoint = null) : Boolean
      {
         var _loc14_:uint = 0;
         var _loc15_:FlxTile = null;
         var _loc16_:Boolean = false;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc5_:Boolean = false;
         var _loc6_:Number = x;
         var _loc7_:Number = y;
         if(param4 != null)
         {
            _loc6_ = param4.x;
            _loc7_ = param4.y;
         }
         var _loc8_:int = FlxU.floor((param1.x - _loc6_) / _tileWidth);
         var _loc9_:int = FlxU.floor((param1.y - _loc7_) / _tileHeight);
         var _loc10_:uint = _loc8_ + FlxU.ceil(param1.width / _tileWidth) + 1;
         var _loc11_:uint = _loc9_ + FlxU.ceil(param1.height / _tileHeight) + 1;
         if(_loc8_ < 0)
         {
            _loc8_ = 0;
         }
         if(_loc9_ < 0)
         {
            _loc9_ = 0;
         }
         if(_loc10_ > widthInTiles)
         {
            _loc10_ = widthInTiles;
         }
         if(_loc11_ > heightInTiles)
         {
            _loc11_ = heightInTiles;
         }
         var _loc12_:uint = _loc9_ * widthInTiles;
         var _loc13_:uint = uint(_loc9_);
         _loc17_ = _loc6_ - last.x;
         _loc18_ = _loc7_ - last.y;
         while(_loc13_ < _loc11_)
         {
            _loc14_ = uint(_loc8_);
            while(_loc14_ < _loc10_)
            {
               _loc16_ = false;
               _loc15_ = _tileObjects[_data[_loc12_ + _loc14_]] as FlxTile;
               if(_loc15_.allowCollisions)
               {
                  _loc15_.x = _loc6_ + _loc14_ * _tileWidth;
                  _loc15_.y = _loc7_ + _loc13_ * _tileHeight;
                  _loc15_.last.x = _loc15_.x - _loc17_;
                  _loc15_.last.y = _loc15_.y - _loc18_;
                  if(param2 != null)
                  {
                     if(param3)
                     {
                        _loc16_ = param2(param1,_loc15_);
                     }
                     else
                     {
                        _loc16_ = param2(_loc15_,param1);
                     }
                  }
                  else
                  {
                     _loc16_ = param1.x + param1.width > _loc15_.x && param1.x < _loc15_.x + _loc15_.width && param1.y + param1.height > _loc15_.y && param1.y < _loc15_.y + _loc15_.height;
                  }
                  if(_loc16_ || Boolean(!_loc16_) && Boolean(this.isSlope[_loc15_.index]))
                  {
                     if(_loc15_.callback != null && (_loc15_.filter == null || param1 is _loc15_.filter))
                     {
                        _loc15_.mapIndex = _loc12_ + _loc14_;
                        _loc15_.callback(_loc15_,param1);
                     }
                     _loc5_ = true;
                  }
               }
               else if(_loc15_.callback != null && (_loc15_.filter == null || param1 is _loc15_.filter))
               {
                  _loc15_.mapIndex = _loc12_ + _loc14_;
                  _loc15_.callback(_loc15_,param1);
               }
               _loc14_++;
            }
            _loc12_ += widthInTiles;
            _loc13_++;
         }
         return _loc5_;
      }
      
      final private function fixSlopePoint(param1:FlxTile) : void
      {
         this._slopePoint.x = FlxU.bound(this._slopePoint.x,param1.x,param1.x + _tileWidth);
         this._slopePoint.y = FlxU.bound(this._slopePoint.y,param1.y,param1.y + _tileHeight);
      }
      
      protected function onCollideFloorSlope(param1:FlxTile, param2:FlxObject) : void
      {
         param2.touching = FLOOR;
         param2.velocity.y = 0;
         param2.y = this._slopePoint.y - param2.height;
         if(param2.y < param1.y - param2.height)
         {
            param2.y = param1.y - param2.height;
         }
      }
      
      protected function onCollideCeilSlope(param1:FlxTile, param2:FlxObject) : void
      {
         param2.touching = CEILING;
         param2.velocity.y = 0;
         param2.y = this._slopePoint.y;
         if(param2.y > param1.y + _tileHeight)
         {
            param2.y = param1.y + _tileHeight;
         }
      }
      
      final private function solveCollisionSlopeFloorLeft(param1:FlxTile, param2:FlxObject) : void
      {
         this._objPoint.x = FlxU.floor(param2.x + param2.width + this._snapping);
         this._objPoint.y = FlxU.floor(param2.y + param2.height);
         this._slopePoint.x = this._objPoint.x;
         this._slopePoint.y = param1.y + _tileHeight - (this._slopePoint.x - param1.x);
         this.fixSlopePoint(param1);
         if(this._objPoint.x > param1.x + this._snapping && this._objPoint.x < param1.x + _tileWidth + param2.width + this._snapping && this._objPoint.y >= this._slopePoint.y && this._objPoint.y <= param1.y + _tileHeight)
         {
            this.onCollideFloorSlope(param1,param2);
         }
      }
      
      final private function solveCollisionSlopeFloorRight(param1:FlxTile, param2:FlxObject) : void
      {
         this._objPoint.x = FlxU.floor(param2.x - this._snapping);
         this._objPoint.y = FlxU.floor(param2.y + param2.height);
         this._slopePoint.x = this._objPoint.x;
         this._slopePoint.y = param1.y + _tileHeight - (param1.x - this._slopePoint.x + _tileWidth);
         this.fixSlopePoint(param1);
         if(this._objPoint.x > param1.x - param2.width - this._snapping && this._objPoint.x < param1.x + _tileWidth + this._snapping && this._objPoint.y >= this._slopePoint.y && this._objPoint.y <= param1.y + _tileHeight)
         {
            this.onCollideFloorSlope(param1,param2);
         }
      }
      
      final private function solveCollisionSlopeCeilLeft(param1:FlxTile, param2:FlxObject) : void
      {
         this._objPoint.x = FlxU.floor(param2.x + param2.width + this._snapping);
         this._objPoint.y = FlxU.ceil(param2.y);
         this._slopePoint.x = this._objPoint.x;
         this._slopePoint.y = param1.y + (this._slopePoint.x - param1.x);
         this.fixSlopePoint(param1);
         if(this._objPoint.x > param1.x + this._snapping && this._objPoint.x < param1.x + _tileWidth + param2.width + this._snapping && this._objPoint.y <= this._slopePoint.y && this._objPoint.y >= param1.y)
         {
            this.onCollideCeilSlope(param1,param2);
         }
      }
      
      final private function solveCollisionSlopeCeilRight(param1:FlxTile, param2:FlxObject) : void
      {
         this._objPoint.x = FlxU.floor(param2.x - this._snapping);
         this._objPoint.y = FlxU.ceil(param2.y);
         this._slopePoint.x = this._objPoint.x;
         this._slopePoint.y = param1.y + (param1.x - this._slopePoint.x + _tileWidth);
         this.fixSlopePoint(param1);
         if(this._objPoint.x > param1.x - param2.width - this._snapping && this._objPoint.x < param1.x + _tileWidth + this._snapping && this._objPoint.y <= this._slopePoint.y && this._objPoint.y >= param1.y)
         {
            this.onCollideCeilSlope(param1,param2);
         }
      }
   }
}

