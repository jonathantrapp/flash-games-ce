package xplor
{
   import org.flixel.FlxSprite;
   
   public class Sky extends FlxSprite
   {
      
      public static const SunsetImage:Class = Sky_SunsetImage;
      
      public static const DesertImage:Class = Sky_DesertImage;
      
      public static const CaveImage:Class = Sky_CaveImage;
      
      public var sky2:FlxSprite;
      
      public var sun:FlxSprite;
      
      public var realX:Number;
      
      public var realX2:Number;
      
      public function Sky(param1:int = 0)
      {
         super();
         if(Global.levelNum == 16)
         {
            loadGraphic(CaveImage,false,false,320,240,true);
         }
         else if(Global.levelNum > 11)
         {
            loadGraphic(DesertImage,false,false,320,240,true);
         }
         else if(Global.levelNum > 7)
         {
            loadGraphic(CaveImage,false,false,320,240,true);
         }
         else if(Global.levelNum > 3)
         {
            loadGraphic(SunsetImage,false,false,320,240,true);
         }
         else
         {
            loadGraphic(DesertImage,false,false,320,240,true);
         }
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

