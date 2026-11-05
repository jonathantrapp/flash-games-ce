package org.flixel
{
   import flash.geom.Point;
   
   public class FlxPoint
   {
      
      public var x:Number;
      
      public var y:Number;
      
      public function FlxPoint(X:Number = 0, Y:Number = 0)
      {
         super();
         this.x = X;
         this.y = Y;
      }
      
      public function make(X:Number = 0, Y:Number = 0) : FlxPoint
      {
         this.x = X;
         this.y = Y;
         return this;
      }
      
      public function copyFrom(Point:FlxPoint) : FlxPoint
      {
         this.x = Point.x;
         this.y = Point.y;
         return this;
      }
      
      public function copyTo(Point:FlxPoint) : FlxPoint
      {
         Point.x = this.x;
         Point.y = this.y;
         return Point;
      }
      
      public function copyFromFlash(FlashPoint:Point) : FlxPoint
      {
         this.x = FlashPoint.x;
         this.y = FlashPoint.y;
         return this;
      }
      
      public function copyToFlash(FlashPoint:Point) : Point
      {
         FlashPoint.x = this.x;
         FlashPoint.y = this.y;
         return FlashPoint;
      }
   }
}

