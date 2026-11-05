package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Bullet.Arrow;
   import xplor.Bullet.FireBit;
   import xplor.Bullets;
   import xplor.Global;
   import xplor.PlayState;
   import xplor.Sounds;
   
   public class Yak_Archer extends BaseMonster
   {
      
      public static var YakImage:Class = Yak_Archer_YakImage;
      
      public static const RELOADING:int = 2;
      
      public var fireTime:Number;
      
      public var convoState:int;
      
      public function Yak_Archer(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,22,19,true);
         addAnimation("idle",[0],10,true);
         addAnimation("walk",[0],10,true);
         addAnimation("hitstun",[7],10,true);
         addAnimation("reload",[1,2,3,4,5,6],12,true);
         addAnimation("disabled",[0],10,true);
         addAnimation("talk",[0],10,true);
         width = 10;
         offset.x = 6;
         speed = 15;
         height = 14;
         offset.y = 4;
         name = "Yak Archer";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 5 + lvl * 6;
      }
      
      public static function Money(lvl:int) : int
      {
         return 10 + lvl * 1.5;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function hurt(n:Number) : void
      {
         reload = 1;
         super.hurt(n);
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         reload = 1;
         this.fireTime = 0;
         this.convoState = 0;
      }
      
      public function UpdateIdle() : void
      {
         var tx:int = 0;
         var ty:int = 0;
         var a:Number = NaN;
         velocity.x = 0;
         if(Global.pedro.x + Global.pedro.width / 2 < x + width / 2)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         if(onScreen())
         {
            this.fireTime -= FlxG.elapsed;
            if(this.fireTime <= 0)
            {
               this.fireTime += 0.1;
               Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x - 6 + (width + 12) * int(facing == RIGHT),y + height / 2,Global.randRange(250,290),0);
            }
            if(reload <= 0)
            {
               if(facing == LEFT)
               {
                  a = 200 - Global.randRange(0,20);
               }
               else
               {
                  a = 340 + Global.randRange(0,20);
               }
               Sounds.play(Sounds.ArrowShootSnd);
               Global.bullets.AddBullet(Arrow,Bullets.EVIL,x + width / 2,y + height / 2,a,1);
               action = RELOADING;
               play("reload");
               reload = 3;
            }
         }
      }
      
      public function UpdateHitStun() : void
      {
         stunned -= FlxG.elapsed;
         if(stunned <= 0)
         {
            if(isTouching(DOWN))
            {
               action = RELOADING;
               play("reload");
               reload = 1;
               return;
            }
         }
         else if(isTouching(DOWN))
         {
            velocity.x = Global.Dampen(velocity.x,FlxG.elapsed * 40);
         }
      }
      
      override public function FreeAgain() : void
      {
         super.FreeAgain();
         action = RELOADING;
         play("reload");
         reload = 1;
      }
      
      public function UpdateReload() : void
      {
         velocity.x = 0;
         if(finished)
         {
            action = IDLE;
            play("idle");
         }
      }
      
      override public function BasicUpdate() : void
      {
         if(Global.levelNum == 9 && tag == 2)
         {
            if(this.convoState == 0 && (Global.pedro.velocity.x < -1 || Global.pedro.velocity.x > 1))
            {
               PlayState(FlxG.state).conversation.Setup(6,this);
               this.convoState = 1;
            }
            else if(this.convoState == 1 && Global.pedro.y <= y + height && Global.pedro.action == IDLE)
            {
               PlayState(FlxG.state).conversation.Setup(7,this);
               this.convoState = 2;
            }
         }
         super.BasicUpdate();
         if(reload > 0)
         {
            reload -= FlxG.elapsed;
         }
         if(action == HITSTUN)
         {
            this.UpdateHitStun();
         }
         else if(action == IDLE)
         {
            this.UpdateIdle();
         }
         else if(action == RELOADING)
         {
            this.UpdateReload();
         }
      }
   }
}

