package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Bullet.NinjaStar;
   import xplor.Bullet.SmokePuff;
   import xplor.Bullets;
   import xplor.Global;
   import xplor.Level;
   import xplor.PlayState;
   import xplor.Sounds;
   
   public class Yak_Ninja extends BaseMonster
   {
      
      public static var YakImage:Class = Yak_Ninja_YakImage;
      
      public static const DIZZY:int = 2;
      
      public static const WALLHANG:int = 3;
      
      public static const THROW:int = 4;
      
      public static const HIDDEN:int = 5;
      
      public var fireTime:Number;
      
      public var dizzyTime:Number;
      
      public var thrown:Boolean;
      
      public var hangTime:Number;
      
      public var ghost:Number;
      
      public function Yak_Ninja(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,19,19,true);
         addAnimation("idle",[0],10,true);
         addAnimation("walk",[0,1,2,3],10,true);
         addAnimation("hitstun",[9],10,true);
         addAnimation("jump",[4],10,true);
         addAnimation("dizzy",[10,11],12,true);
         addAnimation("wallhang",[5],10,true);
         addAnimation("throw",[6,7,8,5],20,false);
         addAnimation("talk",[0,12],10,true);
         addAnimation("disabled",[0],10,true);
         width = 11;
         offset.x = 4;
         speed = 15;
         height = 14;
         offset.y = 4;
         name = "Ninja Yak";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 20;
      }
      
      public static function Money(lvl:int) : int
      {
         return 50;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function hurt(n:Number) : void
      {
         trace("ouch",this.ghost,this.dizzyTime,action);
         if(action == WALLHANG || action == THROW)
         {
            this.dizzyTime = 2;
         }
         if(this.ghost <= 0)
         {
            super.hurt(n);
         }
         acceleration.y = 400;
         if(this.dizzyTime <= 0)
         {
            this.ghost = 1;
            this.fireTime = 0;
            alpha = 0.5;
            action = IDLE;
            stunned = 0;
         }
         angle = 0;
         angularVelocity = 0;
         trace("ouch2",this.ghost,this.dizzyTime,action);
      }
      
      override public function Knockback(facing:int, xspd:Number, yspd:Number) : void
      {
         if(this.ghost <= 0)
         {
            super.Knockback(facing,xspd,yspd);
         }
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         reload = 0;
         this.fireTime = 0;
         action = HIDDEN;
         visible = false;
         this.dizzyTime = 0;
         this.ghost = 0;
      }
      
      public function UpdateIdle() : void
      {
         velocity.x = 0;
         if(this.fireTime > 0)
         {
            this.fireTime -= FlxG.elapsed;
         }
         else
         {
            if(Global.randRange(0,1) < 0.25)
            {
               facing = LEFT + RIGHT - facing;
            }
            action = JUMP;
            velocity.x = 80 - 160 * int(facing == LEFT);
            velocity.y = -200;
            angularVelocity = 360 - 720 * int(facing == LEFT);
            play("jump");
         }
      }
      
      public function UpdateHitStun() : void
      {
         acceleration.y = 400;
         stunned -= FlxG.elapsed;
         if(stunned <= 0)
         {
            if(isTouching(DOWN))
            {
               if(this.dizzyTime > 0)
               {
                  action = DIZZY;
                  play("dizzy");
                  velocity.x = 0;
                  return;
               }
               action = IDLE;
               play("idle");
               this.fireTime = 0.5;
               return;
            }
         }
         else if(isTouching(DOWN))
         {
            velocity.x = Global.Dampen(velocity.x,FlxG.elapsed * 40);
         }
      }
      
      public function UpdateJump() : void
      {
         if(isTouching(FLOOR))
         {
            angularVelocity = 0;
            action = IDLE;
            this.fireTime = 0.5;
            play("idle");
            angle = 0;
         }
         else if(isTouching(WALL))
         {
            angularVelocity = 0;
            action = WALLHANG;
            this.hangTime = 3.2;
            if(isTouching(LEFT))
            {
               facing = RIGHT;
            }
            else
            {
               facing = LEFT;
            }
            play("wallhang");
            angle = 0;
            velocity.y = 0;
            acceleration.y = 0;
            velocity.x = 0;
            this.fireTime = 1;
         }
      }
      
      public function UpdateDizzy() : void
      {
         if(this.dizzyTime <= 0)
         {
            action = IDLE;
            this.fireTime = 0.1;
            play("idle");
         }
      }
      
      public function UpdateWallHang() : void
      {
         this.fireTime -= FlxG.elapsed;
         if(this.fireTime <= 0)
         {
            Sounds.play(Sounds.RapidFireSnd);
            this.fireTime = 1;
            play("throw");
            action = THROW;
            this.thrown = false;
         }
         this.hangTime -= FlxG.elapsed;
         if(this.hangTime <= 0)
         {
            action = JUMP;
            angularVelocity = 360 - 720 * int(facing == LEFT);
            play("jump");
            acceleration.y = 400;
            velocity.x = 30 - 60 * int(facing == LEFT);
         }
      }
      
      public function UpdateThrow() : void
      {
         if(_curFrame == 2 && !this.thrown)
         {
            this.thrown = true;
            Global.bullets.AddBullet(NinjaStar,Bullets.EVIL,x + width / 2,y + height / 2,Global.AngleBetweenGuys(this,Global.pedro),1);
         }
         if(finished)
         {
            action = WALLHANG;
         }
      }
      
      public function Poof() : void
      {
         visible = true;
         Global.bullets.AddBullet(SmokePuff,Bullets.NEUTRAL,x + width / 2,y + height / 2,0,0);
         action = IDLE;
         this.fireTime = 0.5;
         play("idle");
      }
      
      public function UpdateHidden() : void
      {
         var g:BaseMonster = null;
         if(DistanceToGuy(Global.pedro) < 80 && LineOfSight(this,Global.pedro))
         {
            this.Poof();
            if(Global.levelNum == 4)
            {
               PlayState(FlxG.state).conversation.Setup(4,this);
               for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
               {
                  if(g is Yak_Ninja && g.action == HIDDEN)
                  {
                     (g as Yak_Ninja).Poof();
                  }
               }
               Global.level.GetLayer(Level.LAYER_SOLID).setTile(59,19,56);
               Global.level.GetLayer(Level.LAYER_SOLID).setTile(60,19,56);
            }
         }
      }
      
      override public function BasicUpdate() : void
      {
         super.BasicUpdate();
         if(reload > 0)
         {
            reload -= FlxG.elapsed;
         }
         if(this.ghost > 0)
         {
            this.ghost -= FlxG.elapsed;
         }
         else
         {
            alpha = 1;
         }
         if(this.dizzyTime > 0)
         {
            this.dizzyTime -= FlxG.elapsed;
         }
         if(action == HIDDEN)
         {
            this.UpdateHidden();
         }
         else if(action == HITSTUN)
         {
            this.UpdateHitStun();
         }
         else if(action == JUMP)
         {
            this.UpdateJump();
         }
         else if(action == IDLE)
         {
            this.UpdateIdle();
         }
         else if(action == DIZZY)
         {
            this.UpdateDizzy();
         }
         else if(action == WALLHANG)
         {
            this.UpdateWallHang();
         }
         else if(action == THROW)
         {
            this.UpdateThrow();
         }
      }
   }
}

