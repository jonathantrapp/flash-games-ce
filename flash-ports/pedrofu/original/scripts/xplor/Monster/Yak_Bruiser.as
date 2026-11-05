package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   
   public class Yak_Bruiser extends BaseMonster
   {
      
      public static var YakImage:Class = Yak_Bruiser_YakImage;
      
      public static const STAMPING:int = 2;
      
      public static const CHARGE:int = 3;
      
      public static const PUNCH:int = 4;
      
      public var punchedYet:Boolean;
      
      public var punchReload:Number;
      
      public var stampTick:Number;
      
      public function Yak_Bruiser(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,19,19,true);
         addAnimation("idle",[0],10,true);
         addAnimation("walk",[0,1,2,3],10,true);
         addAnimation("jumpup",[16],10,true);
         addAnimation("jumpdn",[17],10,true);
         addAnimation("jumpkick",[18],10,true);
         addAnimation("stamp",[4,5,6,7],10,true);
         addAnimation("charge",[8,9,10,11],20,true);
         addAnimation("punch",[12,13,14,14,13,12],20,false);
         addAnimation("hitstun",[15],10,true);
         addAnimation("disabled",[0],10,true);
         addAnimation("talk",[0,19,20,19],10,true);
         width = 11;
         offset.x = 4;
         speed = 15;
         height = 14;
         offset.y = 4;
         name = "Yak Bruiser";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 20;
      }
      
      public static function Money(lvl:int) : int
      {
         return 20;
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = true;
         super.Init(tx,ty);
      }
      
      override public function hurt(n:Number) : void
      {
         reload = 3;
         this.punchReload = 0.5;
         super.hurt(n);
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         reload = 3;
         this.punchReload = 0;
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
         if(dist < 50 && (facing == LEFT && Global.pedro.x + Global.pedro.width / 2 < x + width / 2 || facing == RIGHT && Global.pedro.x + Global.pedro.width / 2 > x + width / 2))
         {
            if(dist < 25 && this.punchReload <= 0)
            {
               play("punch");
               action = PUNCH;
               this.punchedYet = false;
               this.punchReload = 1;
               velocity.x = 50 - 100 * int(facing == LEFT);
            }
            else if(reload <= 0)
            {
               this.stampTick = 0.2;
               play("stamp");
               reload = 0.5;
               action = STAMPING;
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
      
      public function UpdateStamp() : void
      {
         this.stampTick += FlxG.elapsed;
         if(this.stampTick > 0.2)
         {
            Sounds.play(Sounds.SnortSnd);
            this.stampTick -= 0.2;
         }
         velocity.x = 0;
         if(reload <= 0)
         {
            action = CHARGE;
            play("charge");
            Sounds.play(Sounds.DashSnd);
            velocity.x = 150 - 300 * int(facing == LEFT);
         }
      }
      
      public function UpdateCharge() : void
      {
         velocity.x = Global.Dampen(velocity.x,FlxG.elapsed * 150);
         if(justTouched(LEFT | RIGHT) || velocity.x < 0.1 && velocity.x > -0.1)
         {
            action = IDLE;
            play("walk");
            reload = 3;
         }
         if(Global.pedro.Vulnerable() && overlaps(Global.pedro))
         {
            Global.pedro.hurt(1);
            Global.pedro.Knockback(facing,100,-150);
            Knockback(LEFT + RIGHT - facing,50,-70);
            action = HITSTUN;
            stunned = 0.2;
            reload = 3;
         }
      }
      
      public function UpdatePunch() : void
      {
         var r:FlxRect = null;
         if(_curFrame == 2 && !this.punchedYet)
         {
            if(Global.pedro.Vulnerable())
            {
               r = new FlxRect(x + width / 2 + 10 - 20 * int(facing == LEFT),y,10,height);
               if(Global.pedro.x < r.x + r.width && Global.pedro.x + Global.pedro.width > r.x && Global.pedro.y < r.y + r.height && Global.pedro.y + Global.pedro.height > r.y)
               {
                  Global.pedro.hurt(1);
                  Global.pedro.Knockback(facing,20,-40);
               }
            }
            this.punchedYet = true;
         }
         if(finished)
         {
            action = IDLE;
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
         if(this.punchReload > 0)
         {
            this.punchReload -= FlxG.elapsed;
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
         else if(action == CHARGE)
         {
            this.UpdateCharge();
         }
         else if(action == STAMPING)
         {
            this.UpdateStamp();
         }
         else if(action == PUNCH)
         {
            this.UpdatePunch();
         }
      }
   }
}

