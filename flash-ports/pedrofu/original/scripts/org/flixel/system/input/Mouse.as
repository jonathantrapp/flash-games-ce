package org.flixel.system.input
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.flixel.FlxCamera;
   import org.flixel.FlxG;
   import org.flixel.FlxPoint;
   import org.flixel.system.replay.MouseRecord;
   
   public class Mouse extends FlxPoint
   {
      
      protected var ImgDefaultCursor:Class = Mouse_ImgDefaultCursor;
      
      public var wheel:int;
      
      public var screenX:int;
      
      public var screenY:int;
      
      protected var _current:int;
      
      protected var _last:int;
      
      protected var _cursorContainer:Sprite;
      
      protected var _cursor:Bitmap;
      
      protected var _lastX:int;
      
      protected var _lastY:int;
      
      protected var _lastWheel:int;
      
      protected var _point:FlxPoint;
      
      protected var _globalScreenPosition:FlxPoint;
      
      public function Mouse(CursorContainer:Sprite)
      {
         super();
         this._cursorContainer = CursorContainer;
         this._lastX = this.screenX = 0;
         this._lastY = this.screenY = 0;
         this._lastWheel = this.wheel = 0;
         this._current = 0;
         this._last = 0;
         this._cursor = null;
         this._point = new FlxPoint();
         this._globalScreenPosition = new FlxPoint();
      }
      
      public function destroy() : void
      {
         this._cursorContainer = null;
         this._cursor = null;
         this._point = null;
         this._globalScreenPosition = null;
      }
      
      public function show(Graphic:Class = null, Scale:Number = 1, XOffset:int = 0, YOffset:int = 0) : void
      {
         this._cursorContainer.visible = true;
         if(Graphic != null)
         {
            this.load(Graphic,Scale,XOffset,YOffset);
         }
         else if(this._cursor == null)
         {
            this.load();
         }
      }
      
      public function hide() : void
      {
         this._cursorContainer.visible = false;
      }
      
      public function get visible() : Boolean
      {
         return this._cursorContainer.visible;
      }
      
      public function load(Graphic:Class = null, Scale:Number = 1, XOffset:int = 0, YOffset:int = 0) : void
      {
         if(this._cursor != null)
         {
            this._cursorContainer.removeChild(this._cursor);
         }
         if(Graphic == null)
         {
            Graphic = this.ImgDefaultCursor;
         }
         this._cursor = new Graphic();
         this._cursor.x = XOffset;
         this._cursor.y = YOffset;
         this._cursor.scaleX = Scale;
         this._cursor.scaleY = Scale;
         this._cursorContainer.addChild(this._cursor);
      }
      
      public function unload() : void
      {
         if(this._cursor != null)
         {
            if(this._cursorContainer.visible)
            {
               this.load();
            }
            else
            {
               this._cursorContainer.removeChild(this._cursor);
               this._cursor = null;
            }
         }
      }
      
      public function update(X:int, Y:int) : void
      {
         this._globalScreenPosition.x = X;
         this._globalScreenPosition.y = Y;
         this.updateCursor();
         if(this._last == -1 && this._current == -1)
         {
            this._current = 0;
         }
         else if(this._last == 2 && this._current == 2)
         {
            this._current = 1;
         }
         this._last = this._current;
      }
      
      protected function updateCursor() : void
      {
         this._cursorContainer.x = this._globalScreenPosition.x;
         this._cursorContainer.y = this._globalScreenPosition.y;
         var camera:FlxCamera = FlxG.camera;
         this.screenX = (this._globalScreenPosition.x - camera.x) / camera.zoom;
         this.screenY = (this._globalScreenPosition.y - camera.y) / camera.zoom;
         x = this.screenX + camera.scroll.x;
         y = this.screenY + camera.scroll.y;
      }
      
      public function getWorldPosition(Camera:FlxCamera = null, Point:FlxPoint = null) : FlxPoint
      {
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         if(Point == null)
         {
            Point = new FlxPoint();
         }
         this.getScreenPosition(Camera,this._point);
         Point.x = this._point.x + Camera.scroll.x;
         Point.y = this._point.y + Camera.scroll.y;
         return Point;
      }
      
      public function getScreenPosition(Camera:FlxCamera = null, Point:FlxPoint = null) : FlxPoint
      {
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         if(Point == null)
         {
            Point = new FlxPoint();
         }
         Point.x = (this._globalScreenPosition.x - Camera.x) / Camera.zoom;
         Point.y = (this._globalScreenPosition.y - Camera.y) / Camera.zoom;
         return Point;
      }
      
      public function reset() : void
      {
         this._current = 0;
         this._last = 0;
      }
      
      public function pressed() : Boolean
      {
         return this._current > 0;
      }
      
      public function justPressed() : Boolean
      {
         return this._current == 2;
      }
      
      public function justReleased() : Boolean
      {
         return this._current == -1;
      }
      
      public function handleMouseDown(FlashEvent:MouseEvent) : void
      {
         if(this._current > 0)
         {
            this._current = 1;
         }
         else
         {
            this._current = 2;
         }
      }
      
      public function handleMouseUp(FlashEvent:MouseEvent) : void
      {
         if(this._current > 0)
         {
            this._current = -1;
         }
         else
         {
            this._current = 0;
         }
      }
      
      public function handleMouseWheel(FlashEvent:MouseEvent) : void
      {
         this.wheel = FlashEvent.delta;
      }
      
      public function record() : MouseRecord
      {
         if(this._lastX == this._globalScreenPosition.x && this._lastY == this._globalScreenPosition.y && this._current == 0 && this._lastWheel == this.wheel)
         {
            return null;
         }
         this._lastX = this._globalScreenPosition.x;
         this._lastY = this._globalScreenPosition.y;
         this._lastWheel = this.wheel;
         return new MouseRecord(this._lastX,this._lastY,this._current,this._lastWheel);
      }
      
      public function playback(Record:MouseRecord) : void
      {
         this._current = Record.button;
         this.wheel = Record.wheel;
         this._globalScreenPosition.x = Record.x;
         this._globalScreenPosition.y = Record.y;
         this.updateCursor();
      }
   }
}

