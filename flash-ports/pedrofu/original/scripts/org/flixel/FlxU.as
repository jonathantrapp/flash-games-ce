package org.flixel
{
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class FlxU
   {
      
      public function FlxU()
      {
         super();
      }
      
      public static function openURL(URL:String) : void
      {
         navigateToURL(new URLRequest(URL),"_blank");
      }
      
      public static function abs(Value:Number) : Number
      {
         return Value > 0 ? Value : -Value;
      }
      
      public static function floor(Value:Number) : Number
      {
         var number:Number = int(Value);
         return Value > 0 ? number : (number != Value ? number - 1 : number);
      }
      
      public static function ceil(Value:Number) : Number
      {
         var number:Number = int(Value);
         return Value > 0 ? (number != Value ? number + 1 : number) : number;
      }
      
      public static function round(Value:Number) : Number
      {
         var number:Number = int(Value + (Value > 0 ? 0.5 : -0.5));
         return Value > 0 ? number : (number != Value ? number - 1 : number);
      }
      
      public static function min(Number1:Number, Number2:Number) : Number
      {
         return Number1 <= Number2 ? Number1 : Number2;
      }
      
      public static function max(Number1:Number, Number2:Number) : Number
      {
         return Number1 >= Number2 ? Number1 : Number2;
      }
      
      public static function bound(Value:Number, Min:Number, Max:Number) : Number
      {
         var lowerBound:Number = Value < Min ? Min : Value;
         return lowerBound > Max ? Max : lowerBound;
      }
      
      public static function srand(Seed:Number) : Number
      {
         return 69621 * int(Seed * 2147483647) % 2147483647 / 2147483647;
      }
      
      public static function shuffle(Objects:Array, HowManyTimes:uint) : Array
      {
         var index1:uint = 0;
         var index2:uint = 0;
         var object:Object = null;
         var i:uint = 0;
         while(i < HowManyTimes)
         {
            index1 = Math.random() * Objects.length;
            index2 = Math.random() * Objects.length;
            object = Objects[index2];
            Objects[index2] = Objects[index1];
            Objects[index1] = object;
            i++;
         }
         return Objects;
      }
      
      public static function getRandom(Objects:Array, StartIndex:uint = 0, Length:uint = 0) : Object
      {
         var l:uint = 0;
         if(Objects != null)
         {
            l = Length;
            if(l == 0 || l > Objects.length - StartIndex)
            {
               l = Objects.length - StartIndex;
            }
            if(l > 0)
            {
               return Objects[StartIndex + uint(Math.random() * l)];
            }
         }
         return null;
      }
      
      public static function getTicks() : uint
      {
         return getTimer();
      }
      
      public static function formatTicks(StartTicks:uint, EndTicks:uint) : String
      {
         return (EndTicks - StartTicks) / 1000 + "s";
      }
      
      public static function makeColor(Red:uint, Green:uint, Blue:uint, Alpha:Number = 1) : uint
      {
         return ((Alpha > 1 ? Alpha : Alpha * 255) & 0xFF) << 24 | (Red & 0xFF) << 16 | (Green & 0xFF) << 8 | Blue & 0xFF;
      }
      
      public static function makeColorFromHSB(Hue:Number, Saturation:Number, Brightness:Number, Alpha:Number = 1) : uint
      {
         var red:Number = NaN;
         var green:Number = NaN;
         var blue:Number = NaN;
         var slice:int = 0;
         var hf:Number = NaN;
         var aa:Number = NaN;
         var bb:Number = NaN;
         var cc:Number = NaN;
         if(Saturation == 0)
         {
            red = Brightness;
            green = Brightness;
            blue = Brightness;
         }
         else
         {
            if(Hue == 360)
            {
               Hue = 0;
            }
            slice = Hue / 60;
            hf = Hue / 60 - slice;
            aa = Brightness * (1 - Saturation);
            bb = Brightness * (1 - Saturation * hf);
            cc = Brightness * (1 - Saturation * (1 - hf));
            switch(slice)
            {
               case 0:
                  red = Brightness;
                  green = cc;
                  blue = aa;
                  break;
               case 1:
                  red = bb;
                  green = Brightness;
                  blue = aa;
                  break;
               case 2:
                  red = aa;
                  green = Brightness;
                  blue = cc;
                  break;
               case 3:
                  red = aa;
                  green = bb;
                  blue = Brightness;
                  break;
               case 4:
                  red = cc;
                  green = aa;
                  blue = Brightness;
                  break;
               case 5:
                  red = Brightness;
                  green = aa;
                  blue = bb;
                  break;
               default:
                  red = 0;
                  green = 0;
                  blue = 0;
            }
         }
         return ((Alpha > 1 ? Alpha : Alpha * 255) & 0xFF) << 24 | uint(red * 255) << 16 | uint(green * 255) << 8 | uint(blue * 255);
      }
      
      public static function getRGBA(Color:uint, Results:Array = null) : Array
      {
         if(Results == null)
         {
            Results = new Array();
         }
         Results[0] = Color >> 16 & 0xFF;
         Results[1] = Color >> 8 & 0xFF;
         Results[2] = Color & 0xFF;
         Results[3] = Number(Color >> 24 & 0xFF) / 255;
         return Results;
      }
      
      public static function getHSB(Color:uint, Results:Array = null) : Array
      {
         if(Results == null)
         {
            Results = new Array();
         }
         var red:Number = Number(Color >> 16 & 0xFF) / 255;
         var green:Number = Number(Color >> 8 & 0xFF) / 255;
         var blue:Number = Number(Color & 0xFF) / 255;
         var m:Number = red > green ? red : green;
         var dmax:Number = m > blue ? m : blue;
         m = red > green ? green : red;
         var dmin:Number = m > blue ? blue : m;
         var range:Number = dmax - dmin;
         Results[2] = dmax;
         Results[1] = 0;
         Results[0] = 0;
         if(dmax != 0)
         {
            Results[1] = range / dmax;
         }
         if(Results[1] != 0)
         {
            if(red == dmax)
            {
               Results[0] = (green - blue) / range;
            }
            else if(green == dmax)
            {
               Results[0] = 2 + (blue - red) / range;
            }
            else if(blue == dmax)
            {
               Results[0] = 4 + (red - green) / range;
            }
            Results[0] *= 60;
            if(Results[0] < 0)
            {
               Results[0] += 360;
            }
         }
         Results[3] = Number(Color >> 24 & 0xFF) / 255;
         return Results;
      }
      
      public static function formatTime(Seconds:Number, ShowMS:Boolean = false) : String
      {
         var timeString:String = int(Seconds / 60) + ":";
         var timeStringHelper:int = int(Seconds) % 60;
         if(timeStringHelper < 10)
         {
            timeString += "0";
         }
         timeString += timeStringHelper;
         if(ShowMS)
         {
            timeString += ".";
            timeStringHelper = (Seconds - int(Seconds)) * 100;
            if(timeStringHelper < 10)
            {
               timeString += "0";
            }
            timeString += timeStringHelper;
         }
         return timeString;
      }
      
      public static function formatArray(AnyArray:Array) : String
      {
         if(AnyArray == null || AnyArray.length <= 0)
         {
            return "";
         }
         var string:String = AnyArray[0].toString();
         var i:uint = 0;
         var l:uint = AnyArray.length;
         while(i < l)
         {
            string += ", " + AnyArray[i++].toString();
         }
         return string;
      }
      
      public static function formatMoney(Amount:Number, ShowDecimal:Boolean = true, EnglishStyle:Boolean = true) : String
      {
         var helper:int = 0;
         var amount:int = Amount;
         var string:String = "";
         var comma:String = "";
         var zeroes:String = "";
         while(amount > 0)
         {
            if(string.length > 0 && comma.length <= 0)
            {
               if(EnglishStyle)
               {
                  comma = ",";
               }
               else
               {
                  comma = ".";
               }
            }
            zeroes = "";
            helper = amount - int(amount / 1000) * 1000;
            amount /= 1000;
            if(amount > 0)
            {
               if(helper < 100)
               {
                  zeroes += "0";
               }
               if(helper < 10)
               {
                  zeroes += "0";
               }
            }
            string = zeroes + helper + comma + string;
         }
         if(ShowDecimal)
         {
            amount = int(Amount * 100) - int(Amount) * 100;
            string += (EnglishStyle ? "." : ",") + amount;
            if(amount < 10)
            {
               string += "0";
            }
         }
         return string;
      }
      
      public static function getClassName(Obj:Object, Simple:Boolean = false) : String
      {
         var string:String = getQualifiedClassName(Obj);
         string = string.replace("::",".");
         if(Simple)
         {
            string = string.substr(string.lastIndexOf(".") + 1);
         }
         return string;
      }
      
      public static function compareClassNames(Object1:Object, Object2:Object) : Boolean
      {
         return getQualifiedClassName(Object1) == getQualifiedClassName(Object2);
      }
      
      public static function getClass(Name:String) : Class
      {
         return getDefinitionByName(Name) as Class;
      }
      
      public static function computeVelocity(Velocity:Number, Acceleration:Number = 0, Drag:Number = 0, Max:Number = 10000) : Number
      {
         var drag:Number = NaN;
         if(Acceleration != 0)
         {
            Velocity += Acceleration * FlxG.elapsed;
         }
         else if(Drag != 0)
         {
            drag = Drag * FlxG.elapsed;
            if(Velocity - drag > 0)
            {
               Velocity -= drag;
            }
            else if(Velocity + drag < 0)
            {
               Velocity += drag;
            }
            else
            {
               Velocity = 0;
            }
         }
         if(Velocity != 0 && Max != 10000)
         {
            if(Velocity > Max)
            {
               Velocity = Max;
            }
            else if(Velocity < -Max)
            {
               Velocity = -Max;
            }
         }
         return Velocity;
      }
      
      public static function rotatePoint(X:Number, Y:Number, PivotX:Number, PivotY:Number, Angle:Number, Point:FlxPoint = null) : FlxPoint
      {
         var sin:Number = 0;
         var cos:Number = 0;
         var radians:Number = Angle * -0.017453293;
         while(radians < -3.14159265)
         {
            radians += 6.28318531;
         }
         while(radians > 3.14159265)
         {
            radians -= 6.28318531;
         }
         if(radians < 0)
         {
            sin = 1.27323954 * radians + 0.405284735 * radians * radians;
            if(sin < 0)
            {
               sin = 0.225 * (sin * -sin - sin) + sin;
            }
            else
            {
               sin = 0.225 * (sin * sin - sin) + sin;
            }
         }
         else
         {
            sin = 1.27323954 * radians - 0.405284735 * radians * radians;
            if(sin < 0)
            {
               sin = 0.225 * (sin * -sin - sin) + sin;
            }
            else
            {
               sin = 0.225 * (sin * sin - sin) + sin;
            }
         }
         radians += 1.57079632;
         if(radians > 3.14159265)
         {
            radians -= 6.28318531;
         }
         if(radians < 0)
         {
            cos = 1.27323954 * radians + 0.405284735 * radians * radians;
            if(cos < 0)
            {
               cos = 0.225 * (cos * -cos - cos) + cos;
            }
            else
            {
               cos = 0.225 * (cos * cos - cos) + cos;
            }
         }
         else
         {
            cos = 1.27323954 * radians - 0.405284735 * radians * radians;
            if(cos < 0)
            {
               cos = 0.225 * (cos * -cos - cos) + cos;
            }
            else
            {
               cos = 0.225 * (cos * cos - cos) + cos;
            }
         }
         var dx:Number = X - PivotX;
         var dy:Number = PivotY + Y;
         if(Point == null)
         {
            Point = new FlxPoint();
         }
         Point.x = PivotX + cos * dx - sin * dy;
         Point.y = PivotY - sin * dx - cos * dy;
         return Point;
      }
      
      public static function getAngle(Point1:FlxPoint, Point2:FlxPoint) : Number
      {
         var x:Number = Point2.x - Point1.x;
         var y:Number = Point2.y - Point1.y;
         if(x == 0 && y == 0)
         {
            return 0;
         }
         var c1:Number = 3.14159265 * 0.25;
         var c2:Number = 3 * c1;
         var ay:Number = y < 0 ? -y : y;
         var angle:Number = 0;
         if(x >= 0)
         {
            angle = c1 - c1 * ((x - ay) / (x + ay));
         }
         else
         {
            angle = c2 - c1 * ((x + ay) / (ay - x));
         }
         angle = (y < 0 ? -angle : angle) * 57.2957796;
         if(angle > 90)
         {
            angle -= 270;
         }
         else
         {
            angle += 90;
         }
         return angle;
      }
      
      public static function getDistance(Point1:FlxPoint, Point2:FlxPoint) : Number
      {
         var dx:Number = Point1.x - Point2.x;
         var dy:Number = Point1.y - Point2.y;
         return Math.sqrt(dx * dx + dy * dy);
      }
   }
}

