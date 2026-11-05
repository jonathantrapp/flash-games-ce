package xplor.Monster
{
   import org.flixel.FlxPoint;
   import org.flixel.FlxSprite;
   import xplor.Global;
   import xplor.Level;
   
   public class BaseGuy extends FlxSprite
   {
      
      public static const IDLE:uint = 0;
      
      public static const JUMP:uint = 1;
      
      public static const HITSTUN:uint = 100;
      
      public static const CARRIED:uint = 101;
      
      public static const THROWN:uint = 102;
      
      public var startx:int;
      
      public var starty:int;
      
      public var ouch:Number;
      
      public var action:uint;
      
      public var reload:Number;
      
      public var tag:int;
      
      public function BaseGuy(tx:int, ty:int)
      {
         super();
      }
      
      public function Init(tx:int, ty:int) : void
      {
         this.tag = 0;
         this.startx = tx;
         this.starty = ty;
         this.Reset();
      }
      
      public function Reset() : void
      {
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
      }
      
      public function LineOfSight(me:FlxSprite, you:FlxSprite) : Boolean
      {
         return Global.level.GetLayer(Level.LAYER_SOLID).ray(new FlxPoint(me.x + me.width / 2,me.y + me.height / 2),new FlxPoint(you.x + you.width / 2,you.y + you.height / 2),null,1);
      }
      
      public function DistanceToGuy(him:FlxSprite) : Number
      {
         return Global.Distance(this.x + this.width / 2,this.y + this.height / 2,him.x + him.width / 2,him.y + him.height / 2);
      }
   }
}

