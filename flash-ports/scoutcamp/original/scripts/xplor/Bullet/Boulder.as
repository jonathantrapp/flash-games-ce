package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.BaseMonster;
   
   public class Boulder extends BaseBullet
   {
      
      public static var RockImage:Class = Boulder_RockImage;
      
      public var done:Boolean;
      
      public var range:Number;
      
      public var victims:Array;
      
      public var lastX:Number;
      
      public var noPop:Number;
      
      public function Boulder()
      {
         super();
         loadGraphic(RockImage,true,false,16,16,true);
         addAnimation("fly",[0],20,true);
         addAnimation("pop",[1,2,3,4,5,6,7],20,false);
         width = 12;
         height = 12;
         offset.x = 2;
         offset.y = 2;
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.damage = param4;
         traveled = 0;
         this.noPop = 0.25;
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = true;
         this.done = false;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         angle = Global.randRange(0,360);
         acceleration.y = 200;
         velocity.y = 0;
         if(param3 == 0)
         {
            facing = RIGHT;
            velocity.x = 60;
         }
         else
         {
            facing = LEFT;
            velocity.x = -60;
         }
         if(velocity.x > 0)
         {
            angularVelocity = 200;
         }
         else
         {
            angularVelocity = -200;
         }
         this.lastX = -1000;
         play("fly");
         this.victims = new Array();
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
            angularVelocity = 0;
            angle = 0;
            acceleration.y = 0;
         }
      }
      
      public function Hit(param1:FlxObject, param2:FlxObject) : void
      {
         if((param2 as BaseMonster).immune)
         {
            return;
         }
         if(this.victims.indexOf(param2) >= 0)
         {
            return;
         }
         this.victims.push(param2);
         var _loc3_:Number = damage;
         if((param2 as BaseMonster).frozen > 0 || (param2 as BaseMonster).slowed > 0)
         {
            _loc3_ *= 1 + Profile.skills[SkillDef.BRITTLE_BONES] * 0.05;
         }
         (param2 as BaseMonster).hurt(_loc3_);
         if(param2.exists && Global.randRange(0,1) < Profile.skills[SkillDef.ROLLBACK] * 0.1)
         {
            (param2 as BaseMonster).Fling(facing);
         }
      }
      
      override public function update() : void
      {
         super.update();
         if(!this.done)
         {
            if(this.noPop > 0)
            {
               this.noPop -= FlxG.elapsed;
            }
            if(Profile.skills[SkillDef.FREE_PEBBLES])
            {
               Global.badguys.TowerLoad(this);
            }
            FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.Hit);
            if(this.noPop <= 0 && !this.done && (traveled > this.range || Math.abs(this.lastX - x) < FlxG.elapsed * velocity.x / 4 || velocity.x == 0))
            {
               this.hurt(1);
            }
            if(facing == RIGHT && !this.done)
            {
               velocity.x = 60;
            }
            else if(!this.done)
            {
               velocity.x = -60;
            }
            this.lastX = x;
         }
         else if(finished)
         {
            exists = false;
         }
      }
   }
}

