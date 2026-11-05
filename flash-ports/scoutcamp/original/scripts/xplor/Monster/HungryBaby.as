package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   
   public class HungryBaby extends BaseMonster
   {
      
      public static var HungryBabyImage:Class = HungryBaby_HungryBabyImage;
      
      public var bornSpeed:Number;
      
      public function HungryBaby(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(HungryBabyImage,true,true,12,17,true);
         addAnimation("walk",[0,1,2,1],10,true);
         addAnimation("jump",[3],10,true);
         addAnimation("disabledwalk",[0,1,2,1],10,true);
         addAnimation("disabledjump",[3],10,true);
         width = 5;
         offset.x = 3.5;
         height = 13;
         offset.y = 3;
         name = "Splut";
         speed = 35;
         this.Init(param1,param2);
      }
      
      public static function Life(param1:int) : int
      {
         return 5 + param1 * 1;
      }
      
      public static function Money(param1:int) : int
      {
         return 1 + param1 * 0.25;
      }
      
      override public function Init(param1:int, param2:int) : void
      {
         solid = true;
         super.Init(param1,param2);
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         color = 16777215;
         scale.x = 1;
         scale.y = 0.1;
         origin.y = frameHeight;
         this.bornSpeed = 1;
      }
      
      override public function DoneBeingBorn() : void
      {
         if(facing == RIGHT)
         {
            velocity.x = speed;
         }
         else
         {
            velocity.x = -speed;
         }
         acceleration.y = 200;
         velocity.y = 0;
         if(disabled > 0)
         {
            play("disabledwalk");
         }
         else
         {
            play("walk");
         }
      }
      
      override public function UpdateBorn() : void
      {
         scale.y += FlxG.elapsed * this.bornSpeed;
         if(scale.y >= 1)
         {
            origin.y = frameHeight;
            scale.x = 1;
            scale.y = 1;
            action = IDLE;
            angle = 0;
            this.DoneBeingBorn();
         }
      }
      
      override public function update() : void
      {
         super.update();
      }
   }
}

