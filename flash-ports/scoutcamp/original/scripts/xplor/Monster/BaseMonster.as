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
      
      public var escaping:Boolean;
      
      public var frozen:Number;
      
      public var slowed:Number;
      
      public var slowRate:Number;
      
      public var bright:Number;
      
      public var advancing:Boolean;
      
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
      
      public var speedUp:Number;
      
      public var flattened:Number;
      
      public var flung:Boolean;
      
      public var flingLock:Number;
      
      public var frz_velocity:FlxPoint;
      
      public var frz_accel:FlxPoint;
      
      public function BaseMonster(param1:int, param2:int)
      {
         super(param1,param2);
         this.frz_velocity = new FlxPoint();
         this.frz_accel = new FlxPoint();
      }
      
      override public function Reset() : void
      {
         this.level = Badguys.levelToMake;
         super.Reset();
         this.advancing = true;
         this.frozen = 0;
         this.flattened = 0;
         this.slowed = 0;
         this.flingLock = 0;
         this.frostbite = 0;
         this.shocking = 0;
         this.shockDmg = 0;
         this.poison = 0;
         this.disabled = 0;
         this.crippled = 0;
         this.poisonTick = 0;
         this.speedUp = 0;
         scale.x = 0;
         scale.y = 0;
         action = BORN;
         this.bright = 0;
         this.flung = false;
         color = 0;
         this.immune = false;
         this.escaping = false;
         if(FlxG.random() < 0.5)
         {
            facing = RIGHT;
         }
         else
         {
            facing = LEFT;
         }
         velocity.y = 0;
         acceleration.y = 0;
         health = this.maxHealth;
         frame = 0;
         if(!(this is HungryBaby))
         {
            Sounds.play(Sounds.AlienBornSnd);
         }
      }
      
      public function DoneBeingBorn() : void
      {
         if(facing == RIGHT)
         {
            velocity.x = this.speed;
         }
         else
         {
            velocity.x = -this.speed;
         }
         acceleration.y = 200;
         velocity.y = 0;
         this.bright = 255;
         color = 16777215;
         if(this.disabled > 0)
         {
            play("disabledwalk");
         }
         else
         {
            play("walk");
         }
      }
      
      public function UpdateBorn() : void
      {
         if(this.bright < 255)
         {
            this.bright += FlxG.elapsed * 255;
         }
         else
         {
            this.bright = 255;
         }
         color = int(this.bright) + int(this.bright) * 256 + int(this.bright) * 65536;
         scale.x += FlxG.elapsed;
         scale.y = scale.x;
         angle += FlxG.elapsed * 720;
         origin.y = frameHeight / 2;
         if(angle >= 360)
         {
            angle -= 360;
         }
         if(scale.x >= 1)
         {
            origin.y = frameHeight;
            scale.x = 1;
            scale.y = 1;
            action = IDLE;
            angle = 0;
            this.DoneBeingBorn();
         }
      }
      
      public function UpdateEscape() : void
      {
         origin.y = frameHeight / 2;
         if(this.bright > 0)
         {
            this.bright -= FlxG.elapsed * 255;
         }
         else
         {
            this.bright = 0;
         }
         color = int(this.bright) + int(this.bright) * 256 + int(this.bright) * 65536;
         scale.x -= FlxG.elapsed;
         scale.y = scale.x;
         angle -= FlxG.elapsed * 720;
         if(angle < 0)
         {
            angle += 360;
         }
         if(scale.x <= 0)
         {
            exists = false;
         }
         x = Global.Approach(x,startx * 16 + 8 - width / 2,FlxG.elapsed * 6);
         y = Global.Approach(y,starty * 16 + 8 - height / 2,FlxG.elapsed * 6);
      }
      
      public function EnterPortal() : void
      {
         action = ESCAPE;
         velocity.x = 0;
         velocity.y = 0;
         Global.badguys.FoodIsGone(this);
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
            this.frozen = 0;
            velocity.x = this.frz_velocity.x;
            velocity.y = this.frz_velocity.y;
            acceleration.x = this.frz_accel.x;
            acceleration.y = this.frz_accel.y;
            color = 16777215;
            if(this.disabled > 0)
            {
               play("disabledwalk");
            }
            else
            {
               play("walk");
            }
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
         frame = 0;
         if(this.flattened <= 0)
         {
            this.flattened = 0;
            velocity.x = this.frz_velocity.x;
            velocity.y = this.frz_velocity.y;
            acceleration.x = this.frz_accel.x;
            acceleration.y = this.frz_accel.y;
            if(this.disabled > 0)
            {
               play("disabledwalk");
            }
            else
            {
               play("walk");
            }
         }
      }
      
      public function BlowUpNeighbors(param1:Number, param2:Number) : void
      {
         var _loc3_:BaseMonster = null;
         for each(_loc3_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(_loc3_ != this && _loc3_ != null && !_loc3_.immune && _loc3_.exists && _loc3_.health > 0)
            {
               if(DistanceToGuy(_loc3_) <= param1)
               {
                  _loc3_.hurt(param2);
               }
            }
         }
      }
      
      public function FindAlly(param1:Number, param2:Boolean = true, param3:Boolean = true, param4:Boolean = true) : BaseMonster
      {
         var _loc5_:BaseMonster = null;
         var _loc6_:BaseMonster = null;
         _loc5_ = null;
         for each(_loc6_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(_loc6_ != this && _loc6_ != null && !_loc6_.immune && _loc6_.exists && _loc6_.health > 0 && (param2 || _loc6_.frozen <= 0) && (param3 || _loc6_.slowed <= 0) && (param4 || _loc6_.shocking <= 0))
            {
               if(DistanceToGuy(_loc6_) <= param1)
               {
                  if(_loc5_ == null)
                  {
                     _loc5_ = _loc6_;
                  }
                  else if(Global.randRange(0,1) < 0.5)
                  {
                     _loc5_ = _loc6_;
                  }
               }
            }
         }
         return _loc5_;
      }
      
      public function ShockFriend() : void
      {
         var _loc1_:BaseMonster = this.FindAlly(20 * (1 + Profile.skills[SkillDef.ARCING] * 0.4));
         if(_loc1_ != null)
         {
            Global.bullets.AddBullet(Lightning,Bullets.NEUTRAL,Global.randRange(x + width / 4,x + width * 3 / 4),Global.randRange(y + height / 4,y + height * 3 / 4),0,0);
            Global.bullets.lastAdded.target = _loc1_;
            Global.bullets.lastAdded.update();
            _loc1_.hurt(this.shockDmg);
         }
         else
         {
            Global.bullets.AddBullet(Lightning,Bullets.NEUTRAL,Global.randRange(x + width / 4,x + width * 3 / 4),Global.randRange(y + height / 4,y + height * 3 / 4),0,0);
            Global.bullets.lastAdded.target = this;
            Global.bullets.lastAdded.update();
            this.hurt(this.shockDmg);
         }
      }
      
      override public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         super.update();
         if(this.flingLock > 0)
         {
            this.flingLock -= FlxG.elapsed;
         }
         if(this.speedUp > 0)
         {
            this.speedUp -= FlxG.elapsed;
         }
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
               this.hurt(Profile.skills[SkillDef.GATHEREDMOSS] * 3 / 10);
            }
         }
         if(this.slowed > 0 || this.frozen > 0)
         {
            this.frostbite -= FlxG.elapsed;
            while(this.frostbite <= 0)
            {
               this.frostbite += 0.5;
               if(Profile.skills[SkillDef.FROSTBITE] > 0)
               {
                  _loc3_ = Profile.skills[SkillDef.FROSTBITE] * 0.25;
                  if(this.frozen > 0)
                  {
                     _loc3_ *= 2;
                  }
                  if(this.shocking > 0)
                  {
                     _loc3_ *= 1 + Profile.skills[SkillDef.CONDUCTANCE] * 0.05;
                  }
                  this.hurt(_loc3_);
               }
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
                  this.ShockFriend();
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
            if(this.flattened)
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
         if(this.flung)
         {
            if(this.flingLock <= 0)
            {
               if(isTouching(FLOOR))
               {
                  this.flung = false;
                  this.flingLock = 5;
               }
            }
            else
            {
               velocity.y = -Profile.skills[SkillDef.ROLLBACK] * 10;
            }
            return;
         }
         _loc1_ = (x + width / 2) / 16;
         _loc2_ = (y + height / 2) / 16;
         if(Global.campfire.tx == _loc1_ && Global.campfire.ty == _loc2_)
         {
            this.advancing = false;
         }
         if(startx == _loc1_ && starty == _loc2_)
         {
            this.advancing = true;
         }
         if(action == BORN)
         {
            this.UpdateBorn();
         }
         if(this.escaping)
         {
            this.advancing = false;
            if(action != ESCAPE && _loc1_ == startx && _loc2_ == starty)
            {
               this.EnterPortal();
            }
            else if(action == ESCAPE)
            {
               this.UpdateEscape();
            }
         }
         if(action == BORN || action == ESCAPE)
         {
            return;
         }
         this.BasicUpdate();
      }
      
      public function BasicUpdate() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(action == IDLE)
         {
            if(this.WillBumpWall() || isTouching(LEFT) || isTouching(RIGHT))
            {
               facing = LEFT + RIGHT - facing;
            }
            if(facing == LEFT)
            {
               velocity.x = -this.speed;
            }
            else
            {
               velocity.x = this.speed;
            }
            if(this.speedUp > 0 && !(this is Squirmy) && !(this is Speedy))
            {
               if(facing == LEFT)
               {
                  velocity.x = -40;
               }
               else
               {
                  velocity.x = 40;
               }
            }
            if(this.slowed > 0)
            {
               velocity.x *= this.slowRate;
            }
            if(this.escaping)
            {
               velocity.x *= 1 - Profile.skills[SkillDef.REFRIGERATION] * 0.05;
            }
            if(isTouching(FLOOR))
            {
               if(this.disabled > 0)
               {
                  play("disabledwalk");
               }
               else
               {
                  play("walk");
               }
               _loc1_ = (x + width / 2) / 16;
               _loc2_ = x + width / 2;
               _loc1_ *= 16;
               if(this.GoalIsUp() && (Boolean(_loc3_ = this.CanJump())))
               {
                  if(facing == LEFT && _loc2_ <= _loc1_ + 8 || facing == RIGHT && _loc2_ >= _loc1_ + 8)
                  {
                     x = _loc1_ + 8 - width / 2;
                     if(facing == LEFT && x + width / 2 > _loc1_ + 8)
                     {
                        velocity.x = -35;
                     }
                     else
                     {
                        velocity.x = 35;
                     }
                     velocity.y = -90 - 30 * (_loc3_ - 1);
                     action = JUMP;
                     if(this.disabled > 0)
                     {
                        play("disabledjump");
                     }
                     else
                     {
                        play("jump");
                     }
                  }
               }
            }
            else if(!this.OnSlope())
            {
               if(this.disabled > 0)
               {
                  play("disabledjump");
               }
               else
               {
                  play("jump");
               }
            }
            else if(this.disabled > 0)
            {
               play("disabledwalk");
            }
            else
            {
               play("walk");
            }
         }
         else if(action == JUMP)
         {
            if(facing == LEFT)
            {
               velocity.x = -35;
            }
            else
            {
               velocity.x = 35;
            }
            if(isTouching(FLOOR))
            {
               action = IDLE;
               if(this.disabled > 0)
               {
                  play("disabledwalk");
               }
               else
               {
                  play("walk");
               }
            }
         }
      }
      
      override public function hurt(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(health <= 0 || !exists || this.immune)
         {
            return;
         }
         if(health < this.maxHealth * (Profile.skills[SkillDef.FINISHHIM] * 0.08))
         {
            param1 *= 1.25;
         }
         if(this.crippled > 0)
         {
            param1 *= 1 + Profile.skills[SkillDef.CRIPPLER] * 0.1;
         }
         if(this.escaping)
         {
            param1 *= 1 + Profile.skills[SkillDef.POISONTRAP] * 0.05;
         }
         if(!noCrit)
         {
            if(Global.randRange(0,1) < Profile.skills[SkillDef.CRITICAL] * 0.02)
            {
               param1 *= 2;
               Global.bullets.AddBullet(Critical,Bullets.NEUTRAL,x + Global.randRange(0,width),y + Global.randRange(0,height),0,0);
            }
         }
         noCrit = false;
         super.hurt(param1);
         ouch = 0.2;
         if(health <= 0)
         {
            health = 0;
            ouch = 0;
            Global.bullets.AddBullet(Boom,Bullets.NEUTRAL,x + width / 2,y + height / 2,0,0);
            _loc2_ = this.moneyValue * (1 + Profile.skills[SkillDef.CASHFLOW] * 0.04);
            PlayState(FlxG.state).notice.Say("$" + _loc2_.toString(),16776960,x + width / 2,y + height / 2);
            Global.player.GetMoney(_loc2_);
            Global.player.GetXP(this.xpValue);
            exists = false;
            if(this.crippled > 0 && Boolean(Profile.skills[SkillDef.MEGAWATT]))
            {
               Global.bullets.AddBullet(Megawatt,Bullets.NEUTRAL,x + width / 2,y + height / 2,0,0);
               this.BlowUpNeighbors(30,Profile.skills[SkillDef.MEGAWATT] * 5);
            }
         }
      }
      
      public function WillFall() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = (y + height) / 16;
         if(facing == LEFT)
         {
            _loc1_ = (x + width) / 16;
         }
         else
         {
            _loc1_ = x / 16;
         }
         var _loc3_:int = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,_loc2_));
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(_loc3_).callback != null)
         {
            return false;
         }
         _loc3_ = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_ - 1,_loc2_));
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(_loc3_).callback != null)
         {
            return false;
         }
         _loc3_ = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_ + 1,_loc2_));
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(_loc3_).callback != null)
         {
            return false;
         }
         _loc2_ = (y + height + 1) / 16;
         if(facing == LEFT)
         {
            _loc1_ = (x - 1) / 16;
         }
         else
         {
            _loc1_ = (x + width + 1) / 16;
         }
         return Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,_loc2_) == 0;
      }
      
      public function WillBumpWall() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:* = 0;
         _loc2_ = int((y + height / 2) / 16);
         _loc1_ = (x + width / 2) / 16;
         var _loc3_:int = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,_loc2_));
         if(Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(_loc3_).callback != null)
         {
            _loc2_--;
         }
         if(facing == LEFT)
         {
            _loc1_ = (x - 1) / 16;
         }
         else
         {
            _loc1_ = (x + width + 1) / 16;
         }
         _loc3_ = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,_loc2_));
         if(_loc3_ != 0 && Global.level.GetLayer(Level.LAYER_SOLID).getTileProperties(_loc3_).callback == null)
         {
            return true;
         }
         return false;
      }
      
      public function CanJump() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc1_ = (x + width / 2) / 16;
         _loc2_ = (y + height / 2) / 16;
         _loc3_ = int(Global.level.jumps[_loc1_ + _loc2_ * Global.level.width]);
         if(_loc3_ >= 3 && _loc3_ <= 11)
         {
            _loc4_ = (_loc3_ - 3) % 3;
            if(_loc4_ == 0 && facing == RIGHT)
            {
               return 0;
            }
            if(_loc4_ == 1 && facing == LEFT)
            {
               return 0;
            }
            _loc4_ = (_loc3_ - 3) / 3;
            return _loc4_ + 1;
         }
         return 0;
      }
      
      public function OnSlope() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc1_ = (x + width) / 16;
         _loc2_ = (y + height + 1) / 16;
         var _loc3_:int = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,_loc2_));
         if((Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[_loc3_])
         {
            return true;
         }
         _loc1_ = (x + width / 2) / 16;
         if((Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[_loc3_])
         {
            return true;
         }
         _loc1_ = x / 16;
         if((Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[_loc3_])
         {
            return true;
         }
         return false;
      }
      
      public function GoalIsUp() : Boolean
      {
         if(!this.advancing)
         {
            return starty * 16 < y + height / 2;
         }
         return Global.campfire.y < y + height / 2;
      }
      
      public function GotFood() : void
      {
         this.escaping = true;
         if(this.advancing)
         {
            facing = LEFT + RIGHT - facing;
            this.advancing = false;
         }
      }
      
      public function ExtendaFreeze(param1:Number) : void
      {
         if(this.frozen > 0)
         {
            if(this.frozen < param1)
            {
               this.frozen = param1;
            }
         }
         else
         {
            this.Freeze(param1);
         }
      }
      
      public function Freeze(param1:Number) : void
      {
         if(this.frozen > 0)
         {
            return;
         }
         if(this is Beasty || this is Hungry)
         {
            param1 *= 0.5;
         }
         this.frozen = param1;
         if(this.flattened <= 0)
         {
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
      
      public function Slow(param1:Number, param2:Number, param3:Boolean = false) : void
      {
         if(this is Beasty || this is Hungry)
         {
            param1 *= 0.5;
         }
         this.slowed = param1;
         this.slowRate = 1 - param2;
         if(param3)
         {
            this.disabled = this.slowed;
         }
      }
      
      public function Shock(param1:Number, param2:Number) : void
      {
         if(this.shocking <= 0)
         {
            this.shockTick = 0;
            this.shockTickCount = 0;
         }
         this.shocking = param1;
         if(this.shockDmg < param2)
         {
            this.shockDmg = param2;
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
      
      public function Poison() : void
      {
         this.poison = 10.05;
      }
      
      public function Flatten(param1:Number) : void
      {
         if(this.flattened > 0)
         {
            return;
         }
         if(this is Beasty)
         {
            param1 *= 0.5;
         }
         if(this is Hungry)
         {
            return;
         }
         this.flattened = param1;
         if(this.frozen <= 0)
         {
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
      
      public function Fling(param1:int) : void
      {
         if(action == BORN || action == ESCAPE || this.flung || this.flingLock > 0 || param1 == this.facing)
         {
            return;
         }
         if(this is Hungry)
         {
            return;
         }
         this.flung = true;
         if(param1 == LEFT)
         {
            velocity.x = -70;
         }
         else
         {
            velocity.x = 70;
         }
         if(this is Beasty)
         {
            velocity.x *= 0.5;
         }
         velocity.y = -10 * 2.5;
         if(this.disabled > 0)
         {
            play("disabledjump");
         }
         else
         {
            play("jump");
         }
         action = JUMP;
         this.immune = false;
         this.flingLock = 0.1;
      }
   }
}

