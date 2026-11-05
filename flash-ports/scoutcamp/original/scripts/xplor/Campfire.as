package xplor
{
   import org.flixel.FlxSprite;
   
   public class Campfire extends FlxSprite
   {
      
      public static var FireImage:Class = Campfire_FireImage;
      
      public var tx:int;
      
      public var ty:int;
      
      public function Campfire(param1:Number, param2:Number)
      {
         super(param1,param2);
         loadGraphic(FireImage,true,false,16,19,true);
         addAnimation("burn",[0,1,2,0,1,2,1,0,2,0,1,2,0,1,0,2,1,2,0,2,0,1,0,1,2,1,0,2,1],10,true);
         play("burn");
      }
      
      override public function update() : void
      {
      }
   }
}

