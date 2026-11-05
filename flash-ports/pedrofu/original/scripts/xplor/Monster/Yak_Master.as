package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   
   public class Yak_Master extends BaseMonster
   {
      
      public static var YakImage:Class = Yak_Master_YakImage;
      
      public static const INACTIVE:int = 2;
      
      public static const DIZZY:int = 3;
      
      public static const RECOVER:int = 4;
      
      public var dizzyTime:Number;
      
      public var hoverY:Number;
      
      public var spokenYet:Boolean;
      
      public var inactive:Boolean;
      
      public var teleTime:Boolean;
      
      public var guardTime:Number;
      
      public var orbPos:Array = new Array(7,24,7,18,15,15,24,17,24,20);
      
      public function Yak_Master(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(YakImage,true,true,23,29,true);
         addAnimation("idle",[0,1],10,true);
         addAnimation("walk",[0,1],10,true);
         addAnimation("hitstun",[8],10,true);
         addAnimation("disabled",[4,5,6,7],20,true);
         addAnimation("dizzy",[4,5,6,7],20,true);
         addAnimation("talk",[2,3],10,true);
         addAnimation("recover",[9,10,9,10,9,10],10,false);
         width = 11;
         offset.x = 6;
         speed = 15;
         height = 14;
         offset.y = 10;
         name = "Master Yak";
         this.Init(tx,ty);
      }
      
      public static function Life(lvl:int) : int
      {
         return 150;
      }
      
      public static function Money(lvl:int) : int
      {
         return 500;
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
         reload = 3;
         acceleration.y = 0;
         this.hoverY = y;
         y -= 5;
         this.spokenYet = false;
         action = INACTIVE;
         this.inactive = true;
         facing = LEFT;
         if(Global.levelNum == 14)
         {
            facing = RIGHT;
         }
         this.dizzyTime = 0;
         maxVelocity.x = 70;
         maxVelocity.y = 70;
         this.teleTime = false;
         this.guardTime = 10;
      }
      
      public function UpdateHitStun() : void
      {
         if(this.dizzyTime == 0)
         {
            this.Recover();
         }
         stunned -= FlxG.elapsed;
         if(stunned <= 0)
         {
            if(isTouching(DOWN))
            {
               action = DIZZY;
               play("dizzy");
               return;
            }
         }
      }
      
      public function UpdateIdle() : void
      {
         var a:Number = NaN;
         var g:BaseMonster = null;
         if(this.dizzyTime > 0)
         {
            maxVelocity.y = 400;
            action = DIZZY;
            return;
         }
         maxVelocity.y = 70;
         play("idle");
         a = Global.AngleBetweenGuys(this,Global.pedro);
         if(a >= 90 && a <= 270)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         acceleration.x = Global.Cosine(a) * 30;
         acceleration.y = Global.Sine(a) * 30;
         if(isTouching(RIGHT) && velocity.x > 0 || isTouching(LEFT) && velocity.x < 0)
         {
            velocity.x = -velocity.x;
         }
         if(isTouching(FLOOR) && velocity.y > 0 || isTouching(CEILING) && velocity.y < 0)
         {
            velocity.y = -velocity.y;
         }
         if(!this.teleTime)
         {
            if(!LineOfSight(this,Global.pedro))
            {
               this.teleTime = true;
            }
         }
         if(reload <= 0)
         {
            reload += 3;
            Sounds.play(Sounds.MissileSnd);
            Global.bullets.AddBullet(BadFireball,Bullets.EVIL,x + width / 2,y + height / 2,a,0);
            if(this.teleTime && !LineOfSight(this,Global.pedro))
            {
               Sounds.play(Sounds.TeleportSnd);
               this.teleTime = false;
               x = Global.pedro.x + Global.pedro.width / 2 - width / 2;
               y = Global.pedro.y + Global.pedro.height / 2 - height / 2;
               last.x = x;
               last.y = y;
               velocity.x = 0;
               velocity.y = 0;
               alpha = 0;
            }
         }
         for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(g.exists && g.health > 0 && g is Barrier_Orb)
            {
               return;
            }
         }
         Sounds.play(Sounds.BarrierDownSnd);
         FlxG.flash(4294967040,0.1);
         this.dizzyTime = 8;
         action = DIZZY;
         maxVelocity.y = 400;
         this.Knockback(facing,0,0);
      }
      
      public function Recover() : void
      {
         var g:BaseGuy = null;
         action = RECOVER;
         play("recover");
         for(var i:int = 0; i < this.orbPos.length; i += 2)
         {
            g = Global.badguys.AddGuy(Barrier_Orb,Badguys.DEADLY,this.orbPos[i],this.orbPos[i + 1]);
            g.alpha = 0;
         }
      }
      
      public function UpdateDizzy() : void
      {
         velocity.x = 0;
         velocity.y = 0;
         play("dizzy");
         if(this.dizzyTime <= 0)
         {
            this.Recover();
         }
      }
      
      public function UpdateRecover() : void
      {
         if(finished)
         {
            action = IDLE;
            velocity.x = 0;
            velocity.y = -30;
         }
      }
      
      public function Hover() : void
      {
         if(y > this.hoverY)
         {
            acceleration.y = -60;
         }
         else if(y < this.hoverY)
         {
            acceleration.y = 60;
         }
         if(y < this.hoverY - 6)
         {
            y = this.hoverY - 6;
         }
         else if(y > this.hoverY + 6)
         {
            y = this.hoverY + 6;
         }
      }
      
      public function UpdateInactive() : void
      {
         this.Hover();
         if(Global.levelNum == 10)
         {
            action = IDLE;
            PlayState(FlxG.state).conversation.Setup(8,this);
         }
         else if(Global.levelNum == 11)
         {
            action = IDLE;
            PlayState(FlxG.state).conversation.Setup(9,this);
         }
         else if(Global.levelNum == 13)
         {
            action = IDLE;
            PlayState(FlxG.state).conversation.Setup(10,this);
         }
         else if(DistanceToGuy(Global.pedro) < 100)
         {
            action = IDLE;
            if(Global.levelNum == 8)
            {
               PlayState(FlxG.state).conversation.Setup(5,this);
            }
            else
            {
               PlayState(FlxG.state).conversation.Setup(11,this);
               this.inactive = false;
            }
         }
      }
      
      public function PoofAway() : void
      {
         exists = false;
         Global.bullets.AddBullet(SmokePuff,Bullets.NEUTRAL,x + width / 2,y + height / 2,-1,0);
      }
      
      public function SummonTorgo() : void
      {
         exists = false;
         Global.bullets.AddBullet(SmokePuff,Bullets.NEUTRAL,x + width / 2,y + height / 2,-1,0);
         var g:Yak_Big = Global.badguys.AddGuy(Yak_Big,Badguys.DEADLY,x / 16,y / 16) as Yak_Big;
         g.x = x + 120;
         g.y = y;
         g.tag = this.tag;
         g.IntroLaunch();
         for(var i:int = 18; i <= 24; i++)
         {
            Global.level.GetLayer(Level.LAYER_SOLID).setTile(97,i,56);
            Global.level.GetLayer(Level.LAYER_SOLID).setTile(116,i,56);
         }
      }
      
      public function SummonGuards() : void
      {
         var c:int = 0;
         var g:BaseMonster = null;
         c = 0;
         for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
         {
            if(g.exists && g.health > 0)
            {
               c++;
            }
         }
         if(c < 10)
         {
            Global.badguys.AddGuy(Yakolyte,Badguys.DEADLY,13,24);
            Global.bullets.AddBullet(SmokePuff,Bullets.EVIL,13 * 16 + 8,24 * 16 + 8,0,0);
            Global.badguys.AddGuy(Yakolyte,Badguys.DEADLY,18,24);
            Global.bullets.AddBullet(SmokePuff,Bullets.EVIL,18 * 16 + 8,24 * 16 + 8,0,0);
         }
         this.guardTime = 10;
      }
      
      override public function BasicUpdate() : void
      {
         if(y > Global.level.height * Global.TILE_HEIGHT + 32)
         {
            x = 15 * 16 + 8 - width / 2;
            y = 20 * 16;
            last.x = x;
            last.y = y;
            alpha = 0;
         }
         super.BasicUpdate();
         if(alpha < 1)
         {
            alpha += FlxG.elapsed * 4;
         }
         if(reload > 0)
         {
            reload -= FlxG.elapsed;
         }
         if(this.dizzyTime > 0)
         {
            this.dizzyTime -= FlxG.elapsed;
         }
         if(this.guardTime > 0 && !this.inactive)
         {
            this.guardTime -= FlxG.elapsed;
            if(this.guardTime <= 0)
            {
               this.SummonGuards();
            }
         }
         if(this.inactive)
         {
            action = INACTIVE;
            play("idle");
            this.UpdateInactive();
            return;
         }
         if(action == INACTIVE)
         {
            this.UpdateInactive();
         }
         else if(action == IDLE)
         {
            this.UpdateIdle();
         }
         else if(action == DIZZY)
         {
            this.UpdateDizzy();
         }
         else if(action == HITSTUN)
         {
            this.UpdateHitStun();
         }
         else if(action == RECOVER)
         {
            this.UpdateRecover();
         }
      }
      
      override public function hurt(n:Number) : void
      {
         if(this.inactive)
         {
            return;
         }
         if(action != DIZZY && action != HITSTUN)
         {
            return;
         }
         maxVelocity.y = 400;
         super.hurt(n);
         if(health == 0)
         {
            --Global.mailLeft;
         }
      }
      
      override public function Knockback(facing:int, xspd:Number, yspd:Number) : void
      {
         if(action != DIZZY && action != HITSTUN)
         {
            return;
         }
         super.Knockback(facing,xspd,yspd);
      }
   }
}

