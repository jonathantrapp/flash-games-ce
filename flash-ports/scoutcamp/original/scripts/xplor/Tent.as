package xplor
{
   import org.flixel.FlxSprite;
   
   public class Tent extends FlxSprite
   {
      
      public static var FireImage:Class = Tent_FireImage;
      
      public var tx:int;
      
      public var ty:int;
      
      public function Tent(param1:Number, param2:Number)
      {
         super(param1,param2);
         loadGraphic(FireImage,true,false,16,10,true);
         height = 8;
      }
      
      override public function update() : void
      {
      }
   }
}

