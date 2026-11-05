package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.BaseMonster;
   
   public class Rock extends BaseBullet
   {
      
      public static var RockImage:Class = Rock_RockImage;
      
      public var done:Boolean;
      
      public var range:Number;
      
      public var shockPower:Number;
      
      public function Rock()
      {
         super();
         loadGraphic(RockImage,true,false,5,5,true);
         addAnimation("fly",[0],20,true);
         addAnimation("flyshock",[5],20,true);
         addAnimation("pop",[1,2,3,4],20,false);
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.damage = param4;
         traveled = 0;
         this.range = 100;
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = false;
         this.done = false;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         angle = 0;
         this.shockPower = 0;
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
      
      public function Hit(param1:FlxObject, param2:FlxObject) : void
      {
         if((param2 as BaseMonster).immune)
         {
            return;
         }
         if(this.shockPower > 0)
         {
            (param2 as BaseMonster).Shock(Profile.skills[SkillDef.SHOCKER] * 2,this.shockPower);
         }
         var _loc3_:Number = damage;
         if((param2 as BaseMonster).frozen > 0 || (param2 as BaseMonster).slowed > 0)
         {
            _loc3_ *= 1 + Profile.skills[SkillDef.SHATTER] * 0.05;
         }
         (param2 as BaseMonster).hurt(_loc3_);
         if(Profile.skills[SkillDef.GATHEREDMOSS])
         {
            (param2 as BaseMonster).Poison();
         }
         param1.hurt(1);
      }
      
      override public function update() : void
      {
         super.update();
         if(!this.done)
         {
            if(this.shockPower > 0)
            {
               play("flyshock");
            }
            if(target != null && target.exists && target.health > 0)
            {
               solid = true;
               FlxG.overlap(this,target,this.Hit);
               solid = false;
            }
            else
            {
               target = null;
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

