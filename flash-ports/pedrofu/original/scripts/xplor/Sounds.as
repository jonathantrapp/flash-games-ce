package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxSound;
   
   public class Sounds
   {
      
      public static var BoomSnd:Class = Sounds_BoomSnd;
      
      public static var PunchSnd:Class = Sounds_PunchSnd;
      
      public static var PunchHighSnd:Class = Sounds_PunchHighSnd;
      
      public static var LightningSnd:Class = Sounds_LightningSnd;
      
      public static var SmashSnd:Class = Sounds_SmashSnd;
      
      public static var LevelUpSnd:Class = Sounds_LevelUpSnd;
      
      public static var MissileSnd:Class = Sounds_MissileSnd;
      
      public static var PowerUpSnd:Class = Sounds_PowerUpSnd;
      
      public static var ArrowShootSnd:Class = Sounds_ArrowShootSnd;
      
      public static var MailGetSnd:Class = Sounds_MailGetSnd;
      
      public static var PedroHurtSnd:Class = Sounds_PedroHurtSnd;
      
      public static var CriticalSnd:Class = Sounds_CriticalSnd;
      
      public static var CrushingBlowSnd:Class = Sounds_CrushingBlowSnd;
      
      public static var FuriousBlastSnd:Class = Sounds_FuriousBlastSnd;
      
      public static var FuriousFixSnd:Class = Sounds_FuriousFixSnd;
      
      public static var FreezeSnd:Class = Sounds_FreezeSnd;
      
      public static var FallSnd:Class = Sounds_FallSnd;
      
      public static var TeleportSnd:Class = Sounds_TeleportSnd;
      
      public static var BerserkSnd:Class = Sounds_BerserkSnd;
      
      public static var BarrierShockSnd:Class = Sounds_BarrierShockSnd;
      
      public static var StompSnd:Class = Sounds_StompSnd;
      
      public static var BigJumpSnd:Class = Sounds_BigJumpSnd;
      
      public static var BossDieSnd:Class = Sounds_BossDieSnd;
      
      public static var HeartSnd:Class = Sounds_HeartSnd;
      
      public static var WallDownSnd:Class = Sounds_WallDownSnd;
      
      public static var BarrierDownSnd:Class = Sounds_BarrierDownSnd;
      
      public static var PotionSnd:Class = Sounds_PotionSnd;
      
      public static var MagicSnd:Class = Sounds_MagicSnd;
      
      public static var BurnSnd:Class = Sounds_BurnSnd;
      
      public static var RapidFireSnd:Class = Sounds_RapidFireSnd;
      
      public static var EnrageSnd:Class = Sounds_EnrageSnd;
      
      public static var SnortSnd:Class = Sounds_SnortSnd;
      
      public static var DashSnd:Class = Sounds_DashSnd;
      
      public static var SlashSnd:Class = Sounds_SlashSnd;
      
      public static var MellowSong:Class = Sounds_MellowSong;
      
      public static var Song1:Class = Sounds_Song1;
      
      public static var Song2:Class = Sounds_Song2;
      
      public static var Song3:Class = Sounds_Song3;
      
      public static var bipSnd:Class = Sounds_bipSnd;
      
      public static var curSong:int = -1;
      
      public function Sounds()
      {
         super();
      }
      
      public static function play(s:Class) : void
      {
         FlxG.play(s,Profile.sndVol / 100,false);
      }
      
      public static function playSong(n:int) : void
      {
         var m:Class = null;
         if(n == 0)
         {
            m = MellowSong;
         }
         else if(n == 1)
         {
            m = Song1;
         }
         else if(n == 2)
         {
            m = Song2;
         }
         else if(n == 3)
         {
            m = Song3;
         }
         if(FlxG.music == null || !FlxG.music.active || n != curSong)
         {
            if(FlxG.music != null)
            {
               FlxG.music.destroy();
            }
            curSong = n;
            FlxG.music = new FlxSound();
            FlxG.music.loadEmbedded(m,true);
            FlxG.music.survive = true;
            FlxG.music.volume = Profile.musVol / 100;
            FlxG.music.play();
         }
      }
   }
}

