package xplor
{
   public class LevelStatus
   {
      
      public var passed:Boolean;
      
      public var bestTime:Number;
      
      public var score:int;
      
      public var hardMode:Boolean;
      
      public function LevelStatus()
      {
         super();
         this.passed = false;
         this.bestTime = 999999;
      }
   }
}

