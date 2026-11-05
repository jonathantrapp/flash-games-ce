package org.flixel
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class FlxCamera extends FlxBasic
   {
      
      public static var defaultZoom:Number;
      
      public static const STYLE_LOCKON:uint = 0;
      
      public static const STYLE_PLATFORMER:uint = 1;
      
      public static const STYLE_TOPDOWN:uint = 2;
      
      public static const STYLE_TOPDOWN_TIGHT:uint = 3;
      
      public static const SHAKE_BOTH_AXES:uint = 0;
      
      public static const SHAKE_HORIZONTAL_ONLY:uint = 1;
      
      public static const SHAKE_VERTICAL_ONLY:uint = 2;
      
      public var x:Number;
      
      public var y:Number;
      
      public var width:uint;
      
      public var height:uint;
      
      public var target:FlxObject;
      
      public var deadzone:FlxRect;
      
      public var bounds:FlxRect;
      
      public var scroll:FlxPoint;
      
      public var buffer:BitmapData;
      
      public var bgColor:uint;
      
      public var screen:FlxSprite;
      
      protected var _zoom:Number;
      
      protected var _point:FlxPoint;
      
      protected var _color:uint;
      
      protected var _flashBitmap:Bitmap;
      
      internal var _flashSprite:Sprite;
      
      internal var _flashOffsetX:Number;
      
      internal var _flashOffsetY:Number;
      
      protected var _flashRect:Rectangle;
      
      protected var _flashPoint:Point;
      
      protected var _fxFlashColor:uint;
      
      protected var _fxFlashDuration:Number;
      
      protected var _fxFlashComplete:Function;
      
      protected var _fxFlashAlpha:Number;
      
      protected var _fxFadeColor:uint;
      
      protected var _fxFadeDuration:Number;
      
      protected var _fxFadeComplete:Function;
      
      protected var _fxFadeAlpha:Number;
      
      protected var _fxShakeIntensity:Number;
      
      protected var _fxShakeDuration:Number;
      
      protected var _fxShakeComplete:Function;
      
      protected var _fxShakeOffset:FlxPoint;
      
      protected var _fxShakeDirection:uint;
      
      protected var _fill:BitmapData;
      
      public function FlxCamera(X:int, Y:int, Width:int, Height:int, Zoom:Number = 0)
      {
         super();
         this.x = X;
         this.y = Y;
         this.width = Width;
         this.height = Height;
         this.target = null;
         this.deadzone = null;
         this.scroll = new FlxPoint();
         this._point = new FlxPoint();
         this.bounds = null;
         this.screen = new FlxSprite();
         this.screen.makeGraphic(this.width,this.height,0,true);
         this.screen.setOriginToCorner();
         this.buffer = this.screen.pixels;
         this.bgColor = FlxG.bgColor;
         this._color = 16777215;
         this._flashBitmap = new Bitmap(this.buffer);
         this._flashBitmap.x = -this.width * 0.5;
         this._flashBitmap.y = -this.height * 0.5;
         this._flashSprite = new Sprite();
         this.zoom = Zoom;
         this._flashOffsetX = this.width * 0.5 * this.zoom;
         this._flashOffsetY = this.height * 0.5 * this.zoom;
         this._flashSprite.x = this.x + this._flashOffsetX;
         this._flashSprite.y = this.y + this._flashOffsetY;
         this._flashSprite.addChild(this._flashBitmap);
         this._flashRect = new Rectangle(0,0,this.width,this.height);
         this._flashPoint = new Point();
         this._fxFlashColor = 0;
         this._fxFlashDuration = 0;
         this._fxFlashComplete = null;
         this._fxFlashAlpha = 0;
         this._fxFadeColor = 0;
         this._fxFadeDuration = 0;
         this._fxFadeComplete = null;
         this._fxFadeAlpha = 0;
         this._fxShakeIntensity = 0;
         this._fxShakeDuration = 0;
         this._fxShakeComplete = null;
         this._fxShakeOffset = new FlxPoint();
         this._fxShakeDirection = 0;
         this._fill = new BitmapData(this.width,this.height,true,0);
      }
      
      override public function destroy() : void
      {
         this.screen.destroy();
         this.screen = null;
         this.target = null;
         this.scroll = null;
         this.deadzone = null;
         this.bounds = null;
         this.buffer = null;
         this._flashBitmap = null;
         this._flashRect = null;
         this._flashPoint = null;
         this._fxFlashComplete = null;
         this._fxFadeComplete = null;
         this._fxShakeComplete = null;
         this._fxShakeOffset = null;
         this._fill = null;
      }
      
      override public function update() : void
      {
         var edge:Number = NaN;
         var targetX:Number = NaN;
         var targetY:Number = NaN;
         if(this.target != null)
         {
            if(this.deadzone == null)
            {
               this.focusOn(this.target.getMidpoint(this._point));
            }
            else
            {
               targetX = this.target.x + (this.target.x > 0 ? 1e-7 : -1e-7);
               targetY = this.target.y + (this.target.y > 0 ? 1e-7 : -1e-7);
               edge = targetX - this.deadzone.x;
               if(this.scroll.x > edge)
               {
                  this.scroll.x = edge;
               }
               edge = targetX + this.target.width - this.deadzone.x - this.deadzone.width;
               if(this.scroll.x < edge)
               {
                  this.scroll.x = edge;
               }
               edge = targetY - this.deadzone.y;
               if(this.scroll.y > edge)
               {
                  this.scroll.y = edge;
               }
               edge = targetY + this.target.height - this.deadzone.y - this.deadzone.height;
               if(this.scroll.y < edge)
               {
                  this.scroll.y = edge;
               }
            }
         }
         if(this.bounds != null)
         {
            if(this.scroll.x < this.bounds.left)
            {
               this.scroll.x = this.bounds.left;
            }
            if(this.scroll.x > this.bounds.right - this.width)
            {
               this.scroll.x = this.bounds.right - this.width;
            }
            if(this.scroll.y < this.bounds.top)
            {
               this.scroll.y = this.bounds.top;
            }
            if(this.scroll.y > this.bounds.bottom - this.height)
            {
               this.scroll.y = this.bounds.bottom - this.height;
            }
         }
         if(this._fxFlashAlpha > 0)
         {
            this._fxFlashAlpha -= FlxG.elapsed / this._fxFlashDuration;
            if(this._fxFlashAlpha <= 0 && this._fxFlashComplete != null)
            {
               this._fxFlashComplete();
            }
         }
         if(this._fxFadeAlpha > 0 && this._fxFadeAlpha < 1)
         {
            this._fxFadeAlpha += FlxG.elapsed / this._fxFadeDuration;
            if(this._fxFadeAlpha >= 1)
            {
               this._fxFadeAlpha = 1;
               if(this._fxFadeComplete != null)
               {
                  this._fxFadeComplete();
               }
            }
         }
         if(this._fxShakeDuration > 0)
         {
            this._fxShakeDuration -= FlxG.elapsed;
            if(this._fxShakeDuration <= 0)
            {
               this._fxShakeOffset.make();
               if(this._fxShakeComplete != null)
               {
                  this._fxShakeComplete();
               }
            }
            else
            {
               if(this._fxShakeDirection == SHAKE_BOTH_AXES || this._fxShakeDirection == SHAKE_HORIZONTAL_ONLY)
               {
                  this._fxShakeOffset.x = (FlxG.random() * this._fxShakeIntensity * this.width * 2 - this._fxShakeIntensity * this.width) * this._zoom;
               }
               if(this._fxShakeDirection == SHAKE_BOTH_AXES || this._fxShakeDirection == SHAKE_VERTICAL_ONLY)
               {
                  this._fxShakeOffset.y = (FlxG.random() * this._fxShakeIntensity * this.height * 2 - this._fxShakeIntensity * this.height) * this._zoom;
               }
            }
         }
      }
      
      public function follow(Target:FlxObject, Style:uint = 0) : void
      {
         var helper:Number = NaN;
         var w:Number = NaN;
         var h:Number = NaN;
         this.target = Target;
         switch(Style)
         {
            case STYLE_PLATFORMER:
               w = this.width / 8;
               h = this.height / 3;
               this.deadzone = new FlxRect((this.width - w) / 2,(this.height - h) / 2 - h * 0.25,w,h);
               break;
            case STYLE_TOPDOWN:
               helper = FlxU.max(this.width,this.height) / 4;
               this.deadzone = new FlxRect((this.width - helper) / 2,(this.height - helper) / 2,helper,helper);
               break;
            case STYLE_TOPDOWN_TIGHT:
               helper = FlxU.max(this.width,this.height) / 8;
               this.deadzone = new FlxRect((this.width - helper) / 2,(this.height - helper) / 2,helper,helper);
               break;
            case STYLE_LOCKON:
            default:
               this.deadzone = null;
         }
      }
      
      public function focusOn(Point:FlxPoint) : void
      {
         Point.x += Point.x > 0 ? 1e-7 : -1e-7;
         Point.y += Point.y > 0 ? 1e-7 : -1e-7;
         this.scroll.make(Point.x - this.width * 0.5,Point.y - this.height * 0.5);
      }
      
      public function setBounds(X:Number = 0, Y:Number = 0, Width:Number = 0, Height:Number = 0, UpdateWorld:Boolean = false) : void
      {
         if(this.bounds == null)
         {
            this.bounds = new FlxRect();
         }
         this.bounds.make(X,Y,Width,Height);
         if(UpdateWorld)
         {
            FlxG.worldBounds.copyFrom(this.bounds);
         }
         this.update();
      }
      
      public function flash(Color:uint = 4294967295, Duration:Number = 1, OnComplete:Function = null, Force:Boolean = false) : void
      {
         if(!Force && this._fxFlashAlpha > 0)
         {
            return;
         }
         this._fxFlashColor = Color;
         if(Duration <= 0)
         {
            Duration = Number.MIN_VALUE;
         }
         this._fxFlashDuration = Duration;
         this._fxFlashComplete = OnComplete;
         this._fxFlashAlpha = 1;
      }
      
      public function fade(Color:uint = 4278190080, Duration:Number = 1, OnComplete:Function = null, Force:Boolean = false) : void
      {
         if(!Force && this._fxFadeAlpha > 0)
         {
            return;
         }
         this._fxFadeColor = Color;
         if(Duration <= 0)
         {
            Duration = Number.MIN_VALUE;
         }
         this._fxFadeDuration = Duration;
         this._fxFadeComplete = OnComplete;
         this._fxFadeAlpha = Number.MIN_VALUE;
      }
      
      public function shake(Intensity:Number = 0.05, Duration:Number = 0.5, OnComplete:Function = null, Force:Boolean = true, Direction:uint = 0) : void
      {
         if(!Force && (this._fxShakeOffset.x != 0 || this._fxShakeOffset.y != 0))
         {
            return;
         }
         this._fxShakeIntensity = Intensity;
         this._fxShakeDuration = Duration;
         this._fxShakeComplete = OnComplete;
         this._fxShakeDirection = Direction;
         this._fxShakeOffset.make();
      }
      
      public function stopFX() : void
      {
         this._fxFlashAlpha = 0;
         this._fxFadeAlpha = 0;
         this._fxShakeDuration = 0;
         this._flashSprite.x = this.x + this.width * 0.5;
         this._flashSprite.y = this.y + this.height * 0.5;
      }
      
      public function copyFrom(Camera:FlxCamera) : FlxCamera
      {
         if(Camera.bounds == null)
         {
            this.bounds = null;
         }
         else
         {
            if(this.bounds == null)
            {
               this.bounds = new FlxRect();
            }
            this.bounds.copyFrom(Camera.bounds);
         }
         this.target = Camera.target;
         if(this.target != null)
         {
            if(Camera.deadzone == null)
            {
               this.deadzone = null;
            }
            else
            {
               if(this.deadzone == null)
               {
                  this.deadzone = new FlxRect();
               }
               this.deadzone.copyFrom(Camera.deadzone);
            }
         }
         return this;
      }
      
      public function get zoom() : Number
      {
         return this._zoom;
      }
      
      public function set zoom(Zoom:Number) : void
      {
         if(Zoom == 0)
         {
            this._zoom = defaultZoom;
         }
         else
         {
            this._zoom = Zoom;
         }
         this.setScale(this._zoom,this._zoom);
      }
      
      public function get alpha() : Number
      {
         return this._flashBitmap.alpha;
      }
      
      public function set alpha(Alpha:Number) : void
      {
         this._flashBitmap.alpha = Alpha;
      }
      
      public function get angle() : Number
      {
         return this._flashSprite.rotation;
      }
      
      public function set angle(Angle:Number) : void
      {
         this._flashSprite.rotation = Angle;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(Color:uint) : void
      {
         this._color = Color;
         var colorTransform:ColorTransform = this._flashBitmap.transform.colorTransform;
         colorTransform.redMultiplier = (this._color >> 16) * 0.00392;
         colorTransform.greenMultiplier = (this._color >> 8 & 0xFF) * 0.00392;
         colorTransform.blueMultiplier = (this._color & 0xFF) * 0.00392;
         this._flashBitmap.transform.colorTransform = colorTransform;
      }
      
      public function get antialiasing() : Boolean
      {
         return this._flashBitmap.smoothing;
      }
      
      public function set antialiasing(Antialiasing:Boolean) : void
      {
         this._flashBitmap.smoothing = Antialiasing;
      }
      
      public function getScale() : FlxPoint
      {
         return this._point.make(this._flashSprite.scaleX,this._flashSprite.scaleY);
      }
      
      public function setScale(X:Number, Y:Number) : void
      {
         this._flashSprite.scaleX = X;
         this._flashSprite.scaleY = Y;
      }
      
      public function getContainerSprite() : Sprite
      {
         return this._flashSprite;
      }
      
      public function fill(Color:uint, BlendAlpha:Boolean = true) : void
      {
         this._fill.fillRect(this._flashRect,Color);
         this.buffer.copyPixels(this._fill,this._flashRect,this._flashPoint,null,null,BlendAlpha);
      }
      
      internal function drawFX() : void
      {
         var alphaComponent:Number = NaN;
         if(this._fxFlashAlpha > 0)
         {
            alphaComponent = this._fxFlashColor >> 24;
            this.fill((uint((alphaComponent <= 0 ? 255 : alphaComponent) * this._fxFlashAlpha) << 24) + (this._fxFlashColor & 0xFFFFFF));
         }
         if(this._fxFadeAlpha > 0)
         {
            alphaComponent = this._fxFadeColor >> 24;
            this.fill((uint((alphaComponent <= 0 ? 255 : alphaComponent) * this._fxFadeAlpha) << 24) + (this._fxFadeColor & 0xFFFFFF));
         }
         if(this._fxShakeOffset.x != 0 || this._fxShakeOffset.y != 0)
         {
            this._flashSprite.x = this.x + this._flashOffsetX + this._fxShakeOffset.x;
            this._flashSprite.y = this.y + this._flashOffsetY + this._fxShakeOffset.y;
         }
      }
   }
}

