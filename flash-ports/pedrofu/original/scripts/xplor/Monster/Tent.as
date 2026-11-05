package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Bullet.SmokePuff;
   import xplor.Bullets;
   import xplor.Global;
   import xplor.PlayState;
   
   public class Tent extends BaseGuy
   {
      
      public static var TentImage:Class = Tent_TentImage;
      
      public var occupied:Boolean;
      
      public var mode:int;
      
      public var expelTime:Number;
      
      public var expelCount:int;
      
      public var maxExpel:int;
      
      public function Tent(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(TentImage,true,true,35,18,true);
         height = 16;
         this.Init(tx,ty);
         addAnimation("collapse",[0,0,0,0,1,2,3,4],6,false);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         this.occupied = true;
         solid = false;
         this.mode = 0;
         this.expelTime = 0;
         this.expelCount = 0;
         super.Init(tx,ty);
      }
      
      public function Launch() : void
      {
         var g:Yak = null;
         var b:BaseGuy = null;
         if(!this.occupied)
         {
            return;
         }
         this.occupied = false;
         g = Global.badguys.AddGuy(Yak,Badguys.DEADLY,0,0) as Yak;
         if(facing == RIGHT)
         {
            g.x = x + 27;
         }
         else
         {
            g.x = x + 8;
         }
         g.y = y;
         if(Global.pedro.x + Global.pedro.width / 2 < g.x + g.width / 2)
         {
            g.facing = LEFT;
         }
         else
         {
            g.facing = RIGHT;
         }
         g.tag = tag;
         if(Global.levelNum == 0 && facing == RIGHT)
         {
            PlayState(FlxG.state).conversation.Setup(0,g);
            g.reload = 0;
            for each(b in Global.badguys.GetGroup(Badguys.BACKGD).members)
            {
               if(b is Tent)
               {
                  (b as Tent).Launch();
               }
            }
         }
         Global.bullets.AddBullet(SmokePuff,Bullets.NEUTRAL,g.x + g.width / 2,g.y + g.height / 2,0,0);
      }
      
      public function Awaken() : void
      {
         this.mode = 1;
         this.occupied = false;
         this.maxExpel = 4;
      }
      
      override public function update() : void
      {
         var b:BaseGuy = null;
         if(this.occupied && DistanceToGuy(Global.pedro) < 50)
         {
            if(Global.levelNum == 2)
            {
               for each(b in Global.badguys.GetGroup(Badguys.BACKGD).members)
               {
                  if(b is Tent)
                  {
                     (b as Tent).Awaken();
                  }
               }
            }
            else
            {
               this.Launch();
            }
         }
         if(this.mode == 1)
         {
            this.expelTime -= FlxG.elapsed;
            if(this.expelTime <= 0)
            {
               ++this.expelCount;
               this.expelTime += 4;
               this.occupied = true;
               this.Launch();
               if(this.expelCount == this.maxExpel)
               {
                  this.mode = 2;
                  tag = 0;
                  Global.bullets.AddBullet(SmokePuff,Bullets.NEUTRAL,x + width / 2,y + height / 2,0,0);
                  play("collapse");
               }
            }
         }
      }
   }
}

