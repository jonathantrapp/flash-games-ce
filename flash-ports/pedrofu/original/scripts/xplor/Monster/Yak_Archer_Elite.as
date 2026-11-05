package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Bullet.ArmorBit;
   import xplor.Bullet.Arrow;
   import xplor.Bullet.FireBit;
   import xplor.Bullets;
   import xplor.Global;
   import xplor.Sounds;
   
   public class Yak_Archer_Elite extends BaseMonster
   {
      
      public static var YakImage:Class = Yak_Archer_Elite_YakImage;
      
      public static const RELOADING:int = 2;
      
      public static const RAPIDFIRE:int = 3;
      
      public static const ENRAGE:int = 4;
      
      public var fireTime:Number;
      
      public var rapidFire:Number;
      
      public var rapidHasFired:Boolean;
      
      public var rapidReload:Number;
      
      public function Yak_Archer_Elite(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,22,19,true);
         addAnimation("idle",[0],10,true);
         addAnimation("walk",[0],10,true);
         addAnimation("hitstun",[7],10,true);
         addAnimation("reload",[1,2,3,4,5,6],12,true);
         addAnimation("disabled",[0],10,true);
         addAnimation("rapidfire",[0,1,2,3,4,5,6],30,true);
         addAnimation("enrage",[8,9],30,true);
         width = 10;
         offset.x = 6;
         speed = 15;
         height = 14;
         offset.y = 4;
         name = "Elite Archer";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 20;
      }
      
      public static function Money(lvl:int) : int
      {
         return 70;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function hurt(n:Number) : void
      {
         n *= 0.25;
         reload = 1;
         if(this.rapidReload < 3)
         {
            this.rapidReload = 3;
         }
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
         this.rapidReload = 10;
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
               reload = 2;
            }
         }
         this.rapidReload -= FlxG.elapsed;
         if(this.rapidReload <= 0 && action == IDLE)
         {
            action = ENRAGE;
            play("enrage");
            if(onScreen())
            {
               Sounds.play(Sounds.EnrageSnd);
            }
            this.rapidHasFired = false;
            this.rapidFire = 1;
         }
      }
      
      public function UpdateHitStun() : void
      {
         var g:Yak_Archer = null;
         var i:int = 0;
         stunned -= FlxG.elapsed;
         if(stunned <= 0)
         {
            if(isTouching(DOWN))
            {
               action = RELOADING;
               play("reload");
               reload = 1;
               if(this.rapidReload < 3)
               {
                  this.rapidReload = 3;
               }
               if(shouldShatter)
               {
                  exists = false;
                  g = Global.badguys.AddGuy(Yak_Archer,Badguys.DEADLY,0,0) as Yak_Archer;
                  g.x = x;
                  g.y = y;
                  g.tag = tag;
                  g.health = health * g.maxHealth / maxHealth;
                  for(i = 0; i < 8; i++)
                  {
                     Global.bullets.AddBullet(ArmorBit,Bullets.NEUTRAL,x + width / 2,y + height / 2,Global.randRange(0,360),0);
                  }
               }
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
      
      public function UpdateRapidFire() : void
      {
         var a:Number = NaN;
         this.rapidFire -= FlxG.elapsed;
         this.rapidReload = 10;
         if(Global.pedro.x + Global.pedro.width / 2 < x + width / 2)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         if(_curFrame == 6 && this.rapidFire <= 0)
         {
            action = RELOADING;
            play("reload");
            reload = 2;
            return;
         }
         if(_curFrame == 0 && onScreen())
         {
            if(!this.rapidHasFired)
            {
               this.rapidHasFired = true;
               a = Global.AngleBetweenGuys(this,Global.pedro);
               Sounds.play(Sounds.RapidFireSnd);
               Global.bullets.AddBullet(Arrow,Bullets.EVIL,x + width / 2,y + height / 2,a,2);
            }
         }
         else
         {
            this.rapidHasFired = false;
         }
      }
      
      public function UpdateEnrage() : void
      {
         this.rapidFire -= FlxG.elapsed;
         this.rapidReload = 10;
         if(Global.pedro.x + Global.pedro.width / 2 < x + width / 2)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         if(this.rapidFire <= 0)
         {
            action = RAPIDFIRE;
            play("rapidfire");
            this.rapidFire = 2;
            this.rapidHasFired = false;
         }
      }
      
      override public function BasicUpdate() : void
      {
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
         else if(action == RAPIDFIRE)
         {
            this.UpdateRapidFire();
         }
         else if(action == ENRAGE)
         {
            this.UpdateEnrage();
         }
      }
      
      override public function Knockback(facing:int, xspd:Number, yspd:Number) : void
      {
         super.Knockback(facing,xspd * 0.5,yspd * 0.5);
      }
   }
}

