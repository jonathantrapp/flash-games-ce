package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class BaseMonster extends BaseGuy
   {
      
      public static var noCrit:Boolean = false;
      
      public var maxHealth:int;
      
      public var moneyValue:int;
      
      public var xpValue:int;
      
      public var name:String;
      
      public var speed:Number;
      
      public var level:int;
      
      public var frozen:Number;
      
      public var frozenHits:int;
      
      public var slowed:Number;
      
      public var slowRate:Number;
      
      public var bright:Number;
      
      public var shocking:Number;
      
      public var shockTick:Number;
      
      public var shockDmg:Number;
      
      public var shockTickCount:int;
      
      public var frostbite:Number;
      
      public var poison:Number;
      
      public var poisonTick:Number;
      
      public var disabled:Number;
      
      public var crippled:Number;
      
      public var immune:Boolean;
      
      public var flattened:Number;
      
      public var stunned:Number;
      
      public var shouldShatter:Boolean;
      
      public var throwable:Boolean;
      
      public var upsideHold:Boolean;
      
      public var throwDmg:Number;
      
      public var throwHurt:Number;
      
      public var noReaction:Boolean;
      
      public var throwBonkList:Array;
      
      public var frz_velocity:FlxPoint;
      
      public var frz_accel:FlxPoint;
      
      public var frz_action:int;
      
      public function BaseMonster(tx:int, ty:int)
      {
         super(tx,ty);
         this.frz_velocity = new FlxPoint();
         this.frz_accel = new FlxPoint();
      }
      
      override public function Reset() : void
      {
         this.level = Badguys.levelToMake;
         super.Reset();
         this.throwable = true;
         this.frozen = 0;
         this.flattened = 0;
         this.stunned = 0;
         this.slowed = 0;
         this.frostbite = 0;
         this.shocking = 0;
         this.shockDmg = 0;
         this.poison = 0;
         this.disabled = 0;
         this.crippled = 0;
         this.poisonTick = 0;
         this.throwHurt = 0;
         scale.x = 1;
         scale.y = 1;
         action = IDLE;
         this.bright = 0;
         this.throwBonkList = new Array();
         this.immune = false;
         this.noReaction = false;
         this.shouldShatter = false;
         if(FlxG.random() < 0.5)
         {
            facing = RIGHT;
         }
         else
         {
            facing = LEFT;
         }
         velocity.y = 0;
         acceleration.y = 400;
         health = this.maxHealth;
         frame = 0;
         trace(this,"Lvl",this.level,"Life",this.maxHealth,"$",this.moneyValue,"XP",this.xpValue);
      }
      
      public function UpdateCarried() : void
      {
         if(Global.pedro.action == Pedro.PILEDRIVE)
         {
            if(Global.pedro.facing == LEFT)
            {
               x = Global.pedro.x - width / 2;
               facing = RIGHT;
            }
            else
            {
               x = Global.pedro.x + Global.pedro.width - width / 2;
               facing = LEFT;
            }
            y = Global.pedro.y + Global.pedro.height - height;
            angle = 0;
         }
         else
         {
            x = Global.pedro.x + Global.pedro.width / 2 - width / 2;
            y = Global.pedro.y - height / 2;
            if(Global.pedro.facing == LEFT)
            {
               if(this.upsideHold)
               {
                  angle = 180;
               }
               else
               {
                  angle = 270;
               }
               facing = LEFT;
            }
            else
            {
               if(this.upsideHold)
               {
                  angle = 180;
               }
               else
               {
                  angle = 90;
               }
               facing = RIGHT;
            }
         }
      }
      
      public function FreeAgain() : void
      {
         angle = 0;
         acceleration.y = 400;
         angularVelocity = 0;
         action = IDLE;
         play("idle");
      }
      
      public function GetPickedUp() : void
      {
         if(!this.throwable)
         {
            this.hurt(Global.throwDmg);
            return;
         }
         play("disabled");
         action = CARRIED;
         acceleration.y = 0;
         velocity.x = 0;
         velocity.y = 0;
      }
      
      public function GetThrown() : void
      {
         if(!this.throwable)
         {
            this.hurt(Global.throwDmg);
            return;
         }
         this.throwBonkList = new Array();
         this.throwHurt = 0.1;
         x = Global.pedro.x + Global.pedro.width / 2 - width / 2;
         y = Global.pedro.y - height / 2;
         maxVelocity.x = 80 * Global.throwSpeed;
         if(Global.pedro.facing == RIGHT)
         {
            angularVelocity = 360 * Global.throwSpeed;
            velocity.x = maxVelocity.x;
         }
         else
         {
            angularVelocity = -360 * Global.throwSpeed;
            velocity.x = -maxVelocity.x;
         }
         velocity.y = -50 * Global.throwSpeed;
         acceleration.y = 200;
         action = THROWN;
         this.throwDmg = Global.throwDmg;
      }
      
      public function TossedOther(dir:int) : void
      {
         if(!this.throwable)
         {
            return;
         }
         this.throwBonkList = new Array();
         this.throwHurt = 0.1;
         maxVelocity.x = 80 * Global.throwSpeed;
         if(dir == RIGHT)
         {
            angularVelocity = 360 * Global.throwSpeed;
            velocity.x = 60;
         }
         else
         {
            angularVelocity = -360 * Global.throwSpeed;
            velocity.x = -60;
         }
         velocity.y = -50 * Global.throwSpeed;
         acceleration.y = 200;
         action = THROWN;
         this.throwDmg = Global.throwDmg;
      }
      
      public function ThrowBonk(me:BaseMonster, you:BaseMonster) : void
      {
         var tx:Number = NaN;
         var ty:Number = NaN;
         if(you.action == THROWN)
         {
            return;
         }
         if(this.throwBonkList.indexOf(you) != -1)
         {
            return;
         }
         if(!you.throwable)
         {
            you.hurt(this.throwDmg * (Profile.skills[SkillDef.COCONUTBONK] * 0.1));
         }
         tx = (me.x + me.width / 2 + (you.x + you.width / 2)) / 2;
         ty = (me.y + me.height / 2 + (you.y + you.height / 2)) / 2;
         Global.bullets.AddBullet(HitSpark,Bullets.NEUTRAL,tx,ty,0,0);
         if(velocity.x > 0)
         {
            facing = RIGHT;
         }
         else
         {
            facing = LEFT;
         }
         Global.throwSpeed = maxVelocity.x / 80;
         Global.throwSpeed *= 0.4 + Profile.skills[SkillDef.COCONUTBONK] * 0.1;
         if(Global.throwSpeed < 0.5)
         {
            Global.throwSpeed = 0.5;
         }
         this.hurt(this.throwDmg);
         this.stunned = 0;
         if(health > 0)
         {
            this.FreeAgain();
         }
         Global.throwDmg = this.throwDmg * (Profile.skills[SkillDef.COCONUTBONK] * 0.1);
         if(you.throwable)
         {
            you.TossedOther(facing);
            you.throwBonkList.push(this);
         }
      }
      
      public function UpdateThrown() : void
      {
         var tx:Number = NaN;
         var ty:Number = NaN;
         this.throwHurt -= FlxG.elapsed;
         if(this.throwHurt < 0)
         {
            this.throwHurt = 0;
         }
         if(this.throwHurt == 0 && isTouching(ANY))
         {
            tx = x + width / 2;
            ty = y + height / 2;
            Global.bullets.AddBullet(HitSpark,Bullets.NEUTRAL,tx,ty,0,0);
            this.hurt(this.throwDmg);
            this.stunned = 0;
            if(health > 0)
            {
               this.FreeAgain();
            }
            trace(health);
            return;
         }
         if(this.throwHurt == 0 && Boolean(Profile.skills[SkillDef.COCONUTBONK]))
         {
            FlxG.overlap(this,Global.badguys.GetGroup(Badguys.DEADLY),this.ThrowBonk);
         }
      }
      
      public function Thaw() : void
      {
         this.frozen = 0;
         velocity.x = this.frz_velocity.x;
         velocity.y = this.frz_velocity.y;
         acceleration.x = this.frz_accel.x;
         acceleration.y = this.frz_accel.y;
         color = 16777215;
         action = this.frz_action;
      }
      
      public function UpdateFrozen() : void
      {
         if(ouch <= 0)
         {
            color = 4487167;
         }
         this.frozen -= FlxG.elapsed;
         frame = 0;
         if(this.frozen <= 0)
         {
            this.Thaw();
         }
      }
      
      public function UpdateFlat() : void
      {
         this.flattened -= FlxG.elapsed;
         origin.y = frameHeight;
         if(scale.y > 0.1)
         {
            scale.y -= FlxG.elapsed * 10;
         }
         else
         {
            scale.y = 0.1;
         }
         play("idle");
         acceleration.y = 400;
         if(this.flattened <= 0)
         {
            this.flattened = 0;
            scale.y = 1;
            origin.y = frameHeight / 2;
            velocity.x = this.frz_velocity.x;
            velocity.y = this.frz_velocity.y;
            acceleration.x = this.frz_accel.x;
            acceleration.y = this.frz_accel.y;
            action = HITSTUN;
            play("hitstun");
         }
      }
      
      public function BlowUpNeighbors(range:Number, dmg:Number) : void
      {
         var g:BaseMonster = null;
         for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(g != this && g != null && !g.immune && g.exists && g.health > 0)
            {
               if(DistanceToGuy(g) <= range)
               {
                  g.hurt(dmg);
               }
            }
         }
      }
      
      public function FindAlly(range:Number, frozenOK:Boolean = true, slowedOK:Boolean = true, zapOK:Boolean = true) : BaseMonster
      {
         var target:BaseMonster = null;
         var g:BaseMonster = null;
         target = null;
         for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(g != this && g != null && !g.immune && g.exists && g.health > 0 && (frozenOK || g.frozen <= 0) && (slowedOK || g.slowed <= 0) && (zapOK || g.shocking <= 0))
            {
               if(DistanceToGuy(g) <= range)
               {
                  if(target == null)
                  {
                     target = g;
                  }
                  else if(Global.randRange(0,1) < 0.5)
                  {
                     target = g;
                  }
               }
            }
         }
         return target;
      }
      
      public function BasicUpdate() : void
      {
         if(action == THROWN)
         {
            this.UpdateThrown();
         }
         else if(action == CARRIED)
         {
            this.UpdateCarried();
         }
      }
      
      override public function update() : void
      {
         if(y > Global.level.height * Global.TILE_HEIGHT + 32 && !(this is Yak_Master))
         {
            Sounds.play(Sounds.FallSnd);
            health = 1;
            this.hurt(999);
         }
         if(Global.conversation)
         {
            velocity.x = 0;
            acceleration.x = 0;
            if(this is Yak_Master)
            {
               (this as Yak_Master).Hover();
            }
            return;
         }
         super.update();
         if(this.disabled > 0)
         {
            this.disabled -= FlxG.elapsed;
         }
         if(this.crippled > 0)
         {
            this.crippled -= FlxG.elapsed;
         }
         if(this.poison > 0)
         {
            this.poison -= FlxG.elapsed;
            this.poisonTick -= FlxG.elapsed;
            while(this.poisonTick <= 0)
            {
               this.poisonTick += 1;
            }
         }
         if(this.slowed > 0 || this.frozen > 0)
         {
            this.frostbite -= FlxG.elapsed;
            while(this.frostbite <= 0)
            {
               this.frostbite += 0.5;
            }
         }
         if(this.shocking > 0)
         {
            this.shocking -= FlxG.elapsed;
            this.shockTick += FlxG.elapsed;
            if(this.shockTick >= 0.25)
            {
               ++this.shockTickCount;
               this.shockTick -= 0.25;
               if(this.shockTickCount >= 2)
               {
                  this.shockTickCount -= 2;
               }
               else
               {
                  Global.bullets.AddBullet(Lightning,Bullets.NEUTRAL,Global.randRange(x + width / 4,x + width * 3 / 4),Global.randRange(y + height / 4,y + height * 3 / 4),0,0);
                  Global.bullets.lastAdded.target = this;
                  Global.bullets.lastAdded.update();
               }
            }
         }
         if(ouch > 0)
         {
            color = 16746632;
            ouch -= FlxG.elapsed;
            if(ouch <= 0)
            {
               ouch = 0;
            }
         }
         else if(this.slowed <= 0 && this.frozen <= 0)
         {
            if(this.poison > 0)
            {
               color = 7864217;
            }
            else
            {
               color = 16777215;
            }
         }
         else if(this.frozen > 0)
         {
            color = 4487167;
         }
         else
         {
            color = 10083839;
         }
         if(this.slowed > 0)
         {
            this.slowed -= FlxG.elapsed;
         }
         if(this.frozen > 0)
         {
            if(Boolean(this.flattened))
            {
               this.UpdateFlat();
            }
            this.UpdateFrozen();
            return;
         }
         if(this.flattened > 0)
         {
            this.UpdateFlat();
            return;
         }
         if(scale.y < 1)
         {
            scale.y += FlxG.elapsed * 2;
         }
         else
         {
            scale.y = 1;
         }
         this.BasicUpdate();
      }
      
      override public function hurt(dmg:Number) : void
      {
         var i:int = 0;
         var money:int = 0;
         var g:BaseMonster = null;
         var p:PowerUp = null;
         if(health <= 0 || !exists || this.immune)
         {
            return;
         }
         if(Global.pedro.berserk > 0)
         {
            dmg *= 2;
         }
         if(this.frozen > 0)
         {
            --this.frozenHits;
            if(this.frozenHits <= 0)
            {
               dmg *= 1 + Profile.skills[SkillDef.DEEPFREEZE] * 0.2;
               this.Thaw();
            }
         }
         if(!this.noReaction)
         {
            action = HITSTUN;
            if(this.stunned < 0.2)
            {
               this.stunned = 0.2;
            }
            velocity.x = 0;
            play("hitstun");
         }
         noCrit = false;
         if(Global.pedro.rage > 0)
         {
            dmg *= 1 + Profile.skills[SkillDef.RAGINGBURRO] * 0.08;
         }
         if(Global.pedro.fury == Profile.max_fury && Global.pedro.health == Profile.max_life)
         {
            dmg *= 1 + Profile.skills[SkillDef.MAXIMUMFORCE] * 0.06;
         }
         super.hurt(dmg);
         if(Global.randRange(0,1) < 0.02 * Profile.skills[SkillDef.CRUSHINGBLOW])
         {
            for(i = 0; i < 8; i++)
            {
               Global.bullets.AddBullet(FireBit,Bullets.NEUTRAL,x + width / 2,y + height / 2,i * (360 / 8),1);
            }
            health *= 0.8;
            Sounds.play(Sounds.CrushingBlowSnd);
         }
         ouch = 0.2;
         if(health <= 0)
         {
            if(this is Yak_Big || this is Robot || this is Yak_Master || Global.levelNum == 2 && this is Yak_Armor || Global.levelNum == 4 && this is Yak_Ninja)
            {
               Sounds.play(Sounds.BossDieSnd);
            }
            health = 0;
            ouch = 0;
            money = this.moneyValue;
            money *= 1 + Profile.skills[SkillDef.FANCYFOOTWORK] * 0.06;
            if(y < Global.level.height * Global.TILE_HEIGHT)
            {
               if(Boolean(Profile.skills[SkillDef.COMBOBOMBO]))
               {
                  Global.bullets.AddBullet(Boom,Bullets.NEUTRAL,x + width / 2,y + height / 2,1,0);
                  for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
                  {
                     if(g != null && g.exists && g.health > 0 && g.visible && Global.Distance(g.x + g.width / 2,g.y + g.height / 2,x + width / 2,y + height / 2) < 25)
                     {
                        g.hurt(Profile.skills[SkillDef.COMBOBOMBO] * 2);
                     }
                  }
               }
               else
               {
                  Global.bullets.AddBullet(Boom,Bullets.NEUTRAL,x + width / 2,y + height / 2,0,0);
               }
               PlayState(FlxG.state).notice.Say(money.toString() + "xp",16776960,x + width / 2,y + height / 2);
               if(Global.randRange(0,1) < 0.33333333)
               {
                  p = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,(x + width / 2) / 16,(y + height / 2) / 16) as PowerUp;
                  p.which = 7;
                  p.frame = 7;
               }
            }
            else
            {
               PlayState(FlxG.state).notice.Say(money.toString() + "xp",16776960,x + width / 2,Global.level.height * Global.TILE_HEIGHT - 16);
            }
            if(Global.randRange(0,1) < 0.06 * Profile.skills[SkillDef.RECOVERY])
            {
               if(Global.pedro.health < Profile.max_life)
               {
                  ++Global.pedro.health;
               }
            }
            Global.pedro.GetFury(0.02 * Profile.skills[SkillDef.FURIOUSBLOOD]);
            Profile.GetXP(money);
            exists = false;
            if(tag != 0)
            {
               Global.badguys.TagCheck(tag);
            }
         }
         PlayState(FlxG.state).hud.HitBadguy(this);
      }
      
      public function WillFall() : Boolean
      {
         var tx:int = 0;
         var ty:int = 0;
         ty = (y + height) / 16;
         if(facing == LEFT)
         {
            tx = (x + width) / 16;
         }
         else
         {
            tx = x / 16;
         }
         var t:int = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx,ty));
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(t).callback != null)
         {
            return false;
         }
         t = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx - 1,ty));
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(t).callback != null)
         {
            return false;
         }
         t = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx + 1,ty));
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(t).callback != null)
         {
            return false;
         }
         ty = (y + height + 1) / 16;
         if(facing == LEFT)
         {
            tx = (x - 1) / 16;
         }
         else
         {
            tx = (x + width + 1) / 16;
         }
         return Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx,ty) == 0;
      }
      
      public function WillBumpWall() : Boolean
      {
         var tx:int = 0;
         var ty:int = 0;
         ty = (y + height / 2) / 16;
         tx = (x + width / 2) / 16;
         var t:int = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx,ty));
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(t).callback != null)
         {
            ty--;
         }
         if(facing == LEFT)
         {
            tx = (x - 1) / 16;
         }
         else
         {
            tx = (x + width + 1) / 16;
         }
         t = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx,ty));
         if(t != 0 && Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(t).callback == null)
         {
            return true;
         }
         return false;
      }
      
      public function CanJump() : int
      {
         var tx:int = 0;
         var ty:int = 0;
         var mex:int = 0;
         var dir:int = 0;
         tx = (x + width / 2) / 16;
         ty = (y + height / 2) / 16;
         mex = int(Global.level.jumps[tx + ty * Global.level.width]);
         if(mex >= 3 && mex <= 11)
         {
            dir = (mex - 3) % 3;
            if(dir == 0 && facing == RIGHT)
            {
               return 0;
            }
            if(dir == 1 && facing == LEFT)
            {
               return 0;
            }
            dir = (mex - 3) / 3;
            return dir + 1;
         }
         return 0;
      }
      
      public function OnSlope() : Boolean
      {
         var tx:int = 0;
         var ty:int = 0;
         tx = (x + width) / 16;
         ty = (y + height + 1) / 16;
         var n:int = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(tx,ty));
         if(Boolean((Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[n]))
         {
            return true;
         }
         tx = (x + width / 2) / 16;
         if(Boolean((Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[n]))
         {
            return true;
         }
         tx = x / 16;
         if(Boolean((Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[n]))
         {
            return true;
         }
         return false;
      }
      
      public function GoalIsUp() : Boolean
      {
         return Global.pedro.y < y - 16;
      }
      
      public function ExtendaFreeze(time:Number) : void
      {
         if(this.frozen > 0)
         {
            if(this.frozen < time)
            {
               this.frozen = time;
            }
         }
         else
         {
            this.Freeze(time);
         }
      }
      
      public function Freeze(time:Number) : void
      {
         if(this.frozen > 0)
         {
            return;
         }
         this.frozenHits = Profile.skills[SkillDef.DEEPFREEZE] + 1;
         this.frozen = time;
         if(this.flattened <= 0)
         {
            this.frz_action = action;
            this.frz_velocity.x = velocity.x;
            this.frz_velocity.y = velocity.y;
            this.frz_accel.x = acceleration.x;
            this.frz_accel.y = acceleration.y;
         }
         velocity.x = 0;
         velocity.y = 0;
         acceleration.x = 0;
         acceleration.y = 0;
         color = 4487167;
      }
      
      public function Slow(time:Number, amt:Number, disable:Boolean = false) : void
      {
         this.slowed = time;
         this.slowRate = 1 - amt;
         if(disable)
         {
            this.disabled = this.slowed;
         }
      }
      
      public function Shock(time:Number, dmg:Number) : void
      {
         if(this.shocking <= 0)
         {
            this.shockTick = 0;
            this.shockTickCount = 0;
         }
         this.shocking = time;
         if(this.shockDmg < dmg)
         {
            this.shockDmg = dmg;
         }
      }
      
      public function Cripple() : void
      {
         this.crippled = 0.5;
         if(this.disabled < 0.5)
         {
            this.disabled = 0.5;
         }
      }
      
      public function Stun(time:Number) : void
      {
         this.stunned = time;
      }
      
      public function Poison() : void
      {
         this.poison = 10.05;
      }
      
      public function Flatten(time:Number) : void
      {
         if(this.flattened > 0)
         {
            return;
         }
         if(this.noReaction)
         {
            return;
         }
         this.flattened = time;
         if(this.frozen <= 0)
         {
            this.frz_action = action;
            this.frz_velocity.x = velocity.x;
            this.frz_velocity.y = velocity.y;
            this.frz_accel.x = acceleration.x;
            this.frz_accel.y = acceleration.y;
         }
         velocity.x = 0;
         velocity.y = 0;
         acceleration.x = 0;
         acceleration.y = 0;
      }
      
      public function Knockback(facing:int, xspd:Number, yspd:Number) : void
      {
         if(this.noReaction)
         {
            return;
         }
         if(Boolean(this.frozen))
         {
            this.frz_velocity.x = xspd - 2 * xspd * int(facing == LEFT);
            this.frz_velocity.y = yspd;
            return;
         }
         action = HITSTUN;
         if(facing == LEFT)
         {
            velocity.x = -xspd;
         }
         else
         {
            velocity.x = xspd;
         }
         velocity.y = yspd;
         if(yspd < 0)
         {
            --y;
         }
         acceleration.x = 0;
         acceleration.y = 400;
         this.facing = LEFT + RIGHT - facing;
      }
   }
}

