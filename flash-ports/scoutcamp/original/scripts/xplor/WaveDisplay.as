package xplor
{
   import org.flixel.*;
   import xplor.Bullet.*;
   
   public class WaveDisplay extends FlxGroup
   {
      
      public static var WaveBoomImage:Class = WaveDisplay_WaveBoomImage;
      
      public var first:int;
      
      public var blocks:Array;
      
      public var boom:FlxSprite;
      
      public function WaveDisplay()
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:FlxSprite = null;
         super();
         _loc3_ = new FlxSprite(0,6);
         _loc3_.scrollFactor.x = 0;
         _loc3_.scrollFactor.y = 0;
         _loc3_.makeGraphic(320,4,4279308578);
         add(_loc3_);
         _loc3_ = new FlxSprite(0,7);
         _loc3_.scrollFactor.x = 0;
         _loc3_.scrollFactor.y = 0;
         _loc3_.makeGraphic(320,2,4283782536);
         add(_loc3_);
         this.blocks = new Array();
         _loc2_ = Global.waveManager.TotalWaves();
         _loc1_ = 0;
         while(_loc1_ < _loc2_)
         {
            this.AddWave(Global.waveManager.GetWave(_loc1_));
            _loc1_++;
         }
         this.boom = new FlxSprite();
         this.boom.loadGraphic(WaveBoomImage,false,false,48,16,true);
         this.boom.scrollFactor.x = 0;
         this.boom.scrollFactor.y = 0;
         this.boom.visible = false;
         add(this.boom);
         this.first = 0;
      }
      
      public function AddWave(param1:Array) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         _loc2_ = new Array();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(_loc2_.indexOf(param1[_loc3_ * 3 + 1]) == -1)
            {
               _loc2_.push(param1[_loc3_ * 3 + 1]);
            }
            _loc3_++;
         }
         var _loc4_:WaveBlock = new WaveBlock(_loc2_);
         add(_loc4_);
         this.blocks.push(_loc4_);
         _loc4_.x = 100 + members.length * 48;
         _loc4_.y = 0;
      }
      
      public function Explode() : void
      {
         this.boom.alpha = 1;
         this.boom.scale.x = 1;
         this.boom.scale.y = 1;
         this.boom.visible = true;
         this.boom.blend = "add";
      }
      
      override public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:FlxPoint = null;
         var _loc4_:Boolean = false;
         var _loc5_:WaveBlock = null;
         var _loc6_:int = 0;
         if(this.boom.visible)
         {
            this.boom.scale.x += FlxG.elapsed;
            this.boom.scale.y += FlxG.elapsed * 2;
            this.boom.alpha -= FlxG.elapsed * 2;
            if(this.boom.alpha == 0)
            {
               this.boom.visible = false;
            }
         }
         if(Global.waveManager.allDone)
         {
            return;
         }
         _loc1_ = 0;
         _loc2_ = 49 / Global.waveManager.timePerWave;
         _loc3_ = new FlxPoint(FlxG.mouse.screenX,FlxG.mouse.screenY);
         if(Global.player.boxMode == Player.SENDWAVE)
         {
            Global.player.SetMode(Player.CANTPLACE,0);
         }
         _loc4_ = true;
         for each(_loc5_ in this.blocks)
         {
            if(_loc1_ < Global.waveManager.waveNum)
            {
               _loc5_.visible = false;
            }
            else
            {
               _loc5_.x = Global.waveManager.timeToNext * _loc2_ + (_loc1_ - Global.waveManager.waveNum) * 49;
            }
            _loc1_++;
            if(_loc5_.visible && _loc5_.overlapsPoint(_loc3_) && Global.player.FreeMode())
            {
               _loc5_.frame = 1;
               Global.player.SetMode(Player.SENDWAVE,_loc1_);
               _loc6_ = _loc5_.FaceOn(_loc3_);
               if(_loc6_ != -1)
               {
                  PlayState(FlxG.state).hud.SetBeware(_loc6_,Global.levelNum * 4 + _loc1_,Global.waveManager.CalcCount(_loc1_,_loc6_));
                  _loc4_ = false;
               }
            }
            else
            {
               _loc5_.frame = 0;
            }
         }
         if(_loc4_)
         {
            PlayState(FlxG.state).hud.HideBeware();
         }
      }
   }
}

