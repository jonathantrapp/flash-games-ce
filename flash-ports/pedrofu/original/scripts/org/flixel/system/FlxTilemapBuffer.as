package org.flixel.system
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.flixel.FlxCamera;
   import org.flixel.FlxG;
   import org.flixel.FlxU;
   
   public class FlxTilemapBuffer
   {
      
      public var x:Number;
      
      public var y:Number;
      
      public var width:Number;
      
      public var height:Number;
      
      public var dirty:Boolean;
      
      public var rows:uint;
      
      public var columns:uint;
      
      protected var _pixels:BitmapData;
      
      protected var _flashRect:Rectangle;
      
      public function FlxTilemapBuffer(TileWidth:Number, TileHeight:Number, WidthInTiles:uint, HeightInTiles:uint, Camera:FlxCamera = null)
      {
         super();
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         this.columns = FlxU.ceil(Camera.width / TileWidth) + 1;
         if(this.columns > WidthInTiles)
         {
            this.columns = WidthInTiles;
         }
         this.rows = FlxU.ceil(Camera.height / TileHeight) + 1;
         if(this.rows > HeightInTiles)
         {
            this.rows = HeightInTiles;
         }
         this._pixels = new BitmapData(this.columns * TileWidth,this.rows * TileHeight,true,0);
         this.width = this._pixels.width;
         this.height = this._pixels.height;
         this._flashRect = new Rectangle(0,0,this.width,this.height);
         this.dirty = true;
      }
      
      public function destroy() : void
      {
         this._pixels = null;
      }
      
      public function fill(Color:uint = 0) : void
      {
         this._pixels.fillRect(this._flashRect,Color);
      }
      
      public function get pixels() : BitmapData
      {
         return this._pixels;
      }
      
      public function draw(Camera:FlxCamera, FlashPoint:Point) : void
      {
         Camera.buffer.copyPixels(this._pixels,this._flashRect,FlashPoint,null,null,true);
      }
   }
}

