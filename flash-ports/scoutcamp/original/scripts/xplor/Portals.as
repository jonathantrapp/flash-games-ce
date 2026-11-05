package xplor
{
   import org.flixel.*;
   import xplor.Bullet.Darkness;
   
   public class Portals
   {
      
      public var list:Array;
      
      public var active:int = 0;
      
      public var darkTime:Number;
      
      public function Portals()
      {
         super();
         this.list = new Array();
         this.active = 0;
         this.darkTime = 0;
      }
      
      public function Add(param1:int, param2:int) : void
      {
         this.list.push(param1);
         this.list.push(param2);
      }
      
      public function BirthGuy(param1:Class) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = int(FlxObject.RIGHT);
         _loc3_ = int(this.list[this.active * 2 + 0]);
         _loc4_ = int(this.list[this.active * 2 + 1]);
         if(_loc3_ > Global.level.width - 3)
         {
            _loc2_ = int(FlxObject.LEFT);
         }
         else if(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc3_ + 1,_loc4_) != 0)
         {
            _loc2_ = int(FlxObject.LEFT);
         }
         Global.badguys.AddGuy(param1,Badguys.DEADLY,this.list[this.active * 2 + 0],this.list[this.active * 2 + 1]).facing = _loc2_;
         ++this.active;
         if(this.active >= this.list.length / 2)
         {
            this.active = 0;
         }
      }
      
      public function Update() : void
      {
         var _loc1_:int = 0;
         this.darkTime -= FlxG.elapsed;
         if(this.darkTime <= 0)
         {
            this.darkTime += 0.1;
            _loc1_ = 0;
            while(_loc1_ < this.list.length)
            {
               Global.bullets.AddBullet(Darkness,Bullets.NEUTRAL,this.list[_loc1_] * 16 + Global.randRange(0,16),this.list[_loc1_ + 1] * 16 + Global.randRange(0,16),Global.randRange(0,360),0);
               _loc1_ += 2;
            }
         }
      }
   }
}

