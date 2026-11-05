package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Global;
   import xplor.Pedro;
   import xplor.Sounds;
   
   public class Barrier extends BaseGuy
   {
      
      public static var TentImage:Class = Barrier_TentImage;
      
      public function Barrier(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(TentImage,true,true,5,38,true);
         height = 32;
         offset.y = 3;
         width = 11;
         offset.x = -3;
         this.Init(tx,ty);
         addAnimation("idle",[0,1,2,3],20,true);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function Reset() : void
      {
         super.Reset();
      }
      
      override public function set facing(value:uint) : void
      {
         super.facing = value;
      }
      
      public function Smack(me:BaseGuy, you:Pedro) : void
      {
         if(you.ouch <= 0)
         {
            Sounds.play(Sounds.BarrierShockSnd);
            you.hurt(1);
            if(you.x + you.width / 2 > x + width / 2)
            {
               if(you.x < x + width)
               {
                  you.x = x + width;
               }
               you.Knockback(RIGHT,100,-100);
            }
            else
            {
               if(you.x + you.width > x)
               {
                  you.x = x - you.width;
               }
               you.Knockback(LEFT,100,-100);
            }
         }
         if(you.x + you.width / 2 > x + width / 2)
         {
            if(you.x < x + width)
            {
               you.x = x + width;
            }
         }
         else if(you.x + you.width > x)
         {
            you.x = x - you.width;
         }
      }
      
      override public function update() : void
      {
         play("idle");
         FlxG.overlap(this,Global.pedro,this.Smack);
      }
   }
}

