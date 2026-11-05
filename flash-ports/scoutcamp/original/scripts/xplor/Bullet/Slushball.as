package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.BaseMonster;
   
   public class Slushball extends BaseBullet
   {
      
      public static var RockImage:Class = Slushball_RockImage;
      
      public var done:Boolean;
      
      public var range:Number;
      
      public function Slushball()
      {
         super();
         loadGraphic(RockImage,true,false,9,15,true);
         height = 5;
         offset.y = 5;
         addAnimation("fly",[0,1,2,3,2,1],20,true);
         addAnimation("pop",[1],20,false);
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
         scale.x = 0.25;
         scale.y = 0.5;
         angle = 0;
         acceleration.y = 0;
         velocity.x = Global.randRange(-5,5);
         velocity.y = 150;
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
         if((param2 as BaseMonster).immune)
         {
            return;
         }
         if((param2 as BaseMonster).slowed <= 0 && Profile.skills[SkillDef.BLUERAZZ] > 0)
         {
            (param2 as BaseMonster).Freeze(Profile.skills[SkillDef.BLUERAZZ] * 0.1);
         }
         (param2 as BaseMonster).Slow(power,damage);
      }
      
      override public function update() : void
      {
         super.update();
         if(!this.done)
         {
            solid = true;
            FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.Freeze);
            solid = false;
            if(scale.x < 1)
            {
               scale.x += FlxG.elapsed;
               if(scale.x >= 1)
               {
                  scale.x = 1;
               }
            }
            if(scale.y < 2)
            {
               scale.y += FlxG.elapsed;
               if(scale.y >= 2)
               {
                  scale.y = 2;
               }
            }
            if(y > Global.level.height * 16)
            {
               exists = false;
            }
         }
         else if(finished)
         {
            exists = false;
         }
      }
   }
}

