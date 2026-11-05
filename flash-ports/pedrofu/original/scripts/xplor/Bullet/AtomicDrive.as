package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.BaseMonster;
   
   public class AtomicDrive extends BaseBullet
   {
      
      public var fireTime:Number;
      
      public var burnedYet:Boolean;
      
      public function AtomicDrive()
      {
         super();
         loadGraphic(GroundFire.ArrowImage,true,false,16,16,true);
         addAnimation("burn",[0,1,2,3,4,5,6,7,8,9],14,false);
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         frozen = 0;
         this.damage = 1;
         scale.x = (16 + Profile.skills[SkillDef.ATOMICPILEDRIVER] * 8) / 16;
         width = 16 * scale.x;
         offset.x = 8 - width / 2;
         this.x = x - width / 2;
         this.y = y - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         scale.y = 1;
         angle = a;
         velocity.x = 0;
         velocity.y = 0;
         acceleration.y = 0;
         play("burn",true);
         this.burnedYet = false;
      }
      
      override public function hurt(n:Number) : void
      {
      }
      
      public function Hit(me:FlxObject, you:BaseMonster) : void
      {
         you.hurt(SkillDef.AtomicDamage());
         if(you.x + you.width / 2 < Global.pedro.x + Global.pedro.width / 2)
         {
            you.Knockback(LEFT,90,-90);
         }
         else
         {
            you.Knockback(RIGHT,90,-90);
         }
      }
      
      override public function update() : void
      {
         super.update();
         if(frozen > 0 || finished)
         {
            exists = false;
            return;
         }
         if(_curFrame >= 1 && !this.burnedYet)
         {
            solid = true;
            FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.Hit);
            solid = false;
            this.burnedYet = true;
         }
      }
   }
}

