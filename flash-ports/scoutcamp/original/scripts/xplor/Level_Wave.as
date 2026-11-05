package xplor
{
   import org.flixel.*;
   
   public class Level_Wave
   {
      
      public var guys:Array;
      
      public var delay:Array;
      
      public var wait:Number;
      
      public function Level_Wave(param1:Array)
      {
         super();
         this.guys = new Array();
         this.delay = new Array();
         this.wait = 0;
         this.LoadDef(param1);
      }
      
      public function IsOver() : Boolean
      {
         if(this.guys.length == 0)
         {
            return true;
         }
         return false;
      }
      
      public function Update() : Boolean
      {
         if(this.wait > 0)
         {
            this.wait -= FlxG.elapsed;
         }
         else
         {
            if(this.guys.length <= 0)
            {
               return false;
            }
            Global.portals.BirthGuy(this.guys.shift());
            this.wait = this.delay.shift();
         }
         return true;
      }
      
      public function Setup_Add(param1:Class, param2:Number) : void
      {
         this.guys.push(param1);
         this.delay.push(param2);
      }
      
      public function Setup_AddSeries(param1:Class, param2:Number, param3:int) : void
      {
         var _loc4_:int = 0;
         while(_loc4_ < param3)
         {
            this.Setup_Add(param1,param2);
            _loc4_++;
         }
      }
      
      public function LoadDef(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         this.guys = new Array();
         this.delay = new Array();
         while(_loc2_ < param1.length)
         {
            _loc3_ = int(param1[_loc2_]);
            this.Setup_AddSeries(param1[_loc2_ + 1],param1[_loc2_ + 2],_loc3_);
            _loc2_ += 3;
         }
      }
   }
}

