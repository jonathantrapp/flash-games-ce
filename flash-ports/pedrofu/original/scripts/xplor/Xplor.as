package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxGame;
   
   [Frame(factoryClass="xplor.Preloader")]
   [SWF(width="640",height="480",backgroundColor="#000000")]
   public class Xplor extends FlxGame
   {
      
      public static const FX_VOL:Number = 0.6;
      
      public function Xplor()
      {
         Global.game = this;
         super(320,240,TitleState,2,60,60,true);
         FlxG.framerate = 60;
         useSoundHotKeys = false;
      }
   }
}

