package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   
   public class Yakolyte extends BaseMonster
   {
      
      public static var YakImage:Class = Yakolyte_YakImage;
      
      public static const CASTING:int = 2;
      
      public var punchedYet:Boolean;
      
      public var fireTime:Number;
      
      public var aimx:Number;
      
      public var aimy:Number;
      
      public function Yakolyte(tx:int, ty:int)
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
         name = "Yakolyte";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 30;
      }
      
      public static function Money(lvl:int) : int
      {
         return 30;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function hurt(n:Number) : void
      {
         if(reload < 2)
         {
            reload = 2;
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
         if(dist < 100 && (facing == LEFT && Global.pedro.x + Global.pedro.width / 2 < x + width / 2 || facing == RIGHT && Global.pedro.x + Global.pedro.width / 2 > x + width / 2))
         {
            if(reload <= 0)
            {
               play("cast");
               if(onScreen())
               {
                  Sounds.play(Sounds.MagicSnd);
               }
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
         var tx:int = 0;
         var ty:int = 0;
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
               Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,this.aimx + Global.randRange(-8,8),this.aimy,270,0);
            }
         }
         tx = this.aimx / 16;
         ty = this.aimy / 16;
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx,ty) == 0)
         {
            this.aimy += 2;
         }
         if(_curFrame == 8 && !this.punchedYet)
         {
            this.punchedYet = true;
            Global.bullets.AddBullet(GroundFire,Bullets.NEUTRAL,this.aimx,this.aimy - 8,0,0);
         }
         if(finished)
         {
            action = IDLE;
            play("walk");
         }
      }
      
      public function UpdateHitStun() : void
      {
         stunned -= FlxG.elapsed;
         if(stunned <= 0)
         {
            if(isTouching(DOWN))
            {
               action = IDLE;
               play("walk");
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
   }
}

