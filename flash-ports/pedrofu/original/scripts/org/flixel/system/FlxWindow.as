package org.flixel.system
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import org.flixel.FlxU;
   
   public class FlxWindow extends Sprite
   {
      
      protected var ImgHandle:Class = FlxWindow_ImgHandle;
      
      public var minSize:Point;
      
      public var maxSize:Point;
      
      protected var _width:uint;
      
      protected var _height:uint;
      
      protected var _bounds:Rectangle;
      
      protected var _background:Bitmap;
      
      protected var _header:Bitmap;
      
      protected var _shadow:Bitmap;
      
      protected var _title:TextField;
      
      protected var _handle:Bitmap;
      
      protected var _overHeader:Boolean;
      
      protected var _overHandle:Boolean;
      
      protected var _drag:Point;
      
      protected var _dragging:Boolean;
      
      protected var _resizing:Boolean;
      
      protected var _resizable:Boolean;
      
      public function FlxWindow(Title:String, Width:Number, Height:Number, Resizable:Boolean = true, Bounds:Rectangle = null, BGColor:uint = 2139062143, TopColor:uint = 2130706432)
      {
         super();
         this._width = Width;
         this._height = Height;
         this._bounds = Bounds;
         this.minSize = new Point(50,30);
         if(this._bounds != null)
         {
            this.maxSize = new Point(this._bounds.width,this._bounds.height);
         }
         else
         {
            this.maxSize = new Point(Number.MAX_VALUE,Number.MAX_VALUE);
         }
         this._drag = new Point();
         this._resizable = Resizable;
         this._shadow = new Bitmap(new BitmapData(1,2,true,4278190080));
         addChild(this._shadow);
         this._background = new Bitmap(new BitmapData(1,1,true,BGColor));
         this._background.y = 15;
         addChild(this._background);
         this._header = new Bitmap(new BitmapData(1,15,true,TopColor));
         addChild(this._header);
         this._title = new TextField();
         this._title.x = 2;
         this._title.height = 16;
         this._title.selectable = false;
         this._title.multiline = false;
         this._title.defaultTextFormat = new TextFormat("Courier",12,16777215);
         this._title.text = Title;
         addChild(this._title);
         if(this._resizable)
         {
            this._handle = new this.ImgHandle();
            addChild(this._handle);
         }
         if(this._width != 0 || this._height != 0)
         {
            this.updateSize();
         }
         this.bound();
         addEventListener(Event.ENTER_FRAME,this.init);
      }
      
      public function destroy() : void
      {
         this.minSize = null;
         this.maxSize = null;
         this._bounds = null;
         removeChild(this._shadow);
         this._shadow = null;
         removeChild(this._background);
         this._background = null;
         removeChild(this._header);
         this._header = null;
         removeChild(this._title);
         this._title = null;
         if(this._handle != null)
         {
            removeChild(this._handle);
         }
         this._handle = null;
         this._drag = null;
      }
      
      public function resize(Width:Number, Height:Number) : void
      {
         this._width = Width;
         this._height = Height;
         this.updateSize();
      }
      
      public function reposition(X:Number, Y:Number) : void
      {
         x = X;
         y = Y;
         this.bound();
      }
      
      protected function init(E:Event = null) : void
      {
         if(root == null)
         {
            return;
         }
         removeEventListener(Event.ENTER_FRAME,this.init);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      protected function onMouseMove(E:MouseEvent = null) : void
      {
         if(this._dragging)
         {
            this._overHeader = true;
            this.reposition(parent.mouseX - this._drag.x,parent.mouseY - this._drag.y);
         }
         else if(this._resizing)
         {
            this._overHandle = true;
            this.resize(mouseX - this._drag.x,mouseY - this._drag.y);
         }
         else if(mouseX >= 0 && mouseX <= this._width && mouseY >= 0 && mouseY <= this._height)
         {
            this._overHeader = mouseX <= this._header.width && mouseY <= this._header.height;
            if(this._resizable)
            {
               this._overHandle = mouseX >= this._width - this._handle.width && mouseY >= this._height - this._handle.height;
            }
         }
         else
         {
            this._overHandle = this._overHeader = false;
         }
         this.updateGUI();
      }
      
      protected function onMouseDown(E:MouseEvent = null) : void
      {
         if(this._overHeader)
         {
            this._dragging = true;
            this._drag.x = mouseX;
            this._drag.y = mouseY;
         }
         else if(this._overHandle)
         {
            this._resizing = true;
            this._drag.x = this._width - mouseX;
            this._drag.y = this._height - mouseY;
         }
      }
      
      protected function onMouseUp(E:MouseEvent = null) : void
      {
         this._dragging = false;
         this._resizing = false;
      }
      
      protected function bound() : void
      {
         if(this._bounds != null)
         {
            x = FlxU.bound(x,this._bounds.left,this._bounds.right - this._width);
            y = FlxU.bound(y,this._bounds.top,this._bounds.bottom - this._height);
         }
      }
      
      protected function updateSize() : void
      {
         this._width = FlxU.bound(this._width,this.minSize.x,this.maxSize.x);
         this._height = FlxU.bound(this._height,this.minSize.y,this.maxSize.y);
         this._header.scaleX = this._width;
         this._background.scaleX = this._width;
         this._background.scaleY = this._height - 15;
         this._shadow.scaleX = this._width;
         this._shadow.y = this._height;
         this._title.width = this._width - 4;
         if(this._resizable)
         {
            this._handle.x = this._width - this._handle.width;
            this._handle.y = this._height - this._handle.height;
         }
      }
      
      protected function updateGUI() : void
      {
         if(this._overHeader || this._overHandle)
         {
            if(this._title.alpha != 1)
            {
               this._title.alpha = 1;
            }
         }
         else if(this._title.alpha != 0.65)
         {
            this._title.alpha = 0.65;
         }
      }
   }
}

