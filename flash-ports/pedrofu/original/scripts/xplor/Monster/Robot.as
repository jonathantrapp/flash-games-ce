package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   
   public class Robot extends BaseMonster
   {
      
      public static var CanImage:Class = Robot_CanImage;
      
      public static var YakImage:Class = Robot_YakImage;
      
      public static const SIT:int = 3;
      
      public var punchedYet:Boolean;
      
      public var state:int;
      
      public var lastTurn:Number;
      
      public var plan:Array = new Array(IDLE,3,JUMP,0,SIT,1.5,JUMP,0,SIT,1.5,JUMP,0,SIT,1.5);
      
      public var trashcan:FlxSprite;
      
      public var armor:int;
      
      public function Robot(tx:int, ty:int)
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
         this.trashcan = new FlxSprite();
         this.trashcan.loadGraphic(CanImage,true,true,30,37,true);
         this.trashcan.width = 20;
         this.trashcan.offset.x = 5;
         width = 20;
         offset.x = 9;
         speed = 15;
         height = 30;
         offset.y = 0;
         name = "Mighty Robot";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 100;
      }
      
      public static function Money(lvl:int) : int
      {
         return 200;
      }
      
      override public function draw() : void
      {
         this.trashcan.color = this.color;
         super.draw();
         this.trashcan.x = x;
         this.trashcan.y = y - 8;
         this.trashcan.facing = facing;
         this.trashcan.draw();
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
         this.armor = 5;
         action = this.plan[0];
         facing = LEFT;
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
            Global.bullets.AddBullet(RockSpike,Bullets.EVIL,x + width / 2,y + height - 9,1,1);
            Global.bullets.AddBullet(RockSpike,Bullets.EVIL,x + width / 2,y + height - 9,2,1);
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
      
      override public function hurt(n:Number) : void
      {
         var i:int = 0;
         var g:Yak_Big = null;
         if(health <= 0 || !exists)
         {
            return;
         }
         n *= 0.25;
         super.hurt(n);
         if(health < this.armor * maxHealth / 6)
         {
            shouldShatter = true;
         }
         if(shouldShatter)
         {
            --this.armor;
            this.trashcan.frame = 5 - this.armor;
            for(i = 0; i < 20; i++)
            {
               Global.bullets.AddBullet(ArmorBit,Bullets.NEUTRAL,x + Global.randRange(0,width),y + Global.randRange(0,height),Global.randRange(0,360),0);
            }
            if(this.armor == 0)
            {
               exists = false;
               g = Global.badguys.AddGuy(Yak_Big,Badguys.DEADLY,0,0) as Yak_Big;
               g.x = x;
               g.y = y;
               g.tag = tag;
               g.health = health * g.maxHealth / maxHealth;
            }
         }
         shouldShatter = false;
      }
   }
}

