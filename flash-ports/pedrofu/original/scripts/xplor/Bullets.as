package xplor
{
   import flash.geom.Rectangle;
   import org.flixel.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.*;
   
   public class Bullets
   {
      
      public static const EVIL:uint = 0;
      
      public static const NEUTRAL:uint = 1;
      
      public static const BACKGD:uint = 2;
      
      public static const GOOD:uint = 3;
      
      public var groups:Array;
      
      public var lastAdded:BaseBullet;
      
      public var shieldBounceSound:Number;
      
      public function Bullets(state:PlayState)
      {
         super();
         this.groups = new Array(new FlxGroup(),new FlxGroup(),new FlxGroup(),new FlxGroup());
         this.shieldBounceSound = 0;
      }
      
      public function AddBehindToState(state:PlayState) : void
      {
         state.add(this.groups[BACKGD]);
      }
      
      public function AddToState(state:PlayState) : void
      {
         state.add(this.groups[NEUTRAL]);
         state.add(this.groups[EVIL]);
         state.add(this.groups[GOOD]);
      }
      
      public function AddBullet(bul:Class, group:uint, x:Number, y:Number, a:Number, dmg:Number) : void
      {
         var b:BaseBullet = null;
         b = (this.groups[group] as FlxGroup).recycle(bul) as BaseBullet;
         b.shoot(x,y,a,dmg);
         b.last.x = b.x;
         b.last.y = b.y;
         b.wasTouching = FlxObject.NONE;
         b.touching = FlxObject.NONE;
         this.lastAdded = b;
      }
      
      public function Shot(witch:FlxObject, bul:FlxObject) : void
      {
      }
      
      public function WipeBad() : void
      {
         var g:BaseBullet = null;
         for each(g in this.groups[EVIL].members)
         {
            if(g != null && g.exists)
            {
               g.hurt(100);
            }
         }
      }
      
      public function Collide() : void
      {
         if(this.shieldBounceSound > 0)
         {
            this.shieldBounceSound -= FlxG.elapsed;
         }
         FlxG.collide(Global.level.GetLayer(Level.LAYER_SOLID),this.groups[EVIL] as FlxGroup);
         FlxG.collide(Global.level.GetLayer(Level.LAYER_SOLID),this.groups[NEUTRAL] as FlxGroup);
         FlxG.collide(Global.level.GetLayer(Level.LAYER_SOLID),this.groups[GOOD] as FlxGroup);
      }
      
      public function ResetAll() : void
      {
         var i:int = 0;
         var j:int = 0;
         for(i = 0; i < 2; i++)
         {
            for(j = 0; j < (this.groups[i] as FlxGroup).length; j++)
            {
               BaseBullet((this.groups[i] as FlxGroup).members[j]).exists = false;
            }
         }
      }
      
      public function Spark(hitter:FlxSprite, hittee:FlxSprite, big:Boolean = false) : void
      {
         var x:Number = NaN;
         var y:Number = NaN;
         var r:Rectangle = new Rectangle();
         if(hitter.x < hittee.x)
         {
            r.x = hittee.x;
            r.width = hitter.x + hitter.width - hittee.x;
         }
         else
         {
            r.x = hitter.x;
            r.width = hittee.x + hittee.width - hitter.x;
         }
         if(hitter.y < hittee.y)
         {
            r.y = hittee.y;
            r.height = hitter.y + hitter.height - hittee.y;
         }
         else
         {
            r.y = hitter.y;
            r.height = hittee.y + hittee.height - hitter.y;
         }
         x = Global.randRange(r.x,r.x + r.width);
         y = Global.randRange(r.y,r.y + r.height);
         this.AddBullet(HitSpark,Bullets.NEUTRAL,x,y,int(big),0);
      }
      
      public function FreezeAll() : void
      {
         var b:BaseBullet = null;
         for each(b in this.groups[EVIL].members)
         {
            b.Freeze(Profile.skills[SkillDef.FURIOUSFREEZE] * 1.5);
         }
      }
      
      public function MakeFlash(n:int) : void
      {
         this.AddBullet(FlashFX,Bullets.NEUTRAL,Global.pedro.x + Global.pedro.width / 2,Global.pedro.y + Global.pedro.height / 2,n,0);
      }
   }
}

