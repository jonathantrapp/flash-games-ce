package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   
   public class RockSpike extends BaseBullet
   {
      
      public static var SpikeImage:Class = RockSpike_SpikeImage;
      
      public var spread:int;
      
      public var mode:int;
      
      public function RockSpike()
      {
         super();
         loadGraphic(SpikeImage,true,false,13,22,true);
         height = 19;
         origin.y = 20;
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.damage = dmg;
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = true;
         alpha = 1;
         scale.x = 1;
         scale.y = 0.2;
         velocity.x = 0;
         velocity.y = 200;
         acceleration.y = 400;
         this.spread = a;
         this.mode = 0;
         frozen = 0;
      }
      
      override public function hurt(n:Number) : void
      {
      }
      
      public function Hit(me:FlxObject, you:FlxObject) : void
      {
         Global.pedro.hurt(2);
         Global.pedro.rockSpiked = true;
      }
      
      public function Spread(x:int, y:int) : void
      {
         var tx:int = 0;
         var ty:int = 0;
         if(Boolean(frozen))
         {
            return;
         }
         tx = (x + width / 2) / 16;
         ty = (y + height / 2) / 16;
         if(tx < 0 || tx >= Global.level.width)
         {
            return;
         }
         var t:int = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx,ty));
         if(t == 0 || Boolean((Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[t]))
         {
            Global.bullets.AddBullet(RockSpike,Bullets.EVIL,x + width / 2,y + height / 2,this.spread,1);
         }
      }
      
      override public function update() : void
      {
         super.update();
         if(this.mode == 0)
         {
            scale.y += FlxG.elapsed * 16;
            if(scale.y >= 1.5)
            {
               scale.y = 1.5;
               this.mode = 1;
            }
            if(frozen <= 0 && Global.pedro.rockSpiked == false)
            {
               if(Global.pedro.y + Global.pedro.height > y + height - height * scale.y && Global.pedro.x <= x + width && Global.pedro.x + Global.pedro.width >= x)
               {
                  this.Hit(this,Global.pedro);
               }
            }
         }
         else if(this.mode == 1)
         {
            switch(this.spread)
            {
               case 0:
                  break;
               case 1:
                  this.Spread(x + 12,y);
                  break;
               case 2:
                  this.Spread(x - 12,y);
            }
            this.mode = 2;
         }
         else
         {
            scale.y -= FlxG.elapsed * 2;
            if(scale.y <= 0.1)
            {
               exists = false;
            }
         }
      }
   }
}

