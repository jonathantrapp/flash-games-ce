package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxSound;
   
   public class Sounds
   {
      
      public static var BoomSnd:Class = Sounds_BoomSnd;
      
      public static var SendWaveSnd:Class = Sounds_SendWaveSnd;
      
      public static var AcceptSnd:Class = Sounds_AcceptSnd;
      
      public static var LightningSnd:Class = Sounds_LightningSnd;
      
      public static var HammerSnd:Class = Sounds_HammerSnd;
      
      public static var LevelUpSnd:Class = Sounds_LevelUpSnd;
      
      public static var AlienBornSnd:Class = Sounds_AlienBornSnd;
      
      public static var UpgradeSnd:Class = Sounds_UpgradeSnd;
      
      public static var BuildSnd:Class = Sounds_BuildSnd;
      
      public static var HungryBreedSnd:Class = Sounds_HungryBreedSnd;
      
      public static var EatFoodSnd:Class = Sounds_EatFoodSnd;
      
      public static var TookFoodSnd:Class = Sounds_TookFoodSnd;
      
      public static var MellowSong:Class = Sounds_MellowSong;
      
      public static var DesertSong:Class = Sounds_DesertSong;
      
      public static var MountainSong:Class = Sounds_MountainSong;
      
      public static var CaveSong:Class = Sounds_CaveSong;
      
      public static var ForestSong:Class = Sounds_ForestSong;
      
      public static var BossSong:Class = Sounds_BossSong;
      
      public static var bipSnd:Class = Sounds_bipSnd;
      
      public static var curSong:int = -1;
      
      public function Sounds()
      {
         super();
      }
      
      public static function play(param1:Class) : void
      {
         FlxG.play(param1,Profile.sndVol / 100,false);
      }
      
      public static function playSong(param1:int) : void
      {
         var _loc2_:Class = null;
         if(param1 == 0)
         {
            _loc2_ = MellowSong;
         }
         else if(param1 == 1)
         {
            _loc2_ = DesertSong;
         }
         else if(param1 == 2)
         {
            _loc2_ = MountainSong;
         }
         else if(param1 == 3)
         {
            _loc2_ = CaveSong;
         }
         else if(param1 == 4)
         {
            _loc2_ = ForestSong;
         }
         else if(param1 == 5)
         {
            _loc2_ = BossSong;
         }
         if(FlxG.music == null || !FlxG.music.active || param1 != curSong)
         {
            if(FlxG.music != null)
            {
               FlxG.music.destroy();
            }
            curSong = param1;
            FlxG.music = new FlxSound();
            FlxG.music.loadEmbedded(_loc2_,true);
            FlxG.music.survive = true;
            FlxG.music.volume = Profile.musVol / 100;
            FlxG.music.play();
         }
      }
   }
}

