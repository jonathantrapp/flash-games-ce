package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   
   public class Yak_Big extends BaseMonster
   {
      
      public static var YakImage:Class = Yak_Big_YakImage;
      
      public static const SMASH:int = 2;
      
      public static const SIT:int = 3;
      
      public var punchedYet:Boolean;
      
      public var state:int;
      
      public var lastTurn:Number;
      
      public var plan:Array = new Array(IDLE,4,JUMP,0,SIT,2,JUMP,0,SIT,2,JUMP,0,SIT,2,IDLE,2,SMASH,0,IDLE,2,SMASH,0);
      
      public function Yak_Big(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,38,32,true);
         addAnimation("idle",[0],10,true);
         addAnimation("walk",[0,1,0,2],10,true);
         addAnimation("jumpup",[2],10,true);
         addAnimation("jumpdn",[1],10,true);
         addAnimation("hitstun",[0],10,true);
         addAnimation("disabled",[0],10,true);
         addAnimation("talk",[0],10,true);
         addAnimation("smash",[8,7,6,6,6,6,6,5,4,3],10,false);
         addAnimation("sit",[9],10,true);
         width = 20;
         offset.x = 9;
         speed = 15;
         height = 30;
         offset.y = 0;
         name = "Torgo";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 200;
      }
      
      public static function Money(lvl:int) : int
      {
         return 150;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         throwable = false;
         noReaction = true;
         reload = this.plan[1];
         this.state = 0;
         action = this.plan[0];
      }
      
      public function ProcessPlan() : void
      {
         if(action == IDLE && reload <= 0)
         {
            this.state += 2;
            if(this.state >= this.plan.length)
            {
               this.state = 0;
            }
            reload = this.plan[this.state + 1];
            action = this.plan[this.state];
            if(action != SIT)
            {
               if(Global.pedro.x + Global.pedro.width / 2 < x + width / 2)
               {
                  facing = LEFT;
               }
               else
               {
                  facing = RIGHT;
               }
            }
            switch(action)
            {
               case IDLE:
                  play("walk");
                  this.lastTurn = reload;
                  break;
               case JUMP:
                  Sounds.play(Sounds.BigJumpSnd);
                  play("jumpup");
                  velocity.y = -200;
                  velocity.x = 80 - 160 * int(facing == LEFT);
                  break;
               case SIT:
                  play("sit");
                  velocity.x = 0;
                  break;
               case SMASH:
                  play("smash");
                  this.punchedYet = false;
                  velocity.x = 0;
            }
         }
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
         if(reload <= this.lastTurn - 1)
         {
            if(Global.pedro.x + Global.pedro.width / 2 < x + width / 2)
            {
               facing = LEFT;
            }
            else
            {
               facing = RIGHT;
            }
            this.lastTurn = reload;
         }
         velocity.x = 20 - 40 * int(facing == LEFT);
         play("walk");
      }
      
      public function UpdateJump() : void
      {
         var i:int = 0;
         velocity.x = 80 - 160 * int(facing == LEFT);
         if(velocity.y < 0)
         {
            play("jumpup");
         }
         else
         {
            play("jumpdn");
         }
         if(isTouching(DOWN) && velocity.y >= 0)
         {
            action = IDLE;
            Sounds.play(Sounds.StompSnd);
            FlxG.camera.shake(0.05,0.1);
            Global.pedro.rockSpiked = false;
            for(i = 0; i < 6; i++)
            {
               Global.bullets.AddBullet(RockSpike,Bullets.EVIL,x + width / 2 - 2.5 * 12 + i * 12,y + height - 9,0,1);
            }
         }
      }
      
      public function UpdateSmash() : void
      {
         if(_curFrame == 7 && !this.punchedYet)
         {
            FlxG.camera.shake(0.05,0.1);
            this.punchedYet = true;
            Sounds.play(Sounds.StompSnd);
            Global.pedro.rockSpiked = false;
            Global.bullets.AddBullet(RockSpike,Bullets.EVIL,x + width / 2,y + height - 9,1 + int(facing == LEFT),1);
         }
         if(finished)
         {
            action = IDLE;
         }
      }
      
      public function UpdateSit() : void
      {
         play("sit");
         if(reload <= 0)
         {
            action = IDLE;
         }
      }
      
      public function UpdateHitStun() : void
      {
         trace("this shouldn\'t be");
      }
      
      override public function BasicUpdate() : void
      {
         super.BasicUpdate();
         this.ProcessPlan();
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
         else if(action == JUMP)
         {
            this.UpdateJump();
         }
         else if(action == SMASH)
         {
            this.UpdateSmash();
         }
         else if(action == SIT)
         {
            this.UpdateSit();
         }
      }
      
      public function IntroLaunch() : void
      {
         Sounds.play(Sounds.BigJumpSnd);
         action = JUMP;
         velocity.y = -200;
         facing = LEFT;
         velocity.x = -80;
      }
   }
}

