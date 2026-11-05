package xplor
{
   import flash.utils.ByteArray;
   import org.flixel.*;
   
   public class Profile
   {
      
      public static var sndVol:Number;
      
      public static var musVol:Number;
      
      public static var levelStatus:Array;
      
      public static var skills:Array;
      
      public static var skillPts:int;
      
      public static var xp:int;
      
      public static var level:int;
      
      public static var levelsPassed:int;
      
      public static var fs:FlxSave = null;
      
      public function Profile()
      {
         super();
      }
      
      public static function Init() : void
      {
         var _loc1_:Object = null;
         var _loc2_:ByteArray = null;
         var _loc3_:int = 0;
         if(fs == null)
         {
            fs = new FlxSave();
            fs.bind("ScoutCamp-Hamumu");
            if(fs.data.sndVol == null)
            {
               sndVol = 100;
            }
            else
            {
               sndVol = fs.data.sndVol;
            }
            if(fs.data.musVol == null)
            {
               musVol = 75;
            }
            else
            {
               musVol = fs.data.musVol;
            }
            if(fs.data.skills == null)
            {
               skills = new Array();
               _loc3_ = 0;
               while(_loc3_ < 50)
               {
                  skills[_loc3_] = 0;
                  _loc3_++;
               }
               skills[0] = 1;
               fs.data.skills = skills;
            }
            else
            {
               skills = fs.data.skills;
            }
            if(fs.data.skillPts == null)
            {
               skillPts = 0;
            }
            else
            {
               skillPts = fs.data.skillPts;
            }
            if(fs.data.skillPts == null)
            {
               skillPts = 0;
            }
            else
            {
               skillPts = fs.data.skillPts;
            }
            if(fs.data.level == null)
            {
               level = 1;
            }
            else
            {
               level = fs.data.level;
            }
            if(fs.data.xp == null)
            {
               xp = 0;
            }
            else
            {
               xp = fs.data.xp;
            }
            if(fs.data.levelsPassed == null)
            {
               levelsPassed = 0;
            }
            else
            {
               levelsPassed = fs.data.levelsPassed;
            }
            if(fs.data.levelStatus == null)
            {
               levelStatus = new Array();
               fs.data.levelStatus = levelStatus;
            }
            else
            {
               levelStatus = fs.data.levelStatus;
            }
         }
      }
      
      public static function ResetProgress() : void
      {
         skills = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < 50)
         {
            skills[_loc1_] = 0;
            _loc1_++;
         }
         skills[0] = 1;
         skillPts = 0;
         level = 1;
         xp = 0;
         fs.data.level = 1;
         fs.data.xp = 0;
         fs.data.skillPts = 0;
         fs.data.skills = skills;
         levelsPassed = 0;
         levelStatus = new Array();
         fs.data.levelStatus = levelStatus;
      }
      
      public static function LevelPassed(param1:int) : Boolean
      {
         if(levelStatus[param1] != null)
         {
            return levelStatus[param1].passed;
         }
         return false;
      }
      
      public static function LevelsPassed() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < levelStatus.length)
         {
            if(levelStatus[_loc2_] != null && Boolean(levelStatus[_loc2_].passed))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function WinLevel() : void
      {
         var _loc1_:LevelStatus = null;
         if(Global.mode == Global.TEST)
         {
            return;
         }
         if(levelStatus[Global.levelNum] == null)
         {
            _loc1_ = new LevelStatus();
            _loc1_.passed = true;
            _loc1_.bestTime = Global.time;
            levelStatus[Global.levelNum] = _loc1_;
         }
         else
         {
            if(levelStatus[Global.levelNum].bestTime > Global.time)
            {
               levelStatus[Global.levelNum].bestTime = Global.time;
            }
            levelStatus[Global.levelNum].passed = true;
         }
      }
      
      public static function SaveOverall() : void
      {
         fs.data.skills = skills;
         fs.data.skillPts = skillPts;
         fs.data.level = level;
         fs.data.xp = xp;
         fs.data.levelsPassed = levelsPassed;
         fs.data.levelStatus = levelStatus;
         fs.data.sndVol = sndVol;
         fs.data.musVol = musVol;
      }
      
      public static function SaveGame() : void
      {
         SaveOverall();
      }
      
      public static function XPNeed() : int
      {
         if(level < 5)
         {
            return level * 50;
         }
         return level * 100;
      }
   }
}

