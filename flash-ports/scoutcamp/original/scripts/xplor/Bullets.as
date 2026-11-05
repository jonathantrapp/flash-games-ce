package xplor
{
   import org.flixel.*;
   import xplor.Bullet.*;
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
      
      public function Bullets(param1:PlayState)
      {
         super();
         this.groups = new Array(new FlxGroup(),new FlxGroup(),new FlxGroup(),new FlxGroup());
         this.shieldBounceSound = 0;
      }
      
      public function AddBehindToState(param1:PlayState) : void
      {
         param1.add(this.groups[BACKGD]);
      }
      
      public function AddToState(param1:PlayState) : void
      {
         param1.add(this.groups[NEUTRAL]);
         param1.add(this.groups[EVIL]);
         param1.add(this.groups[GOOD]);
      }
      
      public function AddBullet(param1:Class, param2:uint, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         var _loc7_:BaseBullet = null;
         _loc7_ = (this.groups[param2] as FlxGroup).recycle(param1) as BaseBullet;
         _loc7_.shoot(param3,param4,param5,param6);
         _loc7_.last.x = _loc7_.x;
         _loc7_.last.y = _loc7_.y;
         _loc7_.wasTouching = FlxObject.NONE;
         _loc7_.touching = FlxObject.NONE;
         this.lastAdded = _loc7_;
      }
      
      public function Shot(param1:FlxObject, param2:FlxObject) : void
      {
      }
      
      public function WipeBad() : void
      {
         var _loc1_:BaseBullet = null;
         for each(_loc1_ in this.groups[EVIL].members)
         {
            if(_loc1_ != null && _loc1_.exists)
            {
               _loc1_.hurt(100);
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
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < 2)
         {
            _loc2_ = 0;
            while(_loc2_ < (this.groups[_loc1_] as FlxGroup).length)
            {
               BaseBullet((this.groups[_loc1_] as FlxGroup).members[_loc2_]).exists = false;
               _loc2_++;
            }
            _loc1_++;
         }
      }
   }
}

