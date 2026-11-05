package xplor
{
   import org.flixel.FlxSprite;
   
   public class Sky extends FlxSprite
   {
      
      public static const DesertImage:Class = Sky_DesertImage;
      
      public var sky2:FlxSprite;
      
      public var sun:FlxSprite;
      
      public var realX:Number;
      
      public var realX2:Number;
      
      public function Sky(which:int = 0)
      {
         super();
         loadGraphic(DesertImage,false,false,320,240,true);
         scrollFactor.x = 0;
         scrollFactor.y = 0;
      }
      
      override public function update() : void
      {
      }
      
      override public function draw() : void
      {
         super.draw();
      }
   }
}

