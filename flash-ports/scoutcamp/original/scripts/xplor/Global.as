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
      
      public static var portals:Portals;
      
      public static var won:Boolean;
      
      public static var shopEntrance:int;
      
      public static var player:Player;
      
      public static var campfire:Campfire;
      
      public static var waveManager:WaveManager;
      
      public static var foodLeft:int;
      
      public static var tent:Tent;
      
      public static var tent2:Tent;
      
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
      
      public static function NewGame(param1:int) : void
      {
         difficulty = param1;
         levelSet = new LevelSet();
         tutList = new Array();
         player = new Player();
         Global.time = 0;
         won = false;
         foodLeft = 5;
      }
      
      public static function randRange(param1:Number, param2:Number) : Number
      {
         return param1 + FlxG.random() * (param2 - param1);
      }
      
      public static function Dampen(param1:Number, param2:Number) : Number
      {
         if(param1 > param2)
         {
            param1 -= param2;
         }
         else if(param1 < -param2)
         {
            param1 += param2;
         }
         else
         {
            param1 = 0;
         }
         return param1;
      }
      
      public static function Approach(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param1 > param2)
         {
            param1 -= param3;
            if(param1 < param2)
            {
               param1 = param2;
            }
         }
         else if(param1 < param2)
         {
            param1 += param3;
            if(param1 > param2)
            {
               param1 = param2;
            }
         }
         return param1;
      }
      
      public static function Cosine(param1:Number) : Number
      {
         return Math.cos(param1 * Math.PI / 180);
      }
      
      public static function Sine(param1:Number) : Number
      {
         return Math.sin(param1 * Math.PI / 180);
      }
      
      public static function AngleBetweenGuys(param1:FlxSprite, param2:FlxSprite) : Number
      {
         return AngleBetween(param1.x + param1.width / 2,param1.y + param1.height / 2,param2.x + param2.width / 2,param2.y + param2.height / 2);
      }
      
      public static function AngleBetween(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         var _loc5_:Number = NaN;
         _loc5_ = Math.atan2(param4 - param2,param3 - param1) * 180 / Math.PI;
         while(_loc5_ < 0)
         {
            _loc5_ += 360;
         }
         while(_loc5_ >= 360)
         {
            _loc5_ -= 360;
         }
         return _loc5_;
      }
      
      public static function Distance(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return Math.sqrt((param1 - param3) * (param1 - param3) + (param2 - param4) * (param2 - param4));
      }
      
      public static function TurnToward(param1:Number, param2:Number, param3:Number) : Number
      {
         if(Math.abs(param2 - param1) < 180)
         {
            if(param2 > param1)
            {
               param1 += param3;
               if(param1 > param2)
               {
                  param1 = param2;
               }
            }
            else
            {
               param1 -= param3;
               if(param1 < param2)
               {
                  param1 = param2;
               }
            }
         }
         else if(param2 < param1)
         {
            param1 += param3;
            if(param1 >= 360)
            {
               param1 -= 360;
            }
         }
         else
         {
            param1 -= param3;
            if(param1 < 0)
            {
               param1 += 360;
            }
         }
         return param1;
      }
   }
}

