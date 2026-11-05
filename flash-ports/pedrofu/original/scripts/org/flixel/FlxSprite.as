package org.flixel
{
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.flixel.system.FlxAnim;
   
   public class FlxSprite extends FlxObject
   {
      
      protected var ImgDefault:Class = FlxSprite_ImgDefault;
      
      public var origin:FlxPoint;
      
      public var offset:FlxPoint;
      
      public var scale:FlxPoint;
      
      public var blend:String;
      
      public var antialiasing:Boolean;
      
      public var finished:Boolean;
      
      public var frameWidth:uint;
      
      public var frameHeight:uint;
      
      public var frames:uint;
      
      public var framePixels:BitmapData;
      
      public var dirty:Boolean;
      
      protected var _animations:Array;
      
      protected var _flipped:uint;
      
      protected var _curAnim:FlxAnim;
      
      protected var _curFrame:uint;
      
      protected var _curIndex:uint;
      
      protected var _frameTimer:Number;
      
      protected var _callback:Function;
      
      protected var _facing:uint;
      
      protected var _alpha:Number;
      
      protected var _color:uint;
      
      protected var _bakedRotation:Number;
      
      protected var _pixels:BitmapData;
      
      protected var _flashPoint:Point;
      
      protected var _flashRect:Rectangle;
      
      protected var _flashRect2:Rectangle;
      
      protected var _flashPointZero:Point;
      
      protected var _colorTransform:ColorTransform;
      
      protected var _matrix:Matrix;
      
      public var clip:Rectangle;
      
      public function FlxSprite(X:Number = 0, Y:Number = 0, SimpleGraphic:Class = null)
      {
         super(X,Y);
         health = 1;
         this.clip = null;
         this._flashPoint = new Point();
         this._flashRect = new Rectangle();
         this._flashRect2 = new Rectangle();
         this._flashPointZero = new Point();
         this.offset = new FlxPoint();
         this.origin = new FlxPoint();
         this.scale = new FlxPoint(1,1);
         this._alpha = 1;
         this._color = 16777215;
         this.blend = null;
         this.antialiasing = false;
         cameras = null;
         this.finished = false;
         this._facing = RIGHT;
         this._animations = new Array();
         this._flipped = 0;
         this._curAnim = null;
         this._curFrame = 0;
         this._curIndex = 0;
         this._frameTimer = 0;
         this._matrix = new Matrix();
         this._callback = null;
         if(SimpleGraphic == null)
         {
            SimpleGraphic = this.ImgDefault;
         }
         this.loadGraphic(SimpleGraphic);
      }
      
      override public function destroy() : void
      {
         var a:FlxAnim = null;
         var i:uint = 0;
         var l:uint = 0;
         if(this._animations != null)
         {
            i = 0;
            l = this._animations.length;
            while(i < l)
            {
               a = this._animations[i++];
               if(a != null)
               {
                  a.destroy();
               }
            }
            this._animations = null;
         }
         this._flashPoint = null;
         this._flashRect = null;
         this._flashRect2 = null;
         this._flashPointZero = null;
         this.offset = null;
         this.origin = null;
         this.scale = null;
         this._curAnim = null;
         this._matrix = null;
         this._callback = null;
         this.framePixels = null;
      }
      
      public function loadGraphic(Graphic:Class, Animated:Boolean = false, Reverse:Boolean = false, Width:uint = 0, Height:uint = 0, Unique:Boolean = false) : FlxSprite
      {
         this._bakedRotation = 0;
         this._pixels = FlxG.addBitmap(Graphic,Reverse,Unique);
         if(Reverse)
         {
            this._flipped = this._pixels.width >> 1;
         }
         else
         {
            this._flipped = 0;
         }
         if(Width == 0)
         {
            if(Animated)
            {
               Width = uint(this._pixels.height);
            }
            else if(this._flipped > 0)
            {
               Width = this._pixels.width * 0.5;
            }
            else
            {
               Width = uint(this._pixels.width);
            }
         }
         width = this.frameWidth = Width;
         if(Height == 0)
         {
            if(Animated)
            {
               Height = width;
            }
            else
            {
               Height = uint(this._pixels.height);
            }
         }
         height = this.frameHeight = Height;
         this.resetHelpers();
         return this;
      }
      
      public function loadRotatedGraphic(Graphic:Class, Rotations:uint = 16, Frame:int = -1, AntiAliasing:Boolean = false, AutoBuffer:Boolean = false) : FlxSprite
      {
         var full:BitmapData = null;
         var rx:uint = 0;
         var ry:uint = 0;
         var fw:uint = 0;
         var row:uint = 0;
         var column:uint = 0;
         var bakedAngle:Number = NaN;
         var halfBrushWidth:uint = 0;
         var halfBrushHeight:uint = 0;
         var midpointX:uint = 0;
         var midpointY:uint = 0;
         var rows:uint = Math.sqrt(Rotations);
         var brush:BitmapData = FlxG.addBitmap(Graphic);
         if(Frame >= 0)
         {
            full = brush;
            brush = new BitmapData(full.height,full.height);
            rx = Frame * brush.width;
            ry = 0;
            fw = uint(full.width);
            if(rx >= fw)
            {
               ry = uint(rx / fw) * brush.height;
               rx %= fw;
            }
            this._flashRect.x = rx;
            this._flashRect.y = ry;
            this._flashRect.width = brush.width;
            this._flashRect.height = brush.height;
            brush.copyPixels(full,this._flashRect,this._flashPointZero);
         }
         var max:uint = uint(brush.width);
         if(brush.height > max)
         {
            max = uint(brush.height);
         }
         if(AutoBuffer)
         {
            max *= 1.5;
         }
         var columns:uint = FlxU.ceil(Rotations / rows);
         width = max * columns;
         height = max * rows;
         var key:String = String(Graphic) + ":" + Frame + ":" + width + "x" + height;
         var skipGen:Boolean = FlxG.checkBitmapCache(key);
         this._pixels = FlxG.createBitmap(width,height,0,true,key);
         width = this.frameWidth = this._pixels.width;
         height = this.frameHeight = this._pixels.height;
         this._bakedRotation = 360 / Rotations;
         if(!skipGen)
         {
            row = 0;
            bakedAngle = 0;
            halfBrushWidth = brush.width * 0.5;
            halfBrushHeight = brush.height * 0.5;
            midpointX = max * 0.5;
            midpointY = max * 0.5;
            while(row < rows)
            {
               column = 0;
               while(column < columns)
               {
                  this._matrix.identity();
                  this._matrix.translate(-halfBrushWidth,-halfBrushHeight);
                  this._matrix.rotate(bakedAngle * 0.017453293);
                  this._matrix.translate(max * column + midpointX,midpointY);
                  bakedAngle += this._bakedRotation;
                  this._pixels.draw(brush,this._matrix,null,null,null,AntiAliasing);
                  column++;
               }
               midpointY += max;
               row++;
            }
         }
         this.frameWidth = this.frameHeight = width = height = max;
         this.resetHelpers();
         if(AutoBuffer)
         {
            width = brush.width;
            height = brush.height;
            this.centerOffsets();
         }
         return this;
      }
      
      public function makeGraphic(Width:uint, Height:uint, Color:uint = 4294967295, Unique:Boolean = false, Key:String = null) : FlxSprite
      {
         this._bakedRotation = 0;
         this._pixels = FlxG.createBitmap(Width,Height,Color,Unique,Key);
         width = this.frameWidth = this._pixels.width;
         height = this.frameHeight = this._pixels.height;
         this.resetHelpers();
         return this;
      }
      
      protected function resetHelpers() : void
      {
         this._flashRect.x = 0;
         this._flashRect.y = 0;
         this._flashRect.width = this.frameWidth;
         this._flashRect.height = this.frameHeight;
         this._flashRect2.x = 0;
         this._flashRect2.y = 0;
         this._flashRect2.width = this._pixels.width;
         this._flashRect2.height = this._pixels.height;
         if(this.framePixels == null || this.framePixels.width != width || this.framePixels.height != height)
         {
            this.framePixels = new BitmapData(width,height);
         }
         this.origin.make(this.frameWidth * 0.5,this.frameHeight * 0.5);
         this.framePixels.copyPixels(this._pixels,this._flashRect,this._flashPointZero);
         this.frames = this._flashRect2.width / this._flashRect.width * (this._flashRect2.height / this._flashRect.height);
         if(this._colorTransform != null)
         {
            this.framePixels.colorTransform(this._flashRect,this._colorTransform);
         }
         this._curIndex = 0;
      }
      
      override public function postUpdate() : void
      {
         super.postUpdate();
         this.updateAnimation();
      }
      
      override public function draw() : void
      {
         var camera:FlxCamera = null;
         if(_flickerTimer != 0)
         {
            _flicker = !_flicker;
            if(_flicker)
            {
               return;
            }
         }
         if(this.dirty)
         {
            this.calcFrame();
         }
         if(cameras == null)
         {
            cameras = FlxG.cameras;
         }
         var i:uint = 0;
         var l:uint = cameras.length;
         while(i < l)
         {
            camera = cameras[i++];
            if(this.onScreen(camera))
            {
               _point.x = x - int(camera.scroll.x * scrollFactor.x) - this.offset.x;
               _point.y = y - int(camera.scroll.y * scrollFactor.y) - this.offset.y;
               _point.x += _point.x > 0 ? 1e-7 : -1e-7;
               _point.y += _point.y > 0 ? 1e-7 : -1e-7;
               if((angle == 0 || this._bakedRotation > 0) && this.scale.x == 1 && this.scale.y == 1 && this.blend == null && this._colorTransform == null)
               {
                  this._flashPoint.x = _point.x;
                  this._flashPoint.y = _point.y;
                  if(this.clip != null)
                  {
                     camera.buffer.copyPixels(this.framePixels,this.clip,this._flashPoint,null,null,true);
                  }
                  else
                  {
                     camera.buffer.copyPixels(this.framePixels,this._flashRect,this._flashPoint,null,null,true);
                  }
               }
               else
               {
                  this._matrix.identity();
                  this._matrix.translate(-this.origin.x,-this.origin.y);
                  this._matrix.scale(this.scale.x,this.scale.y);
                  if(angle != 0 && this._bakedRotation <= 0)
                  {
                     this._matrix.rotate(angle * 0.017453293);
                  }
                  this._matrix.translate(_point.x + this.origin.x,_point.y + this.origin.y);
                  camera.buffer.draw(this.framePixels,this._matrix,this._colorTransform,this.blend,this.clip,this.antialiasing);
               }
               ++_VISIBLECOUNT;
               if(FlxG.visualDebug && !ignoreDrawDebug)
               {
                  drawDebug(camera);
               }
            }
         }
      }
      
      public function stamp(Brush:FlxSprite, X:int = 0, Y:int = 0) : void
      {
         Brush.drawFrame();
         var bitmapData:BitmapData = Brush.framePixels;
         if((Brush.angle == 0 || Brush._bakedRotation > 0) && Brush.scale.x == 1 && Brush.scale.y == 1 && Brush.blend == null)
         {
            this._flashPoint.x = X;
            this._flashPoint.y = Y;
            this._flashRect2.width = bitmapData.width;
            this._flashRect2.height = bitmapData.height;
            this._pixels.copyPixels(bitmapData,this._flashRect2,this._flashPoint,null,null,true);
            this._flashRect2.width = this._pixels.width;
            this._flashRect2.height = this._pixels.height;
            this.calcFrame();
            return;
         }
         this._matrix.identity();
         this._matrix.translate(-Brush.origin.x,-Brush.origin.y);
         this._matrix.scale(Brush.scale.x,Brush.scale.y);
         if(Brush.angle != 0)
         {
            this._matrix.rotate(Brush.angle * 0.017453293);
         }
         this._matrix.translate(X + Brush.origin.x,Y + Brush.origin.y);
         this._pixels.draw(bitmapData,this._matrix,null,Brush.blend,this.clip,Brush.antialiasing);
         this.calcFrame();
      }
      
      public function drawLine(StartX:Number, StartY:Number, EndX:Number, EndY:Number, Color:uint, Thickness:uint = 1) : void
      {
         var gfx:Graphics = FlxG.flashGfx;
         gfx.clear();
         gfx.moveTo(StartX,StartY);
         var alphaComponent:Number = Number(Color >> 24 & 0xFF) / 255;
         if(alphaComponent <= 0)
         {
            alphaComponent = 1;
         }
         gfx.lineStyle(Thickness,Color,alphaComponent);
         gfx.lineTo(EndX,EndY);
         this._pixels.draw(FlxG.flashGfxSprite);
         this.dirty = true;
      }
      
      public function fill(Color:uint) : void
      {
         this._pixels.fillRect(this._flashRect2,Color);
         if(this._pixels != this.framePixels)
         {
            this.dirty = true;
         }
      }
      
      public function GetAnimFrame() : int
      {
         return this._curFrame;
      }
      
      protected function updateAnimation() : void
      {
         var oldIndex:uint = 0;
         var angleHelper:int = 0;
         if(this._bakedRotation > 0)
         {
            oldIndex = this._curIndex;
            angleHelper = angle % 360;
            if(angleHelper < 0)
            {
               angleHelper += 360;
            }
            this._curIndex = angleHelper / this._bakedRotation + 0.5;
            if(oldIndex != this._curIndex)
            {
               this.dirty = true;
            }
         }
         else if(this._curAnim != null && this._curAnim.delay > 0 && (this._curAnim.looped || !this.finished))
         {
            this._frameTimer += FlxG.elapsed;
            while(this._frameTimer > this._curAnim.delay)
            {
               this._frameTimer -= this._curAnim.delay;
               if(this._curFrame == this._curAnim.frames.length - 1)
               {
                  if(this._curAnim.looped)
                  {
                     this._curFrame = 0;
                  }
                  this.finished = true;
               }
               else
               {
                  ++this._curFrame;
               }
               this._curIndex = this._curAnim.frames[this._curFrame];
               this.dirty = true;
            }
         }
         if(this.dirty)
         {
            this.calcFrame();
         }
      }
      
      public function drawFrame(Force:Boolean = false) : void
      {
         if(Force || this.dirty)
         {
            this.calcFrame();
         }
      }
      
      public function addAnimation(Name:String, Frames:Array, FrameRate:Number = 0, Looped:Boolean = true) : void
      {
         this._animations.push(new FlxAnim(Name,Frames,FrameRate,Looped));
      }
      
      public function addAnimationCallback(AnimationCallback:Function) : void
      {
         this._callback = AnimationCallback;
      }
      
      public function play(AnimName:String, Force:Boolean = false) : void
      {
         if(!Force && this._curAnim != null && AnimName == this._curAnim.name && (this._curAnim.looped || !this.finished))
         {
            return;
         }
         this._curFrame = 0;
         this._curIndex = 0;
         this._frameTimer = 0;
         var i:uint = 0;
         var l:uint = this._animations.length;
         while(i < l)
         {
            if(this._animations[i].name == AnimName)
            {
               this._curAnim = this._animations[i];
               if(this._curAnim.delay <= 0)
               {
                  this.finished = true;
               }
               else
               {
                  this.finished = false;
               }
               this._curIndex = this._curAnim.frames[this._curFrame];
               this.dirty = true;
               return;
            }
            i++;
         }
         FlxG.log("WARNING: No animation called \"" + AnimName + "\"");
      }
      
      public function randomFrame() : void
      {
         this._curAnim = null;
         this._curIndex = int(FlxG.random() * (this._pixels.width / this.frameWidth));
         this.dirty = true;
      }
      
      public function setOriginToCorner() : void
      {
         this.origin.x = this.origin.y = 0;
      }
      
      public function centerOffsets(AdjustPosition:Boolean = false) : void
      {
         this.offset.x = (this.frameWidth - width) * 0.5;
         this.offset.y = (this.frameHeight - height) * 0.5;
         if(AdjustPosition)
         {
            x += this.offset.x;
            y += this.offset.y;
         }
      }
      
      public function replaceColor(Color:uint, NewColor:uint, FetchPositions:Boolean = false) : Array
      {
         var column:uint = 0;
         var positions:Array = null;
         if(FetchPositions)
         {
            positions = new Array();
         }
         var row:uint = 0;
         var rows:uint = uint(this._pixels.height);
         var columns:uint = uint(this._pixels.width);
         while(row < rows)
         {
            column = 0;
            while(column < columns)
            {
               if(this._pixels.getPixel32(column,row) == Color)
               {
                  this._pixels.setPixel32(column,row,NewColor);
                  if(FetchPositions)
                  {
                     positions.push(new FlxPoint(column,row));
                  }
                  this.dirty = true;
               }
               column++;
            }
            row++;
         }
         return positions;
      }
      
      public function get pixels() : BitmapData
      {
         return this._pixels;
      }
      
      public function set pixels(Pixels:BitmapData) : void
      {
         this._pixels = Pixels;
         width = this.frameWidth = this._pixels.width;
         height = this.frameHeight = this._pixels.height;
         this.resetHelpers();
      }
      
      public function get facing() : uint
      {
         return this._facing;
      }
      
      public function set facing(Direction:uint) : void
      {
         if(this._facing != Direction)
         {
            this.dirty = true;
         }
         this._facing = Direction;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(Alpha:Number) : void
      {
         if(Alpha > 1)
         {
            Alpha = 1;
         }
         if(Alpha < 0)
         {
            Alpha = 0;
         }
         if(Alpha == this._alpha)
         {
            return;
         }
         this._alpha = Alpha;
         if(this._alpha != 1 || this._color != 16777215)
         {
            this._colorTransform = new ColorTransform((this._color >> 16) * 0.00392,(this._color >> 8 & 0xFF) * 0.00392,(this._color & 0xFF) * 0.00392,this._alpha);
         }
         else
         {
            this._colorTransform = null;
         }
         this.dirty = true;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(Color:uint) : void
      {
         Color &= 16777215;
         if(this._color == Color)
         {
            return;
         }
         this._color = Color;
         if(this._alpha != 1 || this._color != 16777215)
         {
            this._colorTransform = new ColorTransform((this._color >> 16) * 0.0039216,(this._color >> 8 & 0xFF) * 0.0039216,(this._color & 0xFF) * 0.0039216,this._alpha);
         }
         else
         {
            this._colorTransform = null;
         }
         this.dirty = true;
      }
      
      public function get frame() : uint
      {
         return this._curIndex;
      }
      
      public function set frame(Frame:uint) : void
      {
         this._curAnim = null;
         this._curIndex = Frame;
         this.dirty = true;
      }
      
      override public function onScreen(Camera:FlxCamera = null) : Boolean
      {
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         getScreenXY(_point,Camera);
         _point.x -= this.offset.x;
         _point.y -= this.offset.y;
         if((angle == 0 || this._bakedRotation > 0) && this.scale.x == 1 && this.scale.y == 1)
         {
            return _point.x + this.frameWidth > 0 && _point.x < Camera.width && _point.y + this.frameHeight > 0 && _point.y < Camera.height;
         }
         var halfWidth:Number = this.frameWidth / 2;
         var halfHeight:Number = this.frameHeight / 2;
         var absScaleX:Number = this.scale.x > 0 ? this.scale.x : -this.scale.x;
         var absScaleY:Number = this.scale.y > 0 ? this.scale.y : -this.scale.y;
         var radius:Number = Math.sqrt(halfWidth * halfWidth + halfHeight * halfHeight) * (absScaleX >= absScaleY ? absScaleX : absScaleY);
         _point.x += halfWidth;
         _point.y += halfHeight;
         return _point.x + radius > 0 && _point.x - radius < Camera.width && _point.y + radius > 0 && _point.y - radius < Camera.height;
      }
      
      public function pixelsOverlapPoint(Point:FlxPoint, Mask:uint = 255, Camera:FlxCamera = null) : Boolean
      {
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         getScreenXY(_point,Camera);
         _point.x -= this.offset.x;
         _point.y -= this.offset.y;
         this._flashPoint.x = Point.x - Camera.scroll.x - _point.x;
         this._flashPoint.y = Point.y - Camera.scroll.y - _point.y;
         return this.framePixels.hitTest(this._flashPointZero,Mask,this._flashPoint);
      }
      
      protected function calcFrame() : void
      {
         var indexX:uint = this._curIndex * this.frameWidth;
         var indexY:uint = 0;
         var widthHelper:uint = Boolean(this._flipped) ? this._flipped : uint(this._pixels.width);
         if(indexX >= widthHelper)
         {
            indexY = uint(indexX / widthHelper) * this.frameHeight;
            indexX %= widthHelper;
         }
         if(Boolean(this._flipped) && this._facing == LEFT)
         {
            indexX = (this._flipped << 1) - indexX - this.frameWidth;
         }
         this._flashRect.x = indexX;
         this._flashRect.y = indexY;
         this.framePixels.copyPixels(this._pixels,this._flashRect,this._flashPointZero);
         this._flashRect.x = this._flashRect.y = 0;
         if(this._colorTransform != null)
         {
            this.framePixels.colorTransform(this._flashRect,this._colorTransform);
         }
         if(this._callback != null)
         {
            this._callback(this._curAnim != null ? this._curAnim.name : null,this._curFrame,this._curIndex);
         }
         this.dirty = false;
      }
   }
}

