package xplor
{
   import org.flixel.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.*;
   
   public class Pedro extends FlxSprite
   {
      
      public static var PedroImage:Class = Pedro_PedroImage;
      
      public static const IDLE:uint = 0;
      
      public static const JUMP:uint = 1;
      
      public static const DUCK:uint = 2;
      
      public static const DASH:uint = 3;
      
      public static const GLIDE:uint = 4;
      
      public static const DIE:uint = 5;
      
      public static const JUMPKICK:uint = 6;
      
      public static const CARRY:uint = 7;
      
      public static const CARRYJUMP:uint = 8;
      
      public static const PUNCH:uint = 9;
      
      public static const HITSTUN:uint = 100;
      
      public static const TORNADO:uint = 11;
      
      public static const FURYPICK:uint = 12;
      
      public static const INACTIVE:uint = 13;
      
      public static const DIVEKICK:uint = 14;
      
      public static const FURYHEAL:uint = 15;
      
      public static const PEDROKEN:uint = 16;
      
      public static const CHARGEKICK:uint = 17;
      
      public static const PILEDRIVE:uint = 18;
      
      public var PLAYER_RUN_SPEED:Number = 70;
      
      public var GRAVITY_ACCELERATION:Number = 300;
      
      public var WATER_GRAVITY:Number = 105;
      
      public var JUMP_ACCELERATION:Number = 125;
      
      public var action:uint;
      
      public var startx:Number;
      
      public var starty:Number;
      
      public var dblJump:Boolean;
      
      public var canJump:Number;
      
      public var shouldDie:Boolean;
      
      public var doubleJumpTime:Number;
      
      public var jumpNoiseOK:Boolean;
      
      public var punchPressed:Boolean;
      
      public var punchMode:int;
      
      public var punchCount:int;
      
      public var punchCanHit:Boolean;
      
      public var jumpkick_ang:Number;
      
      public var jumpkick_reload:Number;
      
      public var dash_reload:Number;
      
      public var punch_reload:Number;
      
      public var alternate:Boolean;
      
      public var victim:BaseMonster;
      
      public var notHitYet:Boolean;
      
      public var stunned:Number;
      
      public var ouch:Number;
      
      public var jumpkick_done:Boolean;
      
      public var tornadoCount:int;
      
      public var releasedB3:Boolean;
      
      public var double_tap_time:Number;
      
      public var dashTime:Number;
      
      public var shadowTime:Number;
      
      public var diveKicks:int;
      
      public var healTime:Number;
      
      public var healSpent:Number;
      
      public var dodge:Number;
      
      public var dashHitList:Array;
      
      public var fury:int;
      
      public var subFury:Number;
      
      public var hitbox:FlxSprite;
      
      public var safeX:Number;
      
      public var safeY:Number;
      
      public var specialEventYet:Boolean;
      
      public var wallHit:int;
      
      public var reflect:Boolean;
      
      public var doubleTapped:Number;
      
      public var pileface:int;
      
      public var pedrokenBurns:Boolean;
      
      public var retaliate:Boolean;
      
      public var innerFury:Number;
      
      public var berserk:Number;
      
      public var fireball:Number;
      
      public var rage:Number;
      
      public var excessFury:Number;
      
      public var rockSpiked:Boolean;
      
      public var lightning:Boolean;
      
      public function Pedro(x:Number, y:Number)
      {
         super(x,y);
         loadGraphic(PedroImage,true,true,20,19,true);
         addAnimation("walk",[1,2,3,4,0],10,true);
         addAnimation("idle",[0],10,true);
         addAnimation("jump",[15],10,true);
         addAnimation("jumpdn",[15],10,true);
         addAnimation("glide",[6],10,true);
         addAnimation("dash",[30],20,true);
         addAnimation("grab",[9],20,true);
         addAnimation("duck",[5],20,false);
         addAnimation("ducking",[5],20,true);
         addAnimation("unduck",[5],20,false);
         addAnimation("die",[0],15,false);
         addAnimation("carryidle",[10],15,true);
         addAnimation("carrywalk",[11,12,13,14,10],10,true);
         addAnimation("carryjump",[16],15,true);
         addAnimation("chargekick_dn",[7],10,true);
         addAnimation("chargekick_up",[8],10,true);
         addAnimation("chargekick_mid",[6],10,true);
         addAnimation("jumpkick",[7,6,6,6,6,7],15,true);
         addAnimation("chomp",[17,18,19,20,21,22],20,false);
         addAnimation("crawl",[5,23,24,23],10,true);
         addAnimation("punch",[21,20,21,22,23,23,23],20,false);
         addAnimation("punch2",[19,18,18,17,17,17,17],20,false);
         addAnimation("hitstun",[24],10,true);
         addAnimation("tornado",[25,26,25],19,false);
         addAnimation("furypick",[10],15,true);
         addAnimation("talk",[27,28,29,28],10,true);
         addAnimation("pedroken",[31,32,33,34],20,false);
         addAnimation("pedroken2",[33,32],20,false);
         addAnimation("pedroken3",[22,0],20,false);
         addAnimation("piledrive",[35],20,true);
         this.offset.x = 6;
         this.offset.y = 3;
         this.width = 8;
         this.height = 15;
         this.rockSpiked = false;
         this.innerFury = 0;
         this.reflect = false;
         this.diveKicks = 0;
         this.specialEventYet = false;
         this.hitbox = new FlxSprite();
         this.hitbox.solid = true;
         this.hitbox.exists = true;
         this.startx = x;
         this.starty = y;
         this.safeX = this.startx;
         this.safeY = this.starty;
         this.action = IDLE;
         this.dblJump = false;
         this.canJump = 0.1;
         this.shouldDie = false;
         this.doubleTapped = 0;
         this.doubleJumpTime = 0;
         this.jumpNoiseOK = true;
         this.dodge = 0;
         this.fury = 0;
         this.subFury = 0.2 * Profile.skills[SkillDef.INNERFURY];
         if(this.subFury >= 1)
         {
            this.fury = 1;
            this.subFury = 0;
         }
         this.excessFury = 0;
         this.fireball = 0;
         this.retaliate = false;
         this.pedrokenBurns = false;
         this.shadowTime = 0;
         this.stunned = 0;
         this.releasedB3 = true;
         this.rage = 0;
         this.ouch = 0;
         this.punch_reload = 0;
         this.dash_reload = 0;
         this.double_tap_time = 0;
         health = Profile.max_life;
         this.dashHitList = new Array();
      }
      
      public function Deactivate() : void
      {
         this.action = INACTIVE;
         visible = false;
      }
      
      public function Vulnerable() : Boolean
      {
         return this.ouch <= 0 && this.dodge <= 0 && this.action != PILEDRIVE && this.action != HITSTUN;
      }
      
      override public function draw() : void
      {
         if(this.ouch > 0)
         {
            color = 16737894;
         }
         else if(this.berserk > 0)
         {
            color = 16729343;
         }
         else if(this.rage > 0 || Boolean(health == Profile.max_life && this.fury == Profile.max_fury) && Boolean(Profile.skills[SkillDef.MAXIMUMFORCE]))
         {
            color = 16729241;
         }
         else
         {
            color = 16777215;
         }
         super.draw();
      }
      
      override public function hurt(n:Number) : void
      {
         if(!this.Vulnerable())
         {
            return;
         }
         if(this.action == CARRY || this.action == CARRYJUMP)
         {
            this.victim.FreeAgain();
            this.victim = null;
         }
         if(this.action == FURYPICK)
         {
            PlayState(FlxG.state).furyIcons.Hide();
         }
         if(this.action == FURYHEAL && Global.randRange(0,100) < 20 * Profile.skills[SkillDef.FURIOUSSHIELD])
         {
            this.reflect = true;
            return;
         }
         if(this.action == PEDROKEN && velocity.y < 0 && this.pedrokenBurns)
         {
            this.reflect = true;
            return;
         }
         if(Boolean(Profile.skills[SkillDef.HEARTOFFURY]))
         {
            this.GetFury(Profile.skills[SkillDef.HEARTOFFURY] * 0.02);
         }
         this.action = HITSTUN;
         acceleration.y = this.GRAVITY_ACCELERATION;
         play("hitstun");
         this.stunned = 0.2;
         this.ouch = 0.2;
         health -= n;
         if(health < 0)
         {
            health = 0;
         }
         Sounds.play(Sounds.PedroHurtSnd);
         FlxG.timeScale = 0.5;
         this.rage = Profile.skills[SkillDef.RAGINGBURRO];
      }
      
      public function Jumpkick() : void
      {
         this.action = JUMPKICK;
         this.punchCanHit = true;
         play("jumpkick");
      }
      
      public function ChargeKick() : void
      {
         var e:FlxSprite = null;
         var tx:Number = NaN;
         var ty:Number = NaN;
         this.jumpkick_reload = 1;
         e = Global.badguys.TargetEnemy(this,1 + int(facing == RIGHT));
         if(e != null && Math.abs(e.x + e.width / 2 - (x + width / 2)) < 70 && Math.abs(e.y + e.height / 2 - (y + height / 2)) < 70)
         {
            tx = e.x + e.width / 2;
            ty = e.y + e.height / 2;
         }
         else
         {
            if(facing == LEFT)
            {
               tx = x - 40;
            }
            else
            {
               tx = x + 40;
            }
            ty = y + 40;
         }
         Sounds.play(Sounds.DashSnd);
         this.action = CHARGEKICK;
         acceleration.x = 0;
         acceleration.y = 0;
         maxVelocity.x = 200;
         maxVelocity.y = 200;
         drag.x = 0;
         drag.y = 0;
         var a:Number = Global.AngleBetween(x + width / 2,y + height / 2,tx,ty);
         while(a < 0)
         {
            a += 360;
         }
         while(a >= 360)
         {
            a -= 360;
         }
         velocity.x = Global.Cosine(a) * 200;
         velocity.y = Global.Sine(a) * 200;
         if(a > 90 && a < 270)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         if(a >= 45 && a <= 180 - 45)
         {
            play("chargekick_dn");
         }
         else if(a <= 360 - 45 && a >= 180 + 45)
         {
            play("chargekick_up");
         }
         else
         {
            play("chargekick_mid");
         }
         if(a > 180)
         {
            acceleration.y = this.GRAVITY_ACCELERATION / 2;
         }
         this.jumpkick_ang = a;
      }
      
      public function EndJumpkick() : void
      {
         this.action = JUMP;
         maxVelocity.x = this.PLAYER_RUN_SPEED;
         maxVelocity.y = 800;
         velocity.x = 0;
         velocity.y = 0;
         acceleration.y = this.GRAVITY_ACCELERATION;
         drag.x = this.PLAYER_RUN_SPEED * 4;
         drag.y = 0;
         play("jump");
         this.jumpkick_reload = 0.25;
      }
      
      public function ChargeKicked(me:FlxSprite, you:BaseMonster) : void
      {
         var dmg:Number = NaN;
         if(you.ouch >= 0.2)
         {
            return;
         }
         if(this.retaliate)
         {
            dmg = SkillDef.RetaliateDamage();
         }
         else
         {
            dmg = SkillDef.ChargeKickDamage();
         }
         if(Global.randRange(0,1) < Profile.skills[SkillDef.LEADFOOT] * 0.03)
         {
            dmg *= 3;
            Sounds.play(Sounds.CriticalSnd);
            Global.bullets.Spark(me,you,true);
            you.shouldShatter = true;
         }
         else
         {
            Sounds.play(Sounds.PunchSnd);
            Global.bullets.Spark(me,you);
         }
         you.hurt(dmg);
         you.Knockback(facing,Global.Cosine(this.jumpkick_ang) * 200 * (1 - 2 * int(facing == LEFT)),Global.Cosine(this.jumpkick_ang) * 100);
         this.EndJumpkick();
         velocity.y = -this.JUMP_ACCELERATION / 4;
         velocity.x = -60 + 120 * int(facing == LEFT);
      }
      
      public function UpdateJumpKick() : void
      {
         this.jumpkick_done = true;
         if(isTouching(FLOOR))
         {
            this.action = IDLE;
            play("idle");
         }
         else if(finished)
         {
            this.action = JUMP;
            if(velocity.y < 0)
            {
               play("jump");
            }
            else
            {
               play("jumpdn");
            }
         }
         if(this.punchCanHit)
         {
            this.hitbox.width = 12;
            if(facing == RIGHT)
            {
               this.hitbox.x = x + 2;
            }
            else
            {
               this.hitbox.x = x + width - this.hitbox.width - 2;
            }
            this.hitbox.y = y;
            this.hitbox.height = height;
            this.hitbox.last.x = this.hitbox.x;
            this.hitbox.last.y = this.hitbox.y;
            FlxG.overlap(this.hitbox,Global.badguys.GetGroup(Badguys.DEADLY),this.JumpkickHit);
         }
         if(Keebie.TapDir(Keebie.B2) && Boolean(Profile.skills[SkillDef.CHARGEKICK]))
         {
            this.retaliate = false;
            this.ChargeKick();
         }
      }
      
      public function UpdateChargeKick() : void
      {
         this.hitbox.width = 12;
         if(facing == RIGHT)
         {
            this.hitbox.x = x + 2;
         }
         else
         {
            this.hitbox.x = x + width - this.hitbox.width - 2;
         }
         this.hitbox.y = y;
         this.hitbox.height = height;
         this.hitbox.last.x = this.hitbox.x;
         this.hitbox.last.y = this.hitbox.y;
         FlxG.overlap(this.hitbox,Global.badguys.GetGroup(Badguys.DEADLY),this.ChargeKicked);
         this.MakeShadow();
         if(this.jumpkick_reload <= 0 || isTouching(ANY) || this.jumpkick_ang < 360 && this.jumpkick_ang > 180 && velocity.y > 40)
         {
            this.EndJumpkick();
         }
      }
      
      public function JumpkickHit(me:FlxSprite, you:BaseMonster) : void
      {
         var dmg:Number = NaN;
         if(you.ouch >= 0.2)
         {
            return;
         }
         dmg = SkillDef.JumpkickDamage();
         if(Global.randRange(0,1) < Profile.skills[SkillDef.LEADFOOT] * 0.03)
         {
            dmg *= 3;
            Sounds.play(Sounds.CriticalSnd);
            Global.bullets.Spark(me,you,true);
            you.shouldShatter = true;
         }
         else
         {
            Sounds.play(Sounds.PunchSnd);
            Global.bullets.Spark(me,you);
         }
         you.hurt(dmg);
         this.GetFury(Profile.skills[SkillDef.FEETOFFURY] * 0.01);
         this.punchCanHit = false;
         if(Keebie.Dir(Keebie.B2) && Boolean(Profile.skills[SkillDef.TORNADOKICK]))
         {
            you.Knockback(LEFT + RIGHT - facing,30,-60);
            this.action = TORNADO;
            play("tornado");
            this.tornadoCount = 0;
            velocity.y = 0;
            velocity.x = 0;
            acceleration.y = 0;
         }
         else
         {
            you.Knockback(facing,50 * (1 + Profile.skills[SkillDef.POWERKICK] * 0.3),-65 * (1 + Profile.skills[SkillDef.POWERKICK] * 0.3));
            if(velocity.y < 0)
            {
               velocity.y = 0;
            }
         }
      }
      
      public function TornadoHit(me:FlxSprite, you:BaseMonster) : void
      {
         if(you.ouch >= 0.2)
         {
            return;
         }
         Sounds.play(Sounds.PunchHighSnd);
         you.hurt(SkillDef.TornadoKickDamage());
         Global.bullets.Spark(me,you);
         if(this.tornadoCount == 6 || !Keebie.Dir(Keebie.B2))
         {
            you.Knockback(facing,50 * (1 + Profile.skills[SkillDef.POWERKICK] * 0.3),-65 * (1 + Profile.skills[SkillDef.POWERKICK] * 0.3));
         }
         else
         {
            you.Knockback(LEFT + RIGHT - facing,30,-60);
         }
      }
      
      public function MakeShadow() : void
      {
         var b:BaseGuy = null;
         if(this.shadowTime <= 0)
         {
            b = Global.badguys.AddGuy(DashShadow,Badguys.NEUTRAL,0,0);
            b.frame = _curIndex;
            b.x = x;
            b.y = y;
            this.shadowTime = 0.05;
         }
      }
      
      public function DiveKickHit(me:FlxSprite, you:BaseMonster) : void
      {
         var dmg:Number = NaN;
         if(this.action != DIVEKICK)
         {
            return;
         }
         if(you.ouch >= 0.2)
         {
            return;
         }
         this.action = JUMP;
         velocity.y = -this.JUMP_ACCELERATION;
         play("jump");
         if(Boolean(Profile.skills[SkillDef.KOKICK]))
         {
            you.Flatten(Profile.skills[SkillDef.KOKICK] * 0.4);
         }
         dmg = SkillDef.DiveKickDamage();
         if(Global.randRange(0,1) < Profile.skills[SkillDef.LEADFOOT] * 0.03)
         {
            dmg *= 3;
            Sounds.play(Sounds.CriticalSnd);
            Global.bullets.Spark(me,you,true);
            you.shouldShatter = true;
         }
         else
         {
            Sounds.play(Sounds.PunchSnd);
            Global.bullets.Spark(me,you);
         }
         you.hurt(dmg);
      }
      
      public function UpdateDiveKick() : void
      {
         if(isTouching(FLOOR))
         {
            this.action = IDLE;
            play("idle");
            return;
         }
         velocity.x = 60 - 120 * int(facing == LEFT);
         this.MakeShadow();
         this.hitbox.x = x - 4;
         this.hitbox.width = width + 8;
         this.hitbox.y = y + height - 4;
         this.hitbox.height = 8;
         this.hitbox.last.x = this.hitbox.x;
         this.hitbox.last.y = this.hitbox.y;
         this.hitbox.x += 8 - 16 * int(facing == LEFT);
         FlxG.overlap(this.hitbox,Global.badguys.GetGroup(Badguys.DEADLY),this.DiveKickHit);
      }
      
      public function Jump() : void
      {
         if(this.canJump > 0)
         {
            if(this.jumpNoiseOK)
            {
               this.jumpNoiseOK = false;
            }
            this.action = JUMP;
            velocity.y = -this.JUMP_ACCELERATION;
            drag.x = this.PLAYER_RUN_SPEED * 4;
         }
      }
      
      public function UpdateTornado() : void
      {
         var g:BaseMonster = null;
         var a:Number = NaN;
         velocity.x = 0;
         velocity.y = -10;
         if(Boolean(Profile.skills[SkillDef.WHIRLWIND]))
         {
            for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
            {
               if(g != null && g.exists && g.health > 0 && !(g is Barrier_Orb) && g.DistanceToGuy(this) < Profile.skills[SkillDef.WHIRLWIND] * 10)
               {
                  a = Global.AngleBetweenGuys(g,this);
                  g.x += Global.Cosine(a) * 100 * FlxG.elapsed;
                  g.y += Global.Sine(a) * 100 * FlxG.elapsed;
                  g.Knockback(RIGHT + (LEFT - RIGHT) * int(a > 90 && a < 270),0,0);
               }
            }
         }
         if(finished)
         {
            play("tornado",true);
            facing = LEFT + RIGHT - facing;
            ++this.tornadoCount;
            this.hitbox.width = 12;
            if(facing == RIGHT)
            {
               this.hitbox.x = x + 2;
            }
            else
            {
               this.hitbox.x = x + width - this.hitbox.width - 2;
            }
            this.hitbox.y = y;
            this.hitbox.height = height;
            this.hitbox.last.x = this.hitbox.x;
            this.hitbox.last.y = this.hitbox.y;
            FlxG.overlap(this.hitbox,Global.badguys.GetGroup(Badguys.DEADLY),this.TornadoHit);
            if(this.tornadoCount >= 6 || !Keebie.Dir(Keebie.B2))
            {
               if(Boolean(this.tornadoCount % 2))
               {
                  facing = LEFT + RIGHT - facing;
               }
               acceleration.y = this.GRAVITY_ACCELERATION;
               this.action = JUMP;
               play("jumpdn");
            }
         }
      }
      
      public function BurroBash() : void
      {
         this.action = DASH;
         this.dashHitList = new Array();
         play("dash");
         Sounds.play(Sounds.DashSnd);
         maxVelocity.x = 150;
         velocity.x = 150 - 300 * int(facing == LEFT);
         velocity.y = 0;
         drag.x = 0;
         acceleration.y = this.GRAVITY_ACCELERATION;
         this.wallHit = 0;
         this.dashTime = Profile.skills[SkillDef.BURROBASH] * 0.5;
      }
      
      public function DiveKick() : void
      {
         this.action = DIVEKICK;
         Sounds.play(Sounds.DashSnd);
         play("jumpkick_dn");
         velocity.x = 60 - 120 * int(facing == LEFT);
         velocity.y = 100;
         ++this.diveKicks;
      }
      
      public function UpdateWalkJump() : void
      {
         maxVelocity.x = this.PLAYER_RUN_SPEED;
         acceleration.x = 0;
         acceleration.y = this.GRAVITY_ACCELERATION;
         if(Keebie.TapDir(Keebie.LEFT))
         {
            if(this.double_tap_time > 0 && facing == LEFT)
            {
               this.doubleTapped = 0.1;
               this.double_tap_time = 0.2;
            }
            else
            {
               this.double_tap_time = 0.2;
            }
         }
         if(Keebie.TapDir(Keebie.RIGHT))
         {
            if(this.double_tap_time > 0 && facing == RIGHT)
            {
               this.doubleTapped = 0.1;
               this.double_tap_time = 0.2;
            }
            else
            {
               this.double_tap_time = 0.2;
            }
         }
         if(this.doubleTapped > 0 && isTouching(FLOOR) && Boolean(Profile.skills[SkillDef.BURROBASH]))
         {
            this.BurroBash();
            return;
         }
         if(Keebie.Dir(Keebie.LEFT))
         {
            facing = LEFT;
            acceleration.x = -this.PLAYER_RUN_SPEED * 4;
         }
         else if(Keebie.Dir(Keebie.RIGHT))
         {
            facing = RIGHT;
            acceleration.x = this.PLAYER_RUN_SPEED * 4;
         }
         if(isTouching(FLOOR))
         {
            this.diveKicks = 0;
            if(Global.level.GetLayer(Level.LAYER_SOLID).getTile(int((x + width / 2) / 16),int((y + height + 2) / 16)) == 63)
            {
               this.hurt(1);
               this.Knockback(LEFT + RIGHT - facing,40,-40);
               return;
            }
            if(Global.levelNum == 3 && x > Global.TILE_WIDTH * 37 && !this.specialEventYet)
            {
               PlayState(FlxG.state).conversation.Setup(3,null);
               this.specialEventYet = true;
               return;
            }
            this.safeX = x;
            this.safeY = y;
            this.jumpkick_done = false;
            this.jumpNoiseOK = true;
            this.dblJump = true;
            this.canJump = 0.1;
            this.action = IDLE;
            velocity.y = 0;
            drag.x = this.PLAYER_RUN_SPEED * 4;
            if(Keebie.Dir(Keebie.DOWN))
            {
               offset.y = 6;
               height = 12;
               y += 3;
               this.action = DUCK;
               this.dodge = Profile.skills[SkillDef.DODGE] * 0.2;
               play("duck");
            }
         }
         else
         {
            this.action = JUMP;
            if(this.diveKicks < Profile.skills[SkillDef.DIVEKICK] && Keebie.TapDir(Keebie.DOWN))
            {
               this.DiveKick();
               return;
            }
         }
         if(Keebie.Dir(Keebie.B3) && this.releasedB3 && this.fury > 0 && (Boolean(Profile.skills[SkillDef.FURIOUSFIX]) || Boolean(Profile.skills[SkillDef.FURIOUSBLAST]) || Boolean(Profile.skills[SkillDef.FURIOUSFREEZE]) || Boolean(Profile.skills[SkillDef.FURIOUSFRENZY])))
         {
            this.releasedB3 = false;
            this.action = FURYPICK;
            play("furypick");
            PlayState(FlxG.state).furyIcons.Show();
            return;
         }
         if(Keebie.Dir(Keebie.B1) || Keebie.Dir(Keebie.UP))
         {
            this.Jump();
         }
         if(this.action == JUMP && this.jumpkick_reload == 0 && Keebie.TapDir(Keebie.B2))
         {
            if(this.jumpkick_done && Boolean(Profile.skills[SkillDef.CHARGEKICK]))
            {
               this.retaliate = false;
               this.ChargeKick();
            }
            else if(!this.jumpkick_done)
            {
               this.Jumpkick();
            }
         }
         else if(this.action == IDLE && this.punch_reload == 0 && Keebie.Dir(Keebie.B2))
         {
            this.action = PUNCH;
            this.punchPressed = false;
            this.punchCanHit = true;
            this.punchMode = 0;
            this.punchCount = 1;
            play("punch");
            acceleration.x = 0;
            maxVelocity.x = 50;
            velocity.x = 25 - 50 * int(facing == LEFT);
            velocity.y = 0;
            drag.x = 0;
            if(Boolean(Profile.skills[SkillDef.GALEFIST]))
            {
               if(facing == RIGHT)
               {
                  Global.bullets.AddBullet(GaleWind,Bullets.NEUTRAL,x + width + 12,y + height / 2,Profile.skills[SkillDef.GALEFIST] * 0.2,0);
               }
               else
               {
                  Global.bullets.AddBullet(GaleWind,Bullets.NEUTRAL,x - 12,y + height / 2,Profile.skills[SkillDef.GALEFIST] * -0.2,0);
               }
            }
         }
      }
      
      public function PileDrive() : void
      {
         this.action = PILEDRIVE;
         this.pileface = facing;
         velocity.x = 0;
         velocity.y = 50;
         play("piledrive");
         this.dash_reload = 0.1;
      }
      
      public function UpdatePileDrive() : void
      {
         velocity.x = 0;
         if(this.victim == null || this.victim.health == 0 || this.victim.exists == false)
         {
            this.action = IDLE;
            this.victim = null;
            this.dash_reload = 0.5;
            return;
         }
         if(isTouching(FLOOR))
         {
            this.action = IDLE;
            facing = this.pileface;
            velocity.x = 40 - 80 * int(facing == RIGHT);
            velocity.y = -60;
            this.victim.FreeAgain();
            Sounds.play(Sounds.SmashSnd);
            this.victim.hurt(SkillDef.PiledriverDamage());
            this.victim.Stun(Profile.skills[SkillDef.PILEDRIVER] * 0.5);
            if(Boolean(Profile.skills[SkillDef.ATOMICPILEDRIVER]) && this.GetFury(-0.05))
            {
               Global.bullets.AddBullet(AtomicDrive,Bullets.NEUTRAL,x + width / 2,y + height - 8,0,0);
            }
            this.victim = null;
         }
         if(this.dash_reload <= 0)
         {
            this.dash_reload += 0.1;
            facing = LEFT + RIGHT - facing;
         }
      }
      
      public function UpdateCarry() : void
      {
         if(this.victim == null || this.victim.health == 0 || this.victim.exists == false)
         {
            this.action = IDLE;
            this.victim = null;
            this.dash_reload = 0.5;
            return;
         }
         maxVelocity.x = this.PLAYER_RUN_SPEED;
         acceleration.x = 0;
         acceleration.y = this.GRAVITY_ACCELERATION;
         if(Keebie.Dir(Keebie.LEFT))
         {
            facing = LEFT;
            acceleration.x = -this.PLAYER_RUN_SPEED * 4;
         }
         else if(Keebie.Dir(Keebie.RIGHT))
         {
            facing = RIGHT;
            acceleration.x = this.PLAYER_RUN_SPEED * 4;
         }
         if(isTouching(CEILING) && velocity.y < 0)
         {
            velocity.y = 0;
         }
         if(isTouching(FLOOR))
         {
            this.jumpNoiseOK = true;
            this.dblJump = true;
            this.canJump = 0.1;
            this.action = CARRY;
            velocity.y = 0;
            drag.x = this.PLAYER_RUN_SPEED * 4;
         }
         else
         {
            this.action = CARRYJUMP;
            if(Boolean(Profile.skills[SkillDef.PILEDRIVER]) && Keebie.TapDir(Keebie.DOWN))
            {
               this.PileDrive();
               return;
            }
         }
         if(Keebie.Dir(Keebie.B1) || Keebie.Dir(Keebie.UP))
         {
            if(this.canJump > 0)
            {
               if(this.jumpNoiseOK)
               {
                  this.jumpNoiseOK = false;
               }
               this.action = CARRYJUMP;
               velocity.y = -this.JUMP_ACCELERATION;
               drag.x = this.PLAYER_RUN_SPEED * 4;
            }
         }
         if(this.dash_reload == 0 && !Keebie.Dir(Keebie.B2))
         {
            this.action = IDLE;
            this.victim.GetThrown();
            this.victim = null;
            this.dash_reload = 0.5;
         }
      }
      
      public function Bash(me:FlxSprite, you:BaseMonster) : void
      {
         if(this.dashHitList.indexOf(you) != -1)
         {
            return;
         }
         if(this.action != DASH)
         {
            return;
         }
         if(you.ouch >= 0.2)
         {
            return;
         }
         this.dashHitList.push(you);
         Global.throwDmg = SkillDef.ThrowDamage();
         Global.throwSpeed = 1 + 0.5 * int(Profile.skills[SkillDef.MIGHTYGRAB]);
         if(!you.throwable || Profile.skills[SkillDef.MIGHTYGRAB] == 0 || !Keebie.Dir(Keebie.B2))
         {
            if(you.action == HITSTUN)
            {
               return;
            }
            you.frozen = 0;
            Sounds.play(Sounds.PunchSnd);
            you.hurt(SkillDef.BurroBashDamage());
            Global.bullets.Spark(me,you,false);
            you.Knockback(facing,-30,-130);
            return;
         }
         play("carrywalk");
         this.action = CARRY;
         this.victim = you;
         you.GetPickedUp();
         maxVelocity.x = this.PLAYER_RUN_SPEED;
         maxVelocity.y = 800;
         velocity.x = 0;
         velocity.y = 0;
         acceleration.y = this.GRAVITY_ACCELERATION;
         drag.x = this.PLAYER_RUN_SPEED * 4;
         drag.y = 0;
         this.dash_reload = 0.2;
      }
      
      public function UpdateDash() : void
      {
         this.dashTime -= FlxG.elapsed;
         if(Keebie.Dir(Keebie.B2) && Boolean(Profile.skills[SkillDef.MIGHTYGRAB]))
         {
            play("grab");
         }
         else
         {
            play("dash");
         }
         if(this.dashTime <= 0)
         {
            if(isTouching(FLOOR))
            {
               this.action = IDLE;
               play("idle");
            }
            else
            {
               this.action = JUMP;
               play("jump");
            }
            maxVelocity.x = this.PLAYER_RUN_SPEED;
            maxVelocity.y = 800;
            velocity.x = 0;
            velocity.y = 0;
            acceleration.y = this.GRAVITY_ACCELERATION;
            drag.x = this.PLAYER_RUN_SPEED * 4;
            drag.y = 0;
         }
         else
         {
            if(facing == LEFT && Keebie.Dir(Keebie.RIGHT) || facing == RIGHT && Keebie.Dir(Keebie.LEFT))
            {
               this.dashTime = 0;
            }
            if(isTouching(WALL))
            {
               ++this.wallHit;
            }
            else
            {
               this.wallHit = 0;
            }
            if(this.wallHit > 3)
            {
               this.dashTime = 0;
               this.action = HITSTUN;
               play("hitstun");
               this.Knockback(LEFT + RIGHT - facing,30,-60);
               return;
            }
            velocity.x = (150 - 300 * int(facing == LEFT)) * (this.dashTime + 0.5) / (Profile.skills[SkillDef.BURROBASH] * 0.5 + 0.5);
            this.MakeShadow();
            FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.Bash);
         }
      }
      
      public function PunchHit(me:FlxSprite, you:BaseMonster) : void
      {
         var targets:int = 0;
         var g:BaseMonster = null;
         if(you.ouch >= 0.2)
         {
            return;
         }
         if(Global.randRange(0,1) < Profile.skills[SkillDef.PRESSUREPOINTS] * 0.04)
         {
            Sounds.play(Sounds.CriticalSnd);
            you.hurt(SkillDef.PunchDamage() * 3);
            Global.bullets.Spark(me,you,true);
            this.GetFury(0.01 * Profile.skills[SkillDef.PRESSUREPOINTS]);
         }
         else
         {
            Sounds.play(Sounds.PunchSnd);
            you.hurt(SkillDef.PunchDamage());
            Global.bullets.Spark(me,you);
         }
         you.Knockback(facing,10,-30);
         if(Global.randRange(0,1) < Profile.skills[SkillDef.FISTOFFURY] * 0.1)
         {
            this.GetFury(0.02);
         }
         if(this.lightning == false && Boolean(Profile.skills[SkillDef.LIGHTNINGFIST]))
         {
            this.lightning = true;
            targets = int(Profile.skills[SkillDef.LIGHTNINGFIST]);
            for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
            {
               if(g != null && g != you && g.exists && g.health > 0 && g.visible && Global.Distance(g.x + g.width / 2,g.y + g.height / 2,you.x + you.width / 2,you.y + you.height / 2) < Profile.skills[SkillDef.LIGHTNINGFIST] * 15)
               {
                  Global.bullets.AddBullet(Lightning,Bullets.NEUTRAL,you.x + you.width / 2,you.y + you.height / 2,0,0);
                  Global.bullets.lastAdded.target = g;
                  Global.bullets.lastAdded.update();
                  g.hurt(0.2 + Profile.skills[SkillDef.LIGHTNINGFIST] * 0.2);
                  targets--;
                  if(targets == 0)
                  {
                     break;
                  }
               }
            }
            if(targets < Profile.skills[SkillDef.LIGHTNINGFIST])
            {
               Sounds.play(Sounds.LightningSnd);
            }
         }
      }
      
      public function EndPunch() : void
      {
         if(isTouching(FLOOR))
         {
            this.action = IDLE;
            play("idle");
         }
         else
         {
            this.action = JUMP;
            play("jump");
         }
         maxVelocity.x = this.PLAYER_RUN_SPEED;
         maxVelocity.y = 800;
         velocity.x = 0;
         velocity.y = 0;
         acceleration.y = this.GRAVITY_ACCELERATION;
         drag.x = this.PLAYER_RUN_SPEED * 4;
         drag.y = 0;
         this.punch_reload = 0.2;
      }
      
      public function UpdatePunch() : void
      {
         if(finished)
         {
            this.EndPunch();
         }
         else
         {
            velocity.x = Global.Dampen(velocity.x,this.PLAYER_RUN_SPEED * 4 * FlxG.elapsed);
            if(Keebie.TapDir(Keebie.B2))
            {
               this.punchPressed = true;
            }
            if(_curFrame > 2 && isTouching(FLOOR))
            {
               if(Keebie.Dir(Keebie.UP) || Keebie.Dir(Keebie.B1))
               {
                  this.EndPunch();
                  this.canJump = 0.1;
                  this.Jump();
                  return;
               }
               if(!Keebie.Dir(Keebie.B2))
               {
                  if(Keebie.Dir(Keebie.LEFT))
                  {
                     this.EndPunch();
                     return;
                  }
                  if(Keebie.Dir(Keebie.RIGHT))
                  {
                     this.EndPunch();
                     return;
                  }
               }
            }
            if(this.punchCanHit && _curFrame == 1)
            {
               this.hitbox.width = 14 + Profile.skills[SkillDef.GALEFIST] * 3;
               if(facing == RIGHT)
               {
                  this.hitbox.x = x + width - 4;
               }
               else
               {
                  this.hitbox.x = x - this.hitbox.width + 4;
               }
               this.hitbox.y = y - 3;
               this.hitbox.height = height + 3;
               this.hitbox.last.x = this.hitbox.x;
               this.hitbox.last.y = this.hitbox.y;
               this.lightning = false;
               FlxG.overlap(this.hitbox,Global.badguys.GetGroup(Badguys.DEADLY),this.PunchHit);
               this.punchCanHit = false;
            }
            if(_curFrame > 2 && (this.punchPressed || Keebie.Dir(Keebie.B2)) && this.punchCount <= Profile.skills[SkillDef.PEDROPUNCH])
            {
               if(Boolean(Profile.skills[SkillDef.PEDROKEN]) && Keebie.Dir(Keebie.DOWN))
               {
                  this.Pedroken();
                  return;
               }
               this.punchMode = 1 - this.punchMode;
               ++this.punchCount;
               if(this.punchMode == 0)
               {
                  play("punch",true);
               }
               else
               {
                  play("punch2",true);
               }
               if(Boolean(Profile.skills[SkillDef.GALEFIST]))
               {
                  if(facing == RIGHT)
                  {
                     Global.bullets.AddBullet(GaleWind,Bullets.NEUTRAL,x + width + 12,y + height / 2,Profile.skills[SkillDef.GALEFIST] * 0.2,0);
                  }
                  else
                  {
                     Global.bullets.AddBullet(GaleWind,Bullets.NEUTRAL,x - 12,y + height / 2,Profile.skills[SkillDef.GALEFIST] * -0.2,0);
                  }
               }
               velocity.x = 25 - 50 * int(facing == LEFT);
               this.punchPressed = false;
               this.punchCanHit = true;
            }
         }
      }
      
      public function Pedroken() : void
      {
         Sounds.play(Sounds.DashSnd);
         this.action = PEDROKEN;
         play("pedroken");
         velocity.x = 40 - 80 * int(facing == LEFT);
         velocity.y = -110;
         this.dashHitList = new Array();
         this.punchCanHit = false;
         this.dodge = 0;
         this.pedrokenBurns = false;
         if(Boolean(Profile.skills[SkillDef.FISTSOFFLAME]))
         {
            if(this.GetFury(-Profile.skills[SkillDef.FISTSOFFLAME] * 0.02))
            {
               this.pedrokenBurns = true;
               Global.bullets.AddBullet(PedroFlame,Bullets.BACKGD,x + width / 2,y + height - 20,int(facing == LEFT),1);
               Global.bullets.AddBullet(PedroFlame,Bullets.NEUTRAL,x + width / 2,y + height - 20,int(facing == LEFT),0);
            }
         }
      }
      
      public function UpdateDuck() : void
      {
         if(this.dodge > 0)
         {
            this.dodge -= FlxG.elapsed;
         }
         if(finished)
         {
            play("ducking");
         }
         acceleration.x = 0;
         drag.x = this.PLAYER_RUN_SPEED * 8;
         if(!Keebie.Dir(Keebie.DOWN))
         {
            this.dodge = 0;
            this.action = IDLE;
            play("unduck");
            offset.y = 3;
            height = 15;
            y -= 3;
         }
         if(Keebie.Dir(Keebie.LEFT))
         {
            facing = LEFT;
         }
         else if(Keebie.Dir(Keebie.RIGHT))
         {
            facing = RIGHT;
         }
         if(Keebie.Dir(Keebie.B2) && Boolean(Profile.skills[SkillDef.PEDROKEN]))
         {
            this.Pedroken();
         }
         if(Keebie.Dir(Keebie.B3) && this.releasedB3 && this.fury > 0 && (Boolean(Profile.skills[SkillDef.FURIOUSFIX]) || Boolean(Profile.skills[SkillDef.FURIOUSBLAST]) || Boolean(Profile.skills[SkillDef.FURIOUSFREEZE]) || Boolean(Profile.skills[SkillDef.FURIOUSFRENZY])))
         {
            this.releasedB3 = false;
            this.action = FURYPICK;
            play("furypick");
            PlayState(FlxG.state).furyIcons.Show();
            return;
         }
      }
      
      public function UpdateHitStun() : void
      {
         this.stunned -= FlxG.elapsed;
         if(Keebie.TapDir(Keebie.B2) && Boolean(Profile.skills[SkillDef.RETALIATE]))
         {
            if(this.GetFury(-(0.2 - Profile.skills[SkillDef.RETALIATE] * 0.03)))
            {
               this.retaliate = true;
               this.ChargeKick();
               this.stunned = 0;
               return;
            }
         }
         if(Keebie.TapDir(Keebie.DOWN) && Boolean(Profile.skills[SkillDef.RECOVERY]))
         {
            this.action = JUMP;
            velocity.x = 0;
            if(velocity.y < 300)
            {
               velocity.y = 300;
            }
            play("jumpdn");
            return;
         }
         if(this.stunned <= 0)
         {
            if(isTouching(DOWN))
            {
               maxVelocity.x = this.PLAYER_RUN_SPEED;
               this.action = IDLE;
               play("walk");
               return;
            }
         }
      }
      
      public function EndFuryPick(boom:int) : void
      {
         if(Boolean(boom))
         {
            PlayState(FlxG.state).furyIcons.Explode();
         }
         else
         {
            PlayState(FlxG.state).furyIcons.Hide();
         }
         if(this.action == FURYPICK)
         {
            play("idle");
            this.action = IDLE;
         }
      }
      
      public function UpdateFuryPick() : void
      {
         var g:BaseMonster = null;
         var b:BaseBullet = null;
         var f:int = 0;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var a:Number = NaN;
         if(this.action != FURYPICK || !Keebie.Dir(Keebie.B3))
         {
            this.EndFuryPick(0);
            return;
         }
         if(Boolean(Profile.skills[SkillDef.FURIOUSBLAST]) && Keebie.TapDir(Keebie.DOWN))
         {
            this.GetFury(-1);
            Global.bullets.AddBullet(NukeBlast,Bullets.NEUTRAL,x + width / 2,y + height / 2,0,0);
            FlxG.flash(4294967295,0.4);
            Sounds.play(Sounds.FuriousBlastSnd);
            for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
            {
               if(g.onScreen())
               {
                  a = Global.AngleBetweenGuys(this,g);
                  g.shouldShatter = true;
                  g.hurt(SkillDef.FuriousBlastDamage());
                  dx = Global.Cosine(a) * 40 * (1 + Profile.skills[SkillDef.FURIOUSROAR]);
                  dy = -20 * (1 + Profile.skills[SkillDef.FURIOUSROAR]);
                  if(a > 90 && a < 270)
                  {
                     f = int(LEFT);
                     dx = -dx;
                  }
                  else
                  {
                     f = int(RIGHT);
                  }
                  g.Knockback(f,dx,dy);
               }
            }
            for each(b in Global.bullets.groups[Bullets.EVIL].members)
            {
               if(b != null && b.exists && Global.randRange(0,1) < Profile.skills[SkillDef.FURIOUSROAR] * 0.2)
               {
                  b.hurt(999);
                  b.exists = false;
               }
            }
            this.EndFuryPick(1);
            return;
         }
         if(Boolean(Profile.skills[SkillDef.FURIOUSFIX]) && Keebie.TapDir(Keebie.UP))
         {
            this.action = FURYHEAL;
            this.healTime = 0;
            this.healSpent = 0;
            this.EndFuryPick(1);
            play("talk");
            return;
         }
         if(Boolean(Profile.skills[SkillDef.FURIOUSFREEZE]) && Keebie.TapDir(Keebie.LEFT))
         {
            this.GetFury(-1);
            Global.badguys.FreezeAll();
            this.action = IDLE;
            this.EndFuryPick(1);
            Sounds.play(Sounds.FreezeSnd);
            play("idle");
            return;
         }
         if(Boolean(Profile.skills[SkillDef.FURIOUSFRENZY]) && Keebie.TapDir(Keebie.RIGHT))
         {
            Sounds.play(Sounds.BerserkSnd);
            this.GetFury(-1);
            this.berserk = Profile.skills[SkillDef.FURIOUSFRENZY] * 2;
            this.action = IDLE;
            this.EndFuryPick(1);
            play("idle");
            return;
         }
         velocity.x = 0;
         acceleration.x = 0;
      }
      
      public function PedrokenHit(me:FlxSprite, you:BaseMonster) : void
      {
         if(this.dashHitList.indexOf(you) != -1)
         {
            return;
         }
         if(you.ouch >= 0.2)
         {
            return;
         }
         this.dashHitList.push(you);
         Sounds.play(Sounds.SmashSnd);
         if(this.pedrokenBurns)
         {
            if(Global.randRange(0,1) < 0.2 * Profile.skills[SkillDef.FISTSOFFLAME])
            {
               you.shouldShatter = true;
            }
            you.hurt(SkillDef.PedrokenDamage() + SkillDef.FistsOfFlameDamage());
         }
         else
         {
            you.hurt(SkillDef.PedrokenDamage());
         }
         you.Knockback(facing,80,-230);
         Global.bullets.Spark(me,you);
      }
      
      public function UpdatePedroken() : void
      {
         if(velocity.y < 0)
         {
            this.MakeShadow();
            velocity.x = 40 - 80 * int(facing == LEFT);
            if(this.pedrokenBurns)
            {
               this.hitbox.width = 24;
               if(facing == RIGHT)
               {
                  this.hitbox.x = x + width / 2 - 8;
               }
               else
               {
                  this.hitbox.x = x + width / 2 - this.hitbox.width + 8;
               }
               this.hitbox.y = y - 12;
               this.hitbox.height = height + 4;
            }
            else
            {
               this.hitbox.width = 16;
               if(facing == RIGHT)
               {
                  this.hitbox.x = x + 2;
               }
               else
               {
                  this.hitbox.x = x + width - this.hitbox.width - 2;
               }
               this.hitbox.y = y - 8;
               this.hitbox.height = height;
            }
            this.hitbox.last.x = this.hitbox.x;
            this.hitbox.last.y = this.hitbox.y;
            FlxG.overlap(this.hitbox,Global.badguys.GetGroup(Badguys.DEADLY),this.PedrokenHit);
         }
         else if(!this.punchCanHit)
         {
            play("pedroken2");
            velocity.x = 0;
            this.punchCanHit = true;
         }
         if(isTouching(FLOOR) && velocity.y >= 0)
         {
            this.action = IDLE;
            play("idle");
            return;
         }
      }
      
      public function UpdateFuryHeal() : void
      {
         if(this.action != FURYHEAL)
         {
            return;
         }
         if(!Keebie.Dir(Keebie.UP) || this.fury <= 0 && this.subFury <= 0)
         {
            this.action = IDLE;
            play("idle");
            return;
         }
         Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + Global.randRange(0,width),y + Global.randRange(0,height),270,0);
         this.healTime -= FlxG.elapsed;
         while(this.healTime <= 0)
         {
            this.healTime += 0.1;
            this.GetFury(-0.05);
            this.healSpent += 5;
            while(this.healSpent >= 20 - 3 * Profile.skills[SkillDef.FURIOUSFIX])
            {
               Sounds.play(Sounds.FuriousFixSnd);
               this.healSpent -= 20 - 3 * Profile.skills[SkillDef.FURIOUSFIX];
               if(health < Profile.max_life)
               {
                  ++health;
               }
            }
         }
      }
      
      public function DoStuff() : void
      {
         if(this.ouch > 0)
         {
            this.ouch -= FlxG.elapsed;
         }
         if(!Keebie.Dir(Keebie.B3))
         {
            this.releasedB3 = true;
         }
         if(this.berserk > 0)
         {
            this.berserk -= FlxG.elapsed;
            this.MakeShadow();
            if(this.fireball <= 0 && Keebie.TapDir(Keebie.B2))
            {
               Global.bullets.AddBullet(Fireball,Bullets.NEUTRAL,x + width / 2,y + height / 2,0 + 180 * int(facing == LEFT),0);
               this.fireball += 0.25;
            }
         }
         if(Boolean(Profile.skills[SkillDef.INNERFURY]))
         {
            this.innerFury += FlxG.elapsed;
            if(this.innerFury >= 3 - 0.5 * Profile.skills[SkillDef.INNERFURY])
            {
               this.GetFury(0.01);
               this.innerFury -= 3 - 0.5 * Profile.skills[SkillDef.INNERFURY];
            }
         }
         if(this.doubleTapped > 0)
         {
            this.doubleTapped -= FlxG.elapsed;
         }
         else
         {
            this.doubleTapped = 0;
         }
         if(this.jumpkick_reload > 0)
         {
            this.jumpkick_reload -= FlxG.elapsed;
         }
         else
         {
            this.jumpkick_reload = 0;
         }
         if(this.dash_reload > 0)
         {
            this.dash_reload -= FlxG.elapsed;
         }
         else
         {
            this.dash_reload = 0;
         }
         if(this.punch_reload > 0)
         {
            this.punch_reload -= FlxG.elapsed;
         }
         else
         {
            this.punch_reload = 0;
         }
         if(this.canJump > 0)
         {
            this.canJump -= FlxG.elapsed;
         }
         else
         {
            this.canJump = 0;
         }
         if(this.doubleJumpTime > 0)
         {
            this.doubleJumpTime -= FlxG.elapsed;
         }
         else
         {
            this.doubleJumpTime = 0;
         }
         if(this.double_tap_time > 0)
         {
            this.double_tap_time -= FlxG.elapsed;
         }
         else
         {
            this.double_tap_time = 0;
         }
         if(this.shadowTime > 0)
         {
            this.shadowTime -= FlxG.elapsed;
         }
         else
         {
            this.shadowTime = 0;
         }
         if(this.rage > 0)
         {
            this.rage -= FlxG.elapsed;
         }
         else
         {
            this.rage = 0;
         }
         if(this.action == IDLE)
         {
            if(velocity.x != 0)
            {
               play("walk");
            }
            else if(finished)
            {
               play("idle");
            }
         }
         else if(this.action == JUMP)
         {
            if(velocity.y < 0)
            {
               play("jump");
            }
            else
            {
               play("jumpdn");
            }
         }
         if(this.action == CARRY)
         {
            if(velocity.x != 0)
            {
               play("carrywalk");
            }
            else if(finished)
            {
               play("carryidle");
            }
         }
         else if(this.action == CARRYJUMP)
         {
            play("carryjump");
         }
         if(this.fireball > 0)
         {
            this.fireball -= FlxG.elapsed;
         }
         if(this.action == HITSTUN)
         {
            this.UpdateHitStun();
         }
         else if(this.action == IDLE || this.action == JUMP)
         {
            this.UpdateWalkJump();
         }
         else if(this.action == DUCK)
         {
            this.UpdateDuck();
         }
         else if(this.action == PUNCH)
         {
            this.UpdatePunch();
         }
         else if(this.action == FURYPICK)
         {
            this.UpdateFuryPick();
         }
         else if(this.action == JUMPKICK)
         {
            this.UpdateJumpKick();
         }
         else if(this.action == TORNADO)
         {
            this.UpdateTornado();
         }
         else if(this.action == DASH)
         {
            this.UpdateDash();
         }
         else if(this.action == CARRY || this.action == CARRYJUMP)
         {
            this.UpdateCarry();
         }
         else if(this.action == DIVEKICK)
         {
            this.UpdateDiveKick();
         }
         else if(this.action == FURYHEAL)
         {
            this.UpdateFuryHeal();
         }
         else if(this.action == PEDROKEN)
         {
            this.UpdatePedroken();
         }
         else if(this.action == CHARGEKICK)
         {
            this.UpdateChargeKick();
         }
         else if(this.action == PILEDRIVE)
         {
            this.UpdatePileDrive();
         }
      }
      
      public function GetFury(amt:Number) : Boolean
      {
         var over:Number = NaN;
         if(amt == 0)
         {
            return true;
         }
         if(amt < 0 && this.fury + this.subFury < -amt)
         {
            return false;
         }
         if(amt > 0 && this.fury == Profile.max_fury)
         {
            this.excessFury += amt;
         }
         else if(amt > 0 && (this.fury == Profile.max_fury - 1 && this.subFury + amt > 1))
         {
            over = this.subFury + amt - 1;
            this.excessFury += over;
         }
         if(amt < 0 && Global.randRange(0,1) < 0.03 * Profile.skills[SkillDef.FURYMASTER])
         {
            return true;
         }
         if(Boolean(Profile.skills[SkillDef.FURYOVERLOAD]))
         {
            while(this.excessFury > 0.5 - Profile.skills[SkillDef.FURYOVERLOAD] * 0.08)
            {
               this.excessFury -= 0.5 - Profile.skills[SkillDef.FURYOVERLOAD] * 0.08;
               if(health < Profile.max_life)
               {
                  ++health;
               }
            }
         }
         this.subFury += amt;
         while(this.subFury >= 1)
         {
            this.subFury -= 1;
            if(this.fury < Profile.max_fury)
            {
               ++this.fury;
               Global.bullets.MakeFlash(1);
            }
         }
         while(this.subFury < 0)
         {
            if(this.fury <= 0)
            {
               this.fury = 0;
               this.subFury = 0;
               break;
            }
            --this.fury;
            this.subFury += 1;
         }
         if(this.fury == Profile.max_fury)
         {
            this.subFury = 0;
         }
         return true;
      }
      
      override public function update() : void
      {
         if(Global.conversation)
         {
            acceleration.x = 0;
            velocity.x = 0;
            return;
         }
         if(this.action == INACTIVE)
         {
            return;
         }
         if(y > Global.level.height * Global.TILE_HEIGHT + 32)
         {
            Sounds.play(Sounds.FallSnd);
            this.hurt(1);
            x = this.safeX;
            y = this.safeY;
            velocity.x = 0;
            velocity.y = 0;
            last.x = x;
            last.y = y;
            this.action = IDLE;
            flicker(0.5);
         }
         if(this.dodge > 0 && alpha > 0.5)
         {
            alpha -= FlxG.elapsed * 2;
         }
         else if(this.dodge <= 0 && alpha < 1)
         {
            alpha += FlxG.elapsed * 2;
         }
         super.update();
         this.DoStuff();
      }
      
      public function Knockback(facing:int, xspd:Number, yspd:Number) : void
      {
         if(this.action == FURYHEAL && Global.randRange(0,100) < 20 * Profile.skills[SkillDef.FURIOUSSHIELD])
         {
            return;
         }
         this.action = HITSTUN;
         maxVelocity.x = 200;
         drag.x = 0;
         if(facing == LEFT)
         {
            velocity.x = -xspd;
         }
         else
         {
            velocity.x = xspd;
         }
         acceleration.x = 0;
         acceleration.y = this.GRAVITY_ACCELERATION;
         this.facing = LEFT + RIGHT - facing;
         velocity.y = yspd;
      }
   }
}

