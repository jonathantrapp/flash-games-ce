package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.BaseMonster;
   
   public class Snowball extends BaseBullet
   {
      
      public static var RockImage:Class = Snowball_RockImage;
      
      public var done:Boolean;
      
      public var range:Number;
      
      public function Snowball()
      {
         super();
         loadGraphic(RockImage,true,false,5,5,true);
         addAnimation("fly",[0],20,true);
         addAnimation("pop",[1,2,3,4],20,false);
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.damage = param4;
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = false;
         this.done = false;
         alpha = 1;
         scale.x = 1.5;
         scale.y = 1.5;
         angle = 0;
         velocity.x = Global.Cosine(param3) * 160;
         velocity.y = Global.Sine(param3) * 160;
         if(velocity.x > 0)
         {
            angularVelocity = 200;
         }
         else
         {
            angularVelocity = -200;
         }
         play("fly");
      }
      
      override public function hurt(param1:Number) : void
      {
         if(!this.done)
         {
            this.done = true;
            play("pop");
            velocity.x = 0;
            velocity.y = 0;
            solid = false;
         }
      }
      
      public function Freeze(param1:FlxObject, param2:FlxObject) : void
      {
         (param2 as BaseMonster).Slow(power,damage,Global.randRange(0,1) < Profile.skills[SkillDef.BRAINFREEZE] * 0.08);
         param1.hurt(1);
      }
      
      override public function update() : void
      {
         super.update();
         if(!this.done)
         {
            scale.x -= FlxG.elapsed;
            if(scale.x <= 0.1)
            {
               scale.x = 0.1;
            }
            scale.y = scale.x;
            if(target != null && target.exists && target.health > 0)
            {
               solid = true;
               FlxG.overlap(this,target,this.Freeze);
               solid = false;
            }
            if(traveled > this.range || target == null)
            {
               alpha -= FlxG.elapsed * 2;
               if(alpha <= 0)
               {
                  exists = false;
               }
            }
         }
         else if(finished)
         {
            exists = false;
         }
      }
   }
}

