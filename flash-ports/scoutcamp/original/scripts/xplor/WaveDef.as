package xplor
{
   import xplor.Monster.*;
   
   public class WaveDef
   {
      
      public static const waves:Array = new Array(new Array(40,new Array(10,Lumpy,3),new Array(10,Lumpy,2.5),new Array(5,Squirmy,1,1,Squirmy,5,5,Squirmy,2),new Array(10,Lumpy,2),new Array(3,Beefy,10),new Array(1,Squirmy,1,1,Lumpy,1,1,Squirmy,1,1,Lumpy,1,1,Squirmy,1,1,Lumpy,1,1,Squirmy,1,1,Lumpy,1,1,Squirmy,1,1,Lumpy,1)),new Array(40,new Array(10,Lumpy,2.5),new Array(10,Lumpy,2),new Array(3,Lumpy,2,3,Squirmy,2,1,Beefy,5),new Array(10,Squirmy,1),new Array(5,Beefy,3)),new Array(30,new Array(10,Lumpy,1.5),new Array(5,Lumpy,2.5),new Array(1,Beefy,1),new Array(15,Squirmy,1),new Array(5,Lumpy,1,5,Squirmy,1),new Array(1,Beefy,2.5),new Array(10,Lumpy,0.5),new Array(3,Beefy,1.5),new Array(1,Beasty,1)),new Array(40,new Array(3,Beefy,5),new Array(10,Lumpy,2),new Array(10,Squirmy,1.5),new Array(20,Lumpy,1),new Array(5,Beefy,4),new Array(20,Squirmy,1),new Array(10,Lumpy,2),new Array(5,Beefy,4),new Array(10,Squirmy,1.5),new Array(20,Lumpy,1),new Array(1,Beasty,1)),new Array(30,new Array(5,Lumpy,2.5),new Array(5
      ,Lumpy,2.5),new Array(1,Beefy,1),new Array(15,Squirmy,1),new Array(5,Lumpy,1,5,Squirmy,1,2,Beefy,2.5),new Array(3,Wormy,5),new Array(10,Squirmy,1.5),new Array(30,Lumpy,0.5),new Array(10,Beefy,1.5),new Array(20,Lumpy,0.75),new Array(20,Squirmy,0.75),new Array(10,Lumpy,1),new Array(10,Beefy,1.5),new Array(6,Wormy,2.5)),new Array(40,new Array(10,Lumpy,2),new Array(3,Beefy,6),new Array(20,Squirmy,1),new Array(1,Beefy,10,3,Wormy,3),new Array(20,Lumpy,1),new Array(20,Lumpy,1),new Array(20,Lumpy,1),new Array(10,Beefy,2),new Array(10,Squirmy,1,3,Wormy,3),new Array(10,Lumpy,1,10,Beefy,1),new Array(5,Squirmy,2,5,Lumpy,2),new Array(40,Lumpy,0.5),new Array(2,Beefy,10)),new Array(50,new Array(10,Lumpy,3),new Array(20,Lumpy,1.5),new Array(25,Lumpy,1),new Array(30,Lumpy,0.75),new Array(5,Beefy,6),new Array(50,Squirmy,0.5),new Array(10,Lumpy,3),new Array(30,Lumpy,1),new Array(20,Beefy,1),new Array(3,Beasty,10)),new Array(50,new Array(10,Lumpy,3),new Array(20,Lumpy,1.5),new Array(30,Lumpy,1),new Array(5
      ,Beefy,6),new Array(50,Squirmy,0.1),new Array(10,Lumpy,3),new Array(30,Lumpy,1),new Array(30,Beefy,1),new Array(20,Wormy,1),new Array(30,Squirmy,0.5,20,Lumpy,0.5,10,Beefy,0.5),new Array(3,Beasty,10)),new Array(60,new Array(10,Lumpy,3),new Array(20,Lumpy,1.5),new Array(10,Lumpy,1,2,Speedy,1,10,Lumpy,1),new Array(5,Beefy,6),new Array(50,Squirmy,0.1),new Array(10,Lumpy,3),new Array(30,Lumpy,1),new Array(30,Beefy,1),new Array(20,Wormy,1),new Array(30,Squirmy,0.5,20,Lumpy,0.5,10,Beefy,0.5),new Array(3,Beasty,10)),new Array(80,new Array(30,Lumpy,2),new Array(5,Lumpy,1,1,Blinky,1,10,Squirmy,1),new Array(10,Beefy,6),new Array(5,Lumpy,2,1,Blinky,2,10,Lumpy,2),new Array(1,Blinky,1,30,Squirmy,1),new Array(10,Wormy,6),new Array(15,Lumpy,1,1,Speedy,1,15,Lumpy,1),new Array(5,Beefy,3,1,Blinky,3,5,Beefy,3),new Array(1,Beasty,1,1,Blinky,1,1,Beasty,1,1,Blinky,1,1,Beasty,1,1,Blinky,1,1,Beasty,1)),new Array(80,new Array(9,Lumpy,1,3,Blinky,1,9,Lumpy,1),new Array(21,Squirmy,2,3,Speedy,5),new Array(9,Beefy,6)
      ,new Array(12,Lumpy,1,24,Speedy,1),new Array(24,Lumpy,0.5,12,Beefy,1),new Array(3,Beasty,0.1),new Array(60,Squirmy,1),new Array(30,Lumpy,2),new Array(3,Lumpy,1,3,Blinky,1,6,Lumpy,1,3,Blinky,1,9,Lumpy,1,3,Blinky,1,6,Lumpy,1),new Array(9,Wormy,5),new Array(9,Beasty,5)),new Array(60,new Array(10,Lumpy,3),new Array(10,Wormy,3),new Array(20,Lumpy,1.5),new Array(30,Squirmy,0.5),new Array(10,Beefy,3),new Array(30,Squirmy,1),new Array(3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5),new Array(3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5),new Array(3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5),new Array(3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5),new Array(3,Lumpy,1.5,1,Blinky,1.5,3
      ,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5,3,Lumpy,1.5,1,Blinky,1.5),new Array(20,Beefy,1.5),new Array(20,Beefy,1.5),new Array(60,Squirmy,0.5),new Array(10,Blinky,1),new Array(10,Beasty,3)),new Array(50,new Array(10,Lumpy,2),new Array(20,Lumpy,1),new Array(30,Squirmy,1),new Array(5,Scary,6),new Array(1,Scary,1,3,Beefy,4,1,Scary,1),new Array(1,Scary,1,1,Blinky,1,1,Scary,5,1,Scary,1,1,Blinky,1,1,Scary,5,1,Scary,1,1,Blinky,1,1,Scary,5),new Array(10,Lumpy,1,3,Wormy,3,10,Lumpy,1),new Array(10,Beefy,1,1,Scary,1,1,Speedy,1),new Array(20,Beefy,1.5),new Array(60,Squirmy,0.5),new Array(10,Scary,2),new Array(4,Beasty,7)),new Array(60,new Array(20,Squirmy,1),new Array(40,Squirmy,0.5),new Array(50,Squirmy,0.5),new Array(10,Lumpy,1,1,Scary,1),new Array(1,Blinky,1,4,Lumpy,1,1,Blinky,1,4,Lumpy,1,1,Blinky,1,4,Lumpy,1),new Array(1,Beasty,1),new Array(30,Lumpy,1),new Array(60,Squirmy,0.5),new Array(10,Beefy,1,5,Speedy,1),new Array(3,Lumpy,1,1,Blinky,1,1,Beasty,1,1,Blinky,1,3
      ,Lumpy,1),new Array(30,Beefy,1),new Array(1,Scary,1,10,Lumpy,1,1,Scary,1,10,Lumpy,1,1,Scary,1),new Array(30,Lumpy,1),new Array(1,Blinky,1,1,Scary,1,1,Blinky,1,1,Scary,1,1,Blinky,1,1,Scary,1,1,Blinky,1,1,Scary,1,1,Blinky,1,1,Scary,1),new Array(5,Beasty,5,30,Squirmy,0.5)),new Array(60,new Array(1,Beasty,1),new Array(20,Lumpy,1),new Array(40,Squirmy,0.5),new Array(10,Lumpy,1,1,Speedy,1),new Array(10,Beefy,1),new Array(10,Lumpy,1,1,Blinky,1,10,Lumpy,1,1,Blinky,1,5,Lumpy,1),new Array(5,Squirmy,1,1,Scary,1,5,Squirmy,1,1,Scary,1,5,Squirmy,1,1,Scary,1),new Array(30,Lumpy,1),new Array(40,Squirmy,0.5),new Array(20,Beefy,1),new Array(5,Beasty,6),new Array(1,Scary,1,1,Blinky,1,1,Wormy,1,1,Scary,1,1,Blinky,1,1,Wormy,1,1,Scary,1,1,Blinky,1,1,Wormy,1,1,Scary,1,1,Blinky,1,1,Wormy,1,1,Scary,1,1,Blinky,1,1,Wormy,1,1,Scary,1,1,Blinky,1,1,Wormy,1)),new Array(100,new Array(50,Lumpy,1),new Array(100,Squirmy,0.5),new Array(30,Beefy,1),new Array(3,Blinky,1,9,Lumpy,0.3,3,Wormy,1,9,Lumpy,0.3,3,Blinky,1,9,Lumpy,0.3)
      ,new Array(12,Wormy,1),new Array(3,Beasty,1),new Array(18,Scary,1),new Array(50,Lumpy,1),new Array(100,Squirmy,0.5),new Array(30,Beefy,1),new Array(50,Lumpy,1),new Array(100,Squirmy,0.5),new Array(30,Beefy,1),new Array(9,Beefy,1,18,Blinky,1,3,Speedy,1,9,Beefy,1),new Array(30,Lumpy,1),new Array(9,Beasty,1),new Array(3,Scary,1,3,Beefy,1,3,Scary,1,3,Lumpy,1,3,Scary,1,3,Beefy,1,3,Lumpy,1,3,Scary,1),new Array(24,Beasty,1)),new Array(90,new Array(1,Hungry,1)));
      
      public static const levels:int = waves.length;
      
      public function WaveDef()
      {
         super();
      }
      
      public static function GetLevel(param1:int) : Array
      {
         if(param1 < 0 || param1 >= levels)
         {
            return null;
         }
         var _loc2_:Array = new Array();
         _loc2_[0] = waves[param1][0];
         var _loc3_:int = 1;
         while(_loc3_ < waves[param1].length)
         {
            _loc2_[_loc3_] = (waves[param1][_loc3_] as Array).slice();
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

