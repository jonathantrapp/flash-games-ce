package xplor
{
   public class LevelStatus
   {
      
      public var passed:Boolean;
      
      public var gotHeart:Boolean;
      
      public var gotFury:Boolean;
      
      public var bestTime:Number;
      
      public var score:int;
      
      public var hardMode:Boolean;
      
      public function LevelStatus()
      {
         super();
         this.passed = false;
         this.gotHeart = false;
         this.gotFury = false;
         this.bestTime = 999999;
         this.score = 0;
         this.hardMode = false;
      }
   }
}

