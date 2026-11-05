package xplor
{
   import org.flixel.*;
   import xplor.Menus.SkillDef;
   
   public class WaveManager
   {
      
      public var waves:Array;
      
      public var waveTime:Array;
      
      public var activeWaves:Array;
      
      public var wavesDone:int;
      
      public var allDone:Boolean;
      
      public var timeToNext:Number;
      
      public var waveNum:int;
      
      public var timePerWave:Number;
      
      public var speed:int;
      
      public function WaveManager()
      {
         super();
      }
      
      public function TotalWaves() : int
      {
         return this.waves.length - 1;
      }
      
      public function GetWave(param1:int) : Array
      {
         return this.waves[param1 + 1] as Array;
      }
      
      public function CalcCount(param1:int, param2:int) : int
      {
         var _loc6_:int = 0;
         var _loc3_:Class = WaveBlock.monsType[param2];
         var _loc4_:Array = this.GetWave(param1 - 1);
         var _loc5_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc4_.length)
         {
            if(_loc4_[_loc6_ + 1] == _loc3_)
            {
               _loc5_ += _loc4_[_loc6_];
            }
            _loc6_ += 3;
         }
         return _loc5_;
      }
      
      public function StartLevel(param1:int) : void
      {
         this.waves = WaveDef.GetLevel(param1);
         if(this.waves == null)
         {
         }
         this.waveTime = new Array();
         this.timePerWave = Number(this.waves[0]);
         var _loc2_:int = 1;
         while(_loc2_ < this.waves.length)
         {
            this.waveTime.push(Number(this.timePerWave * _loc2_));
            _loc2_++;
         }
         this.activeWaves = new Array();
         this.allDone = false;
         this.wavesDone = 0;
         this.waveNum = 0;
         this.speed = 0;
      }
      
      public function Update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         this.timeToNext = 0;
         _loc1_ = 0;
         while(_loc1_ < this.waves.length)
         {
            if(this.waveTime[_loc1_] > 0)
            {
               if(this.timeToNext == 0)
               {
                  this.timeToNext = this.waveTime[_loc1_];
               }
               if(this.speed > 0)
               {
                  --this.waveTime[_loc1_];
               }
               else
               {
                  this.waveTime[_loc1_] -= FlxG.elapsed;
               }
               if(this.waveTime[_loc1_] <= 0)
               {
                  if(this.speed > 0)
                  {
                     --this.speed;
                     if(Profile.skills[SkillDef.ON_A_ROLL])
                     {
                        _loc2_ = (this.waveNum + 1) * Profile.skills[SkillDef.ON_A_ROLL] * 2;
                        Global.player.GetMoney(_loc2_);
                        PlayState(FlxG.state).notice.Say("$" + _loc2_.toString(),16776960,FlxG.camera.scroll.x + 20,FlxG.camera.scroll.y + 20);
                     }
                  }
                  this.waveTime[_loc1_] = 0;
                  this.activeWaves.push(new Level_Wave(this.waves[_loc1_ + 1]));
                  this.timeToNext = 0;
                  ++this.waveNum;
                  PlayState(FlxG.state).hud.waves.Explode();
               }
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.activeWaves.length)
         {
            Badguys.levelToMake = Global.levelNum * 3 + this.waveNum - this.activeWaves.length + _loc1_ + 1;
            if(Global.levelNum < 4)
            {
               Badguys.levelToMake -= Global.levelNum;
            }
            if(this.activeWaves[_loc1_] != null && !(this.activeWaves[_loc1_] as Level_Wave).Update())
            {
               this.activeWaves[_loc1_] = null;
               ++this.wavesDone;
            }
            _loc1_++;
         }
         if(this.wavesDone == this.waves.length - 1)
         {
            this.allDone = true;
         }
      }
      
      public function TimeToNext() : int
      {
         if(this.allDone)
         {
            return -1;
         }
         return this.timeToNext;
      }
      
      public function SendWave(param1:int) : void
      {
         Sounds.play(Sounds.SendWaveSnd);
         this.speed = param1 - this.waveNum;
      }
   }
}

