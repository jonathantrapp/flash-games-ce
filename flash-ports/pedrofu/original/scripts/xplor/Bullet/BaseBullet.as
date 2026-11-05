package xplor.Bullet
{
   import org.flixel.FlxG;
   import org.flixel.FlxPoint;
   import org.flixel.FlxSprite;
   import xplor.Global;
   import xplor.Level;
   import xplor.Monster.BaseGuy;
   import xplor.Pedro;
   
   public class BaseBullet extends FlxSprite
   {
      
      public var damage:Number;
      
      public var power:Number;
      
      public var target:BaseGuy;
      
      public var traveled:Number;
      
      public var frozen:Number;
      
      public var reflected:Boolean;
      
      public function BaseBullet()
      {
         super();
      }
      
      public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.reflected = false;
         this.frozen = 0;
         this.damage = dmg;
         this.traveled = 0;
      }
      
      public function LineOfSight(me:FlxSprite, you:FlxSprite) : Boolean
      {
         return Global.level.GetLayer(Level.LAYER_SOLID).ray(new FlxPoint(me.x + me.width / 2,me.y + me.height / 2),new FlxPoint(you.x + you.width / 2,you.y + you.height / 2),null,1);
      }
      
      public function TargetPlayer(side:int = 0, throughWalls:Boolean = false) : Pedro
      {
         return null;
      }
      
      override public function update() : void
      {
         if(this.frozen > 0)
         {
            color = 5605631;
            this.frozen -= FlxG.elapsed;
            if(isTouching(ANY))
            {
               this.frozen = 0;
               hurt(1);
            }
         }
         else
         {
            color = 16777215;
         }
         super.update();
         this.traveled += Math.abs(velocity.x * FlxG.elapsed) + Math.abs(velocity.y * FlxG.elapsed);
         if(x < -width || y < -height || x > Global.level.width * 16 || y > Global.level.height * 16)
         {
            exists = false;
         }
      }
      
      public function Freeze(time:Number) : void
      {
         this.frozen = time;
         velocity.x = 0;
         velocity.y = 0;
         acceleration.y = 400;
      }
   }
}

