package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   
   public class Iron_Priest extends BaseMonster
   {
      
      public static var YakImage:Class = Iron_Priest_YakImage;
      
      public static const CASTING:int = 2;
      
      public var punchedYet:Boolean;
      
      public var fireTime:Number;
      
      public var aimx:Number;
      
      public var aimy:Number;
      
      public function Iron_Priest(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,20,20,true);
         addAnimation("idle",[0],10,true);
         addAnimation("walk",[0,1,2,3,0,4,5,6],10,true);
         addAnimation("hitstun",[9],10,true);
         addAnimation("disabled",[0],10,true);
         addAnimation("talk",[0],10,true);
         addAnimation("cast",[7,8,8,8,8,8,8,8,8,8,7],10,false);
         width = 12;
         offset.x = 4;
         speed = 15;
         height = 14;
         offset.y = 5;
         name = "Iron Monk";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 30;
      }
      
      public static function Money(lvl:int) : int
      {
         return 80;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function hurt(n:Number) : void
      {
         reload = 4;
         n *= 0.25;
         super.hurt(n);
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         reload = 4;
      }
      
      public function UpdateIdle() : void
      {
         var tx:int = 0;
         var ty:int = 0;
         tx = (x + width / 2) / Global.TILE_WIDTH;
         ty = (y + height / 2) / Global.TILE_HEIGHT;
         var p:int = int(Global.level.jumps[tx + ty * Global.level.width]);
         if(p == 10)
         {
            facing = RIGHT;
         }
         else if(p == 11)
         {
            facing = LEFT;
         }
         else if(isTouching(WALL))
         {
            facing = LEFT + RIGHT - facing;
         }
         velocity.x = 20 - 40 * int(facing == LEFT);
         play("walk");
         var dist:Number = DistanceToGuy(Global.pedro);
         if(dist < 150)
         {
            if(reload <= 0)
            {
               if(onScreen())
               {
                  Sounds.play(Sounds.MagicSnd);
               }
               play("cast");
               this.fireTime = 0;
               action = CASTING;
               this.punchedYet = false;
               this.aimx = Global.pedro.x + Global.pedro.width / 2;
               this.aimy = Global.pedro.y + Global.pedro.height;
               velocity.x = 0;
            }
         }
      }
      
      public function UpdateCasting() : void
      {
         velocity.x = 0;
         reload = 4;
         if(_curFrame >= 1 && _curFrame <= 9)
         {
            this.fireTime += FlxG.elapsed;
            if(this.fireTime > 0.1)
            {
               this.fireTime -= 0.1;
               if(onScreen())
               {
                  Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + width + 4 - (width + 4 + 4) * int(facing == LEFT),y - 2,Global.randRange(0,360),0);
               }
            }
         }
         if(_curFrame == 8 && !this.punchedYet)
         {
            this.punchedYet = true;
            Sounds.play(Sounds.MissileSnd);
            Global.bullets.AddBullet(BadFireball,Bullets.EVIL,x + width + 4 - (width + 4 + 4) * int(facing == LEFT),y - 2,225,0);
            Global.bullets.AddBullet(BadFireball,Bullets.EVIL,x + width + 4 - (width + 4 + 4) * int(facing == LEFT),y - 2,315,0);
         }
         if(finished)
         {
            action = IDLE;
            play("walk");
         }
      }
      
      public function UpdateHitStun() : void
      {
         var g:Yakolyte = null;
         var i:int = 0;
         stunned -= FlxG.elapsed;
         if(stunned <= 0)
         {
            if(isTouching(DOWN))
            {
               action = IDLE;
               play("walk");
               reload = 4;
               if(shouldShatter)
               {
                  exists = false;
                  g = Global.badguys.AddGuy(Yakolyte,Badguys.DEADLY,0,0) as Yakolyte;
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
         else if(action == CASTING)
         {
            this.UpdateCasting();
         }
      }
      
      override public function Knockback(facing:int, xspd:Number, yspd:Number) : void
      {
         super.Knockback(facing,xspd * 0.5,yspd * 0.5);
      }
   }
}

