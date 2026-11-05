package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Global;
   
   public class Barrier_Orb extends BaseMonster
   {
      
      public static var YakImage:Class = Barrier_Orb_YakImage;
      
      public function Barrier_Orb(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,11,20,true);
         addAnimation("idle",[0,1,2],10,true);
         width = 11;
         offset.x = 0;
         speed = 15;
         height = 14;
         offset.y = 5;
         name = "Barrier Orb";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 20;
      }
      
      public static function Money(lvl:int) : int
      {
         return 5;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         throwable = false;
         noReaction = true;
         play("idle");
      }
      
      public function UpdateHitStun() : void
      {
         trace("this shouldn\'t be");
      }
      
      override public function BasicUpdate() : void
      {
         super.BasicUpdate();
         play("idle");
         velocity.x = 0;
         velocity.y = 0;
         acceleration.x = 0;
         acceleration.y = 0;
      }
      
      override public function hurt(n:Number) : void
      {
         super.hurt(n);
         if(exists == false)
         {
            Global.badguys.BarrierTags(tag);
         }
      }
      
      override public function update() : void
      {
         if(alpha < 1)
         {
            alpha += FlxG.elapsed;
         }
         if(frozen != 0)
         {
            frozen = 0;
         }
         if(flattened != 0)
         {
            flattened = 0;
         }
         super.update();
      }
   }
}

