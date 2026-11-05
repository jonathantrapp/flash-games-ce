package xplor.Bullet
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.BaseMonster;
   import xplor.Monster.Hungry;
   
   public class BoulderDrop extends BaseBullet
   {
      
      public var done:Boolean;
      
      public var range:Number;
      
      public var victims:Array;
      
      public var inAir:Boolean;
      
      public var airSkip:Number;
      
      public function BoulderDrop()
      {
         super();
         loadGraphic(Boulder.RockImage,true,false,16,16,true);
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
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = false;
         this.done = false;
         alpha = 1;
         scale.x = 1;
         scale.y = 1;
         angle = Global.randRange(0,360);
         acceleration.y = 350;
         velocity.y = 0;
         maxVelocity.y = 250;
         if(Global.randRange(0,1) < 0.5)
         {
            velocity.x = Global.randRange(0,10);
            angularVelocity = 200;
         }
         else
         {
            velocity.x = -Global.randRange(0,10);
            angularVelocity = -200;
         }
         play("fly");
         this.inAir = false;
         this.airSkip = 0.25;
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
         if(param2.health > 0 && Profile.skills[SkillDef.FLATTEN] > 0 && !(param2 is Hungry))
         {
            (param2 as BaseMonster).Flatten(Profile.skills[SkillDef.FLATTEN] * 0.2);
         }
      }
      
      override public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         super.update();
         if(this.airSkip > 0)
         {
            this.airSkip -= FlxG.elapsed;
         }
         if(!this.done)
         {
            if(Profile.skills[SkillDef.FREE_PEBBLES])
            {
               Global.badguys.TowerLoad(this);
            }
            if(this.airSkip <= 0)
            {
               _loc1_ = (x + width / 2) / 16;
               _loc2_ = (y + height / 2) / 16;
               _loc3_ = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,_loc2_));
               if(this.inAir)
               {
                  if(_loc3_ != 0)
                  {
                     velocity.y = -30;
                     velocity.x = Global.randRange(0,10);
                     angularVelocity = -angularVelocity;
                     if(angularVelocity < 0)
                     {
                        velocity.x = -velocity.x;
                     }
                     this.inAir = false;
                     this.airSkip = 0.25;
                  }
               }
               else if(_loc3_ == 0)
               {
                  this.inAir = true;
                  this.airSkip = 0.25;
               }
            }
            solid = true;
            FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.Hit);
            solid = false;
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

