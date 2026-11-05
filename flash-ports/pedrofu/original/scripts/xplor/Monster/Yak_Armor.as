package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   
   public class Yak_Armor extends BaseMonster
   {
      
      public static var YakImage:Class = Yak_Armor_YakImage;
      
      public static const SLASH:int = 2;
      
      public static const INACTIVE:int = 3;
      
      public var punchedYet:Boolean;
      
      public var quickSlashTime:Number;
      
      public var inactive:Boolean;
      
      public function Yak_Armor(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,19,23,true);
         addAnimation("idle",[0],10,true);
         addAnimation("walk",[0,1,2,3],10,true);
         addAnimation("jumpup",[8],10,true);
         addAnimation("jumpdn",[9],10,true);
         addAnimation("slash",[4,5,6,6,6,6,7,3,2],15,true);
         addAnimation("quickslash",[4,5,6,6,6,6,7,3,2],20,true);
         addAnimation("hitstun",[4,5,6],10,false);
         addAnimation("inactive",[10,10,10,10,10,10,10,10,10,10,11,10,10,10,10,11,11,10,10,10,10,10,10,10,10,11],5,true);
         addAnimation("talk",[12,13],5,true);
         addAnimation("talkidle",[12],5,true);
         addAnimation("disabled",[0],10,true);
         width = 11;
         offset.x = 4;
         speed = 15;
         height = 14;
         offset.y = 8;
         name = "Armored Yak";
         this.Init(tx,ty);
         this.quickSlashTime = 0;
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
         reload = 1;
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
         reload = 0;
         this.inactive = true;
         action = INACTIVE;
         play("inactive");
      }
      
      public function UpdateIdle() : void
      {
         var tx:int = 0;
         var ty:int = 0;
         if(this.inactive)
         {
            action = INACTIVE;
            play("inactive");
            return;
         }
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
         velocity.x = 30 - 60 * int(facing == LEFT);
         if(p == 3 && facing == LEFT || p == 4 && facing == RIGHT || p == 5)
         {
            action = JUMP;
            play("jumpup");
            velocity.y = -180;
            velocity.x = 50 - 100 * int(facing == LEFT);
            return;
         }
         play("walk");
         var dist:Number = DistanceToGuy(Global.pedro);
         if(dist < 30 && (facing == LEFT && Global.pedro.x + Global.pedro.width / 2 < x + width / 2 || facing == RIGHT && Global.pedro.x + Global.pedro.width / 2 > x + width / 2))
         {
            if(reload <= 0)
            {
               if(this.quickSlashTime > 0)
               {
                  play("quickslash");
               }
               else
               {
                  play("slash");
               }
               reload = 1;
               action = SLASH;
               this.punchedYet = false;
               velocity.x = 0;
            }
         }
      }
      
      public function UpdateJump() : void
      {
         velocity.x = 50 - 100 * int(facing == LEFT);
         if(velocity.y < 0)
         {
            play("jumpup");
         }
         else
         {
            play("jumpdn");
         }
         if(isTouching(DOWN))
         {
            action = IDLE;
            play("walk");
         }
      }
      
      public function UpdateSlash() : void
      {
         var r:FlxRect = null;
         if(_curFrame == 6 && !this.punchedYet)
         {
            if(onScreen())
            {
               Sounds.play(Sounds.SlashSnd);
            }
            Global.bullets.AddBullet(PikeSlash,Bullets.NEUTRAL,x + 15 + (width - 30) * int(facing == LEFT),y + 5,-1 * int(facing == LEFT),0);
            if(Global.pedro.Vulnerable())
            {
               r = new FlxRect(x + width / 2 - 30 * int(facing == LEFT),y - 15,30,40);
               if(Global.pedro.x < r.x + r.width && Global.pedro.x + Global.pedro.width > r.x && Global.pedro.y < r.y + r.height && Global.pedro.y + Global.pedro.height > r.y)
               {
                  Global.pedro.hurt(1);
                  Global.pedro.Knockback(facing,60,-60);
               }
            }
            this.punchedYet = true;
            velocity.x = 100 - 200 * int(facing == LEFT);
            drag.x = 200;
         }
         if(finished)
         {
            action = IDLE;
            drag.x = 0;
            velocity.x = 0;
            reload = 1;
         }
      }
      
      public function UpdateHitStun() : void
      {
         var g:Yak_Bruiser = null;
         var i:int = 0;
         stunned -= FlxG.elapsed;
         if(stunned <= 0)
         {
            if(isTouching(DOWN))
            {
               action = IDLE;
               play("walk");
               reload = 0;
               if(shouldShatter)
               {
                  exists = false;
                  g = Global.badguys.AddGuy(Yak_Bruiser,Badguys.DEADLY,0,0) as Yak_Bruiser;
                  g.x = x;
                  g.y = y;
                  g.tag = tag;
                  g.health = health * g.maxHealth / maxHealth;
                  for(i = 0; i < 8; i++)
                  {
                     Global.bullets.AddBullet(ArmorBit,Bullets.NEUTRAL,x + width / 2,y + height / 2,Global.randRange(0,360),0);
                  }
               }
               this.quickSlashTime = 0.5;
               return;
            }
         }
         else if(isTouching(DOWN))
         {
            velocity.x = Global.Dampen(velocity.x,FlxG.elapsed * 40);
         }
      }
      
      public function WakeUp() : void
      {
         this.inactive = false;
         action = IDLE;
         play("jumpup");
         velocity.y = -70;
         if(Global.pedro.x < x)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
      }
      
      public function UpdateInactive() : void
      {
         var g:BaseMonster = null;
         if(Global.pedro.x < x)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         if(DistanceToGuy(Global.pedro) < 60)
         {
            this.WakeUp();
         }
         if(Global.levelNum == 2 && action == IDLE)
         {
            PlayState(FlxG.state).conversation.Setup(2,this);
            Global.level.GetLayer(Level.LAYER_SOLID).setTileByIndex(Global.level.level2Spot,56);
            Global.level.GetLayer(Level.LAYER_SOLID).setTileByIndex(Global.level.level2Spot - Global.level.width,56);
         }
         if(Global.levelNum == 5 && action == IDLE)
         {
            for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
            {
               if(g is Yak_Armor && g.action == INACTIVE)
               {
                  (g as Yak_Armor).WakeUp();
               }
            }
         }
      }
      
      override public function BasicUpdate() : void
      {
         if(this.inactive && action == IDLE)
         {
            action = INACTIVE;
            play("inactive");
         }
         super.BasicUpdate();
         if(reload > 0)
         {
            reload -= FlxG.elapsed;
         }
         if(this.quickSlashTime > 0)
         {
            this.quickSlashTime -= FlxG.elapsed;
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
         else if(action == SLASH)
         {
            this.UpdateSlash();
         }
         else if(action == INACTIVE)
         {
            this.UpdateInactive();
         }
      }
      
      override public function Knockback(facing:int, xspd:Number, yspd:Number) : void
      {
         super.Knockback(facing,xspd * 0.5,yspd * 0.5);
      }
   }
}

