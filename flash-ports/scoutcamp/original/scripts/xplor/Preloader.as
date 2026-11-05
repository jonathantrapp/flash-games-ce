package xplor
{
   import org.flixel.system.FlxPreloader;
   
   [SWF(width="640", height="480", backgroundColor="#000000", frameRate="60")]
   public class Preloader extends FlxPreloader
   {
      
      public static var _FONT_VOLKS:Class = Preloader__FONT_VOLKS;
      
      public function Preloader()
      {
         className = "xplor.Xplor";
         super();
      }
   }
}

