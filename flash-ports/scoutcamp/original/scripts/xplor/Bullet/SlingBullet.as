package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.BaseMonster;
   import xplor.Monster.Hungry;
   
   public class SlingBullet extends BaseBullet
   {
      
      public static var RockImage:Class = SlingBullet_RockImage;
      
      public var done:Boolean;
      
      public var range:Number;
      
      public function SlingBullet()
      {
         super();
         loadGraphic(RockImage,true,false,8,8,true);
         addAnimation("fly",[0],20,true);
         addAnimation("pop",[1,2,3,4],20,false);
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.damage = param4;
         traveled = 0;
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
         this.range = 100000;
         velocity.x = Global.Cosine(param3) * 200;
         velocity.y = Global.Sine(param3) * 200;
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
         var _loc3_:Number = damage;
         if((param2 as BaseMonster).frozen > 0 || (param2 as BaseMonster).slowed > 0)
         {
            _loc3_ *= 1 + Profile.skills[SkillDef.SHATTER] * 0.05;
         }
         (param2 as BaseMonster).hurt(_loc3_);
         if(!(param2 is Hungry) && Global.randRange(0,1) < Profile.skills[SkillDef.CONFUSION] * 0.02)
         {
            (param2 as BaseMonster).facing = LEFT + RIGHT - (param2 as BaseMonster).facing;
         }
         param1.hurt(1);
      }
      
      override public function update() : void
      {
         var _loc1_:Number = NaN;
         super.update();
         if(!this.done)
         {
            if(target != null && target.exists && target.health > 0 && !(target as BaseMonster).immune)
            {
               _loc1_ = Global.AngleBetweenGuys(this,target);
               velocity.x = Global.Cosine(_loc1_) * 200;
               velocity.y = Global.Sine(_loc1_) * 200;
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

