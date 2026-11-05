package xplor.Bullet
{
   import org.flixel.FlxG;
   import org.flixel.FlxPoint;
   import org.flixel.FlxSprite;
   import xplor.Global;
   import xplor.Level;
   import xplor.Monster.BaseGuy;
   import xplor.Player;
   
   public class BaseBullet extends FlxSprite
   {
      
      public var damage:Number;
      
      public var power:Number;
      
      public var target:BaseGuy;
      
      public var traveled:Number;
      
      public function BaseBullet()
      {
         super();
      }
      
      public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.damage = param4;
         this.traveled = 0;
      }
      
      public function LineOfSight(param1:FlxSprite, param2:FlxSprite) : Boolean
      {
         return Global.level.GetLayer(Level.LAYER_SOLID).ray(new FlxPoint(param1.x + param1.width / 2,param1.y + param1.height / 2),new FlxPoint(param2.x + param2.width / 2,param2.y + param2.height / 2),null,1);
      }
      
      public function TargetPlayer(param1:int = 0, param2:Boolean = false) : Player
      {
         return null;
      }
      
      override public function update() : void
      {
         super.update();
         this.traveled += Math.abs(velocity.x * FlxG.elapsed) + Math.abs(velocity.y * FlxG.elapsed);
         if(x < -width || y < -height || x > Global.level.width * 16 || y > Global.level.height * 16)
         {
            exists = false;
         }
      }
   }
}

