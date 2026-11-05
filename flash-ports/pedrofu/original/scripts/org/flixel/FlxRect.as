package org.flixel
{
   import flash.geom.Rectangle;
   
   public class FlxRect
   {
      
      public var x:Number;
      
      public var y:Number;
      
      public var width:Number;
      
      public var height:Number;
      
      public function FlxRect(X:Number = 0, Y:Number = 0, Width:Number = 0, Height:Number = 0)
      {
         super();
         this.x = X;
         this.y = Y;
         this.width = Width;
         this.height = Height;
      }
      
      public function get left() : Number
      {
         return this.x;
      }
      
      public function get right() : Number
      {
         return this.x + this.width;
      }
      
      public function get top() : Number
      {
         return this.y;
      }
      
      public function get bottom() : Number
      {
         return this.y + this.height;
      }
      
      public function make(X:Number = 0, Y:Number = 0, Width:Number = 0, Height:Number = 0) : FlxRect
      {
         this.x = X;
         this.y = Y;
         this.width = Width;
         this.height = Height;
         return this;
      }
      
      public function copyFrom(Rect:FlxRect) : FlxRect
      {
         this.x = Rect.x;
         this.y = Rect.y;
         this.width = Rect.width;
         this.height = Rect.height;
         return this;
      }
      
      public function copyTo(Rect:FlxRect) : FlxRect
      {
         Rect.x = this.x;
         Rect.y = this.y;
         Rect.width = this.width;
         Rect.height = this.height;
         return Rect;
      }
      
      public function copyFromFlash(FlashRect:Rectangle) : FlxRect
      {
         this.x = FlashRect.x;
         this.y = FlashRect.y;
         this.width = FlashRect.width;
         this.height = FlashRect.height;
         return this;
      }
      
      public function copyToFlash(FlashRect:Rectangle) : Rectangle
      {
         FlashRect.x = this.x;
         FlashRect.y = this.y;
         FlashRect.width = this.width;
         FlashRect.height = this.height;
         return FlashRect;
      }
      
      public function overlaps(Rect:FlxRect) : Boolean
      {
         return Rect.x + Rect.width > this.x && Rect.x < this.x + this.width && Rect.y + Rect.height > this.y && Rect.y < this.y + this.height;
      }
   }
}

