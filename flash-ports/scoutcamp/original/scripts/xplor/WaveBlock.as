package xplor
{
   import org.flixel.FlxPoint;
   import org.flixel.FlxSprite;
   import xplor.Monster.*;
   
   public class WaveBlock extends FlxSprite
   {
      
      public static var WaveBoxImage:Class = WaveBlock_WaveBoxImage;
      
      public static var WaveMonsterImage:Class = WaveBlock_WaveMonsterImage;
      
      public static var monsType:Array = new Array(Beefy,Squirmy,Lumpy,Wormy,Speedy,Beasty,Blinky,Hungry,Scary);
      
      public var mons:FlxSprite;
      
      public var monsList:Array;
      
      public function WaveBlock(param1:Array)
      {
         var _loc2_:Class = null;
         var _loc3_:int = 0;
         super(0,0);
         scrollFactor.x = 0;
         scrollFactor.y = 0;
         loadGraphic(WaveBoxImage,true,false,48,16,true);
         this.mons = new FlxSprite(0,0);
         this.mons.scrollFactor.x = 0;
         this.mons.scrollFactor.y = 0;
         this.mons.loadGraphic(WaveMonsterImage,true,false,14,16,true);
         this.monsList = new Array();
         for each(_loc2_ in param1)
         {
            _loc3_ = 0;
            while(_loc3_ < monsType.length)
            {
               if(monsType[_loc3_] == _loc2_)
               {
                  this.monsList.push(_loc3_);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      override public function draw() : void
      {
         if(!visible)
         {
            return;
         }
         super.draw();
         var _loc1_:int = x + 3;
         if(this.monsList.length == 1)
         {
            _loc1_ += 14;
         }
         else if(this.monsList.length == 2)
         {
            _loc1_ += 7;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.monsList.length)
         {
            if(this.monsList[_loc2_] != -1)
            {
               this.mons.x = _loc1_ + _loc2_ * 14;
               this.mons.y = y;
               this.mons.frame = this.monsList[_loc2_];
               this.mons.draw();
            }
            _loc2_++;
         }
      }
      
      public function FaceOn(param1:FlxPoint) : int
      {
         var _loc2_:int = x + 3;
         if(this.monsList.length == 1)
         {
            _loc2_ += 14;
         }
         else if(this.monsList.length == 2)
         {
            _loc2_ += 7;
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.monsList.length)
         {
            if(this.monsList[_loc3_] != -1)
            {
               if(param1.x >= _loc2_ + _loc3_ * 14 && param1.x < _loc2_ + (_loc3_ + 1) * 14)
               {
                  return this.monsList[_loc3_];
               }
            }
            _loc3_++;
         }
         return -1;
      }
   }
}

