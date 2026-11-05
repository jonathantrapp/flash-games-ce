package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Bullet.Boom;
   import xplor.Bullet.FireBit;
   import xplor.Bullets;
   import xplor.Global;
   
   public class Blimp extends BaseMonster
   {
      
      public static var BlimpImage:Class = Blimp_BlimpImage;
      
      public var chute:Boolean;
      
      public function Blimp(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(BlimpImage,false,false,320,62,true);
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         super.Init(tx,ty);
         y -= 123;
      }
      
      override public function Reset() : void
      {
         super.Reset();
         acceleration.y = 0;
         velocity.y = 15;
         velocity.x = 60;
         FlxG.camera.follow(this);
         this.chute = false;
      }
      
      override public function BasicUpdate() : void
      {
         if(y >= 0)
         {
            velocity.y = 0;
            y = 0;
         }
         if(x > FlxG.camera.scroll.x + 320)
         {
            exists = false;
         }
         else
         {
            Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + Global.randRange(103,201),y + Global.randRange(20,59),180,1);
            if(Global.randRange(0,1) < FlxG.elapsed * 5)
            {
               Global.bullets.AddBullet(Boom,Bullets.NEUTRAL,x + Global.randRange(103,201),y + Global.randRange(20,59),0,0);
            }
            if(x > 16 * 24 - 160 && !this.chute)
            {
               this.chute = true;
               Global.badguys.AddGuy(PedroChute,Badguys.NEUTRAL,24,1);
            }
         }
      }
   }
}

