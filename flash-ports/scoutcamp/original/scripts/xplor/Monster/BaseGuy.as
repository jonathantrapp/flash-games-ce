package xplor.Monster
{
   import org.flixel.FlxG;
   import org.flixel.FlxPoint;
   import org.flixel.FlxSprite;
   import xplor.Global;
   import xplor.Level;
   
   public class BaseGuy extends FlxSprite
   {
      
      public static const IDLE:uint = 0;
      
      public static const JUMP:uint = 1;
      
      public static const BORN:uint = 100;
      
      public static const ESCAPE:uint = 101;
      
      public var startx:int;
      
      public var starty:int;
      
      public var ouch:Number;
      
      public var action:uint;
      
      public var traveled:Number;
      
      public function BaseGuy(param1:int, param2:int)
      {
         super();
      }
      
      public function Init(param1:int, param2:int) : void
      {
         this.startx = param1;
         this.starty = param2;
         this.Reset();
      }
      
      public function Reset() : void
      {
         this.traveled = 0;
         x = this.startx * 16 + 8 - width / 2;
         y = this.starty * 16 + 16 - height;
         exists = true;
         scale.x = 1;
         scale.y = 1;
         this.action = IDLE;
         velocity.x = 0;
         velocity.y = 0;
         acceleration.x = 0;
         acceleration.y = 0;
      }
      
      override public function update() : void
      {
         super.update();
         this.traveled += Math.abs(velocity.x * FlxG.elapsed);
      }
      
      public function LineOfSight(param1:FlxSprite, param2:FlxSprite) : Boolean
      {
         return Global.level.GetLayer(Level.LAYER_SOLID).ray(new FlxPoint(param1.x + param1.width / 2,param1.y + param1.height / 2),new FlxPoint(param2.x + param2.width / 2,param2.y + param2.height / 2),null,1);
      }
      
      public function DistanceToGuy(param1:FlxSprite) : Number
      {
         return Global.Distance(this.x + this.width / 2,this.y + this.height / 2,param1.x + param1.width / 2,param1.y + param1.height / 2);
      }
   }
}

