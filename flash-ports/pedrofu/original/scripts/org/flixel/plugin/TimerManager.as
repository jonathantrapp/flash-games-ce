package org.flixel.plugin
{
   import org.flixel.*;
   
   public class TimerManager extends FlxBasic
   {
      
      protected var _timers:Array;
      
      public function TimerManager()
      {
         super();
         this._timers = new Array();
         visible = false;
      }
      
      override public function destroy() : void
      {
         this.clear();
         this._timers = null;
      }
      
      override public function update() : void
      {
         var timer:FlxTimer = null;
         var i:int = this._timers.length - 1;
         while(i >= 0)
         {
            timer = this._timers[i--] as FlxTimer;
            if(timer != null && !timer.paused && !timer.finished && timer.time > 0)
            {
               timer.update();
            }
         }
      }
      
      public function add(Timer:FlxTimer) : void
      {
         this._timers.push(Timer);
      }
      
      public function remove(Timer:FlxTimer) : void
      {
         var index:int = this._timers.indexOf(Timer);
         if(index >= 0)
         {
            this._timers.splice(index,1);
         }
      }
      
      public function clear() : void
      {
         var timer:FlxTimer = null;
         var i:int = this._timers.length - 1;
         while(i >= 0)
         {
            timer = this._timers[i--] as FlxTimer;
            if(timer != null)
            {
               timer.destroy();
            }
         }
         this._timers.length = 0;
      }
   }
}

