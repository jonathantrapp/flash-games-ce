package xplor
{
   import org.flixel.FlxG;
   
   public class Keebie
   {
      
      public static const UP:int = 0;
      
      public static const DOWN:int = 1;
      
      public static const LEFT:int = 2;
      
      public static const RIGHT:int = 3;
      
      public static const B1:int = 4;
      
      public static const B2:int = 5;
      
      public function Keebie()
      {
         super();
      }
      
      public static function Dir(param1:int) : Boolean
      {
         switch(param1)
         {
            case UP:
               return FlxG.keys.UP || FlxG.keys.W || FlxG.keys.NUMPADEIGHT;
            case DOWN:
               return FlxG.keys.DOWN || FlxG.keys.S || FlxG.keys.NUMPADTWO;
            case LEFT:
               return FlxG.keys.LEFT || FlxG.keys.A || FlxG.keys.NUMPADFOUR;
            case RIGHT:
               return FlxG.keys.RIGHT || FlxG.keys.D || FlxG.keys.NUMPADSIX;
            case B1:
               return false;
            case B2:
               return false;
            default:
               return false;
         }
      }
      
      public static function TapDir(param1:int) : Boolean
      {
         switch(param1)
         {
            case UP:
               return FlxG.keys.justPressed("UP") || FlxG.keys.justPressed("W") || FlxG.keys.justPressed("NUMPADEIGHT");
            case DOWN:
               return FlxG.keys.justPressed("DOWN") || FlxG.keys.justPressed("S") || FlxG.keys.justPressed("NUMPADTWO");
            case LEFT:
               return FlxG.keys.justPressed("LEFT") || FlxG.keys.justPressed("A") || FlxG.keys.justPressed("NUMPADFOUR");
            case RIGHT:
               return FlxG.keys.justPressed("RIGHT") || FlxG.keys.justPressed("D") || FlxG.keys.justPressed("NUMPADSIX");
            case B1:
               return false;
            case B2:
               return false;
            default:
               return false;
         }
      }
   }
}

