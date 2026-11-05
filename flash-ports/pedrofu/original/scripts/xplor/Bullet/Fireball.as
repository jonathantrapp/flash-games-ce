package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.BaseGuy;
   
   public class Fireball extends BaseBullet
   {
      
      public static var ArrowImage:Class = Fireball_ArrowImage;
      
      public var fireTime:Number;
      
      public var life:Number;
      
      public function Fireball()
      {
         super();
         loadGraphic(ArrowImage,true,false,13,7,true);
         width = 7;
         offset.x = 3;
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         reflected = false;
         frozen = 0;
         this.damage = Profile.skills[SkillDef.BURNINGFURY] * 0.5;
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = true;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         angle = a;
         velocity.x = Global.Cosine(a) * 100;
         velocity.y = Global.Sine(a) * 100;
         acceleration.x = 0;
         acceleration.y = 0;
         this.fireTime = 0;
         target = null;
         this.life = 8;
      }
      
      override public function hurt(n:Number) : void
      {
         exists = false;
         for(var i:int = 0; i < 8; i++)
         {
            Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + width / 2,y + height / 2,Global.randRange(0,360),0);
         }
      }
      
      public function Hit(me:FlxObject, you:FlxObject) : void
      {
         you.hurt(damage);
         this.hurt(1);
      }
      
      override public function update() : void
      {
         super.update();
         this.life -= FlxG.elapsed;
         if(this.life <= 0)
         {
            this.hurt(1);
         }
         FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.Hit);
         if(isTouching(ANY))
         {
            this.hurt(1);
         }
         this.fireTime -= FlxG.elapsed;
         if(this.fireTime <= 0)
         {
            target = Global.badguys.TargetEnemy(this,0) as BaseGuy;
            Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + width / 2,y + height / 2,Global.randRange(0,360),0);
            this.fireTime += 0.1;
         }
         velocity.x = Global.Cosine(angle) * 100;
         velocity.y = Global.Sine(angle) * 100;
         if(target != null)
         {
            angle = Global.TurnToward(angle,Global.AngleBetweenGuys(this,target),FlxG.elapsed * 360);
         }
      }
   }
}

