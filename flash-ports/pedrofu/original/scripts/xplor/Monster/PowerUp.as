package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Global;
   import xplor.Profile;
   
   public class PowerUp extends BaseGuy
   {
      
      public static var PowerUpImage:Class = PowerUp_PowerUpImage;
      
      public var which:int;
      
      public var realY:Number;
      
      public var noGet:Number;
      
      public var expire:Number;
      
      public var done:Boolean;
      
      public function PowerUp(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(PowerUpImage,true,false,16,16,true);
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function Reset() : void
      {
         super.Reset();
         this.realY = y;
         y -= 2;
         alpha = 1;
         acceleration.y = 10;
         this.noGet = 0.5;
         this.expire = 20;
         this.done = false;
      }
      
      override public function update() : void
      {
         if(this.done)
         {
            scale.x += FlxG.elapsed * 4;
            scale.y += FlxG.elapsed * 4;
            alpha -= FlxG.elapsed * 1.5;
            if(alpha <= 0)
            {
               exists = false;
            }
         }
         if(frame != this.which)
         {
            frame = this.which;
         }
         if(this.which == 7)
         {
            if(this.expire > 0)
            {
               this.expire -= FlxG.elapsed;
            }
            else
            {
               alpha -= FlxG.elapsed;
               if(alpha == 0)
               {
                  exists = false;
               }
            }
         }
         super.update();
         solid = true;
         if(this.noGet > 0)
         {
            this.noGet -= FlxG.elapsed;
         }
         if(!this.done && this.noGet <= 0 && DistanceToGuy(Global.pedro) < 16)
         {
            if(this.which != 7 || Global.pedro.health < Profile.max_life)
            {
               Profile.GetPowerUp(this.which);
               this.done = true;
            }
         }
         solid = false;
         if(y > this.realY)
         {
            acceleration.y = -10;
         }
         else if(y < this.realY)
         {
            acceleration.y = 10;
         }
         if(y < this.realY - 3)
         {
            y = this.realY - 3;
         }
         if(y > this.realY + 3)
         {
            y = this.realY + 3;
         }
      }
   }
}

