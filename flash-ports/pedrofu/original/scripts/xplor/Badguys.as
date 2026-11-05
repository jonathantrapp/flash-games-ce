package xplor
{
   import org.flixel.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.*;
   
   public class Badguys
   {
      
      public static var levelToMake:int;
      
      public static const DEADLY:uint = 0;
      
      public static const NEUTRAL:uint = 1;
      
      public static const BACKGD:uint = 2;
      
      public static const NUM_GROUPS:uint = 3;
      
      public var groups:Array;
      
      public function Badguys(state:PlayState)
      {
         super();
         this.groups = new Array(new FlxGroup(),new FlxGroup(),new FlxGroup());
      }
      
      public function GetGroup(n:int) : FlxGroup
      {
         if(n < 0 || n >= NUM_GROUPS)
         {
            return null;
         }
         return this.groups[n];
      }
      
      public function AddToState(group:uint, state:PlayState) : void
      {
         state.add(this.groups[group] as FlxGroup);
      }
      
      public function AddGuy(guy:Class, group:uint, x:int, y:int) : BaseGuy
      {
         var b:BaseGuy = new guy(x,y);
         (this.groups[group] as FlxGroup).add(b);
         return b;
      }
      
      public function OnPlatform(pee:FlxObject, plat:FlxObject) : void
      {
      }
      
      public function BadguyBump(me:FlxSprite, you:FlxSprite) : void
      {
         if(me.x + me.width / 2 < you.x + you.width / 2)
         {
            me.x -= 1;
            you.x += 1;
         }
         else
         {
            you.x -= 1;
            me.x += 1;
         }
      }
      
      public function Collide() : void
      {
         FlxG.collide(PlayState(FlxG.state).border,this.groups[DEADLY] as FlxGroup);
         FlxG.collide(Global.level.GetLayer(Level.LAYER_SOLID),this.groups[DEADLY] as FlxGroup);
         FlxG.collide(Global.level.GetLayer(Level.LAYER_SOLID),this.groups[NEUTRAL] as FlxGroup);
         FlxG.collide(Global.level.GetLayer(Level.LAYER_SOLID),this.groups[BACKGD] as FlxGroup);
      }
      
      public function TargetEnemy(me:FlxSprite, side:int = 0) : FlxSprite
      {
         var dist:Number = NaN;
         var best:Number = NaN;
         var bestGuy:FlxSprite = null;
         var s:FlxSprite = null;
         bestGuy = null;
         var myPt:FlxPoint = new FlxPoint(me.x + me.width / 2,me.y + me.height / 2);
         var youPt:FlxPoint = new FlxPoint();
         for each(s in (this.groups[DEADLY] as FlxGroup).members)
         {
            if(s != null && s.health > 0 && s.exists)
            {
               youPt.x = s.x + s.width / 2;
               youPt.y = s.y + s.height / 2;
               if((side == 0 || side == 1 && youPt.x < myPt.x || side == 2 && youPt.x > myPt.x) && Global.level.GetLayer(Level.LAYER_SOLID).ray(myPt,youPt,null,1))
               {
                  dist = Global.Distance(myPt.x,myPt.y,youPt.x,youPt.y);
                  if(bestGuy == null || dist < best)
                  {
                     bestGuy = s;
                     best = dist;
                  }
               }
            }
         }
         return bestGuy;
      }
      
      public function ResetAll() : void
      {
         var i:int = 0;
         var j:int = 0;
         for(i = 0; i < 4; i++)
         {
            for(j = 0; j < (this.groups[i] as FlxGroup).length; j++)
            {
               BaseGuy((this.groups[i] as FlxGroup).members[j]).Reset();
            }
         }
      }
      
      public function BadguysLeft() : int
      {
         var n:int = 0;
         var b:BaseGuy = null;
         n = 0;
         for each(b in this.groups[DEADLY].members)
         {
            if(b != null && b.exists && b.health > 0)
            {
               n++;
            }
         }
         return n;
      }
      
      public function TagCheck(t:int) : Boolean
      {
         var b:BaseGuy = null;
         for each(b in this.groups[DEADLY].members)
         {
            if(b != null && !(b is Barrier_Orb) && b.exists && b.health > 0 && b.tag == t)
            {
               return false;
            }
         }
         for each(b in this.groups[BACKGD].members)
         {
            if(b != null && !(b is Barrier) && b.exists && b.health > 0 && b.tag == t)
            {
               return false;
            }
         }
         Global.level.TagTripped(t);
         return true;
      }
      
      public function BarrierTags(t:int) : Boolean
      {
         var b:BaseGuy = null;
         for each(b in this.groups[DEADLY].members)
         {
            if(b != null && b is Barrier_Orb && b.exists && b.health > 0 && b.tag == t)
            {
               return false;
            }
         }
         FlxG.flash(4294967040,0.4);
         Sounds.play(Sounds.BarrierDownSnd);
         for each(b in this.groups[BACKGD].members)
         {
            if(b != null && b is Barrier && b.exists && b.health > 0 && b.tag == t)
            {
               b.exists = false;
            }
         }
         return true;
      }
      
      public function FreezeAll() : void
      {
         var b:BaseMonster = null;
         Global.bullets.FreezeAll();
         for each(b in this.groups[DEADLY].members)
         {
            b.Freeze(Profile.skills[SkillDef.FURIOUSFREEZE] * 1.5);
         }
      }
   }
}

