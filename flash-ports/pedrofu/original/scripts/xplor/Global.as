package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxGame;
   import org.flixel.FlxSave;
   import org.flixel.FlxSprite;
   
   public class Global
   {
      
      public static var level:Level;
      
      public static var mapStore:MapStore;
      
      public static var mode:uint;
      
      public static var game:FlxGame;
      
      public static var time:Number;
      
      public static var tutList:Array;
      
      public static var levelSet:LevelSet;
      
      public static var difficulty:int;
      
      public static var bullets:Bullets;
      
      public static var badguys:Badguys;
      
      public static var throwDmg:Number;
      
      public static var throwSpeed:Number;
      
      public static var won:Boolean;
      
      public static var shopEntrance:int;
      
      public static var pedro:Pedro;
      
      public static var mailLeft:int;
      
      public static var conversation:Boolean;
      
      public static var VolumeImage:Class = Global_VolumeImage;
      
      public static const PLAY:uint = 0;
      
      public static const EDIT:uint = 1;
      
      public static const TEST:uint = 2;
      
      public static const TILE_WIDTH:uint = 16;
      
      public static const TILE_HEIGHT:uint = 16;
      
      public static var inited:Boolean = false;
      
      public static var levelNum:int = 0;
      
      public static var fs:FlxSave = null;
      
      public function Global()
      {
         super();
      }
      
      public static function Init() : void
      {
         if(inited)
         {
            return;
         }
         Profile.Init();
         mapStore = new MapStore();
         tutList = new Array();
         won = false;
      }
      
      public static function NewGame(diff:int) : void
      {
         conversation = false;
         difficulty = diff;
         levelSet = new LevelSet();
         tutList = new Array();
         Global.time = 0;
         won = false;
      }
      
      public static function randRange(min:Number, max:Number) : Number
      {
         return min + FlxG.random() * (max - min);
      }
      
      public static function Dampen(val:Number, amt:Number) : Number
      {
         if(val > amt)
         {
            val -= amt;
         }
         else if(val < -amt)
         {
            val += amt;
         }
         else
         {
            val = 0;
         }
         return val;
      }
      
      public static function Approach(val:Number, target:Number, amt:Number) : Number
      {
         if(val > target)
         {
            val -= amt;
            if(val < target)
            {
               val = target;
            }
         }
         else if(val < target)
         {
            val += amt;
            if(val > target)
            {
               val = target;
            }
         }
         return val;
      }
      
      public static function Cosine(ang:Number) : Number
      {
         return Math.cos(ang * Math.PI / 180);
      }
      
      public static function Sine(ang:Number) : Number
      {
         return Math.sin(ang * Math.PI / 180);
      }
      
      public static function AngleBetweenGuys(guy1:FlxSprite, guy2:FlxSprite) : Number
      {
         return AngleBetween(guy1.x + guy1.width / 2,guy1.y + guy1.height / 2,guy2.x + guy2.width / 2,guy2.y + guy2.height / 2);
      }
      
      public static function AngleBetween(x1:Number, y1:Number, x2:Number, y2:Number) : Number
      {
         var a:Number = NaN;
         a = Math.atan2(y2 - y1,x2 - x1) * 180 / Math.PI;
         while(a < 0)
         {
            a += 360;
         }
         while(a >= 360)
         {
            a -= 360;
         }
         return a;
      }
      
      public static function Distance(x1:Number, y1:Number, x2:Number, y2:Number) : Number
      {
         return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
      }
      
      public static function TurnToward(a:Number, dest:Number, amt:Number) : Number
      {
         if(Math.abs(dest - a) < 180)
         {
            if(dest > a)
            {
               a += amt;
               if(a > dest)
               {
                  a = dest;
               }
            }
            else
            {
               a -= amt;
               if(a < dest)
               {
                  a = dest;
               }
            }
         }
         else if(dest < a)
         {
            a += amt;
            if(a >= 360)
            {
               a -= 360;
            }
         }
         else
         {
            a -= amt;
            if(a < 0)
            {
               a += 360;
            }
         }
         return a;
      }
   }
}

