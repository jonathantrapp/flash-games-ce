package org.flixel.system
{
   import org.flixel.FlxG;
   import org.flixel.system.replay.FrameRecord;
   import org.flixel.system.replay.MouseRecord;
   
   public class FlxReplay
   {
      
      public var seed:Number;
      
      public var frame:int;
      
      public var frameCount:int;
      
      public var finished:Boolean;
      
      protected var _frames:Array;
      
      protected var _capacity:int;
      
      protected var _marker:int;
      
      public function FlxReplay()
      {
         super();
         this.seed = 0;
         this.frame = 0;
         this.frameCount = 0;
         this.finished = false;
         this._frames = null;
         this._capacity = 0;
         this._marker = 0;
      }
      
      public function destroy() : void
      {
         if(this._frames == null)
         {
            return;
         }
         var i:int = this.frameCount - 1;
         while(i >= 0)
         {
            (this._frames[i--] as FrameRecord).destroy();
         }
         this._frames = null;
      }
      
      public function create(Seed:Number) : void
      {
         this.destroy();
         this.init();
         this.seed = Seed;
         this.rewind();
      }
      
      public function load(FileContents:String) : void
      {
         var line:String = null;
         this.init();
         var lines:Array = FileContents.split("\n");
         this.seed = Number(lines[0]);
         var i:uint = 1;
         var l:uint = lines.length;
         while(i < l)
         {
            line = lines[i++] as String;
            if(line.length > 3)
            {
               this._frames[this.frameCount++] = new FrameRecord().load(line);
               if(this.frameCount >= this._capacity)
               {
                  this._capacity *= 2;
                  this._frames.length = this._capacity;
               }
            }
         }
         this.rewind();
      }
      
      protected function init() : void
      {
         this._capacity = 100;
         this._frames = new Array(this._capacity);
         this.frameCount = 0;
      }
      
      public function save() : String
      {
         if(this.frameCount <= 0)
         {
            return null;
         }
         var output:String = this.seed + "\n";
         var i:uint = 0;
         while(i < this.frameCount)
         {
            output += this._frames[i++].save() + "\n";
         }
         return output;
      }
      
      public function recordFrame() : void
      {
         var keysRecord:Array = FlxG.keys.record();
         var mouseRecord:MouseRecord = FlxG.mouse.record();
         if(keysRecord == null && mouseRecord == null)
         {
            ++this.frame;
            return;
         }
         this._frames[this.frameCount++] = new FrameRecord().create(this.frame++,keysRecord,mouseRecord);
         if(this.frameCount >= this._capacity)
         {
            this._capacity *= 2;
            this._frames.length = this._capacity;
         }
      }
      
      public function playNextFrame() : void
      {
         FlxG.resetInput();
         if(this._marker >= this.frameCount)
         {
            this.finished = true;
            return;
         }
         if((this._frames[this._marker] as FrameRecord).frame != this.frame++)
         {
            return;
         }
         var fr:FrameRecord = this._frames[this._marker++];
         if(fr.keys != null)
         {
            FlxG.keys.playback(fr.keys);
         }
         if(fr.mouse != null)
         {
            FlxG.mouse.playback(fr.mouse);
         }
      }
      
      public function rewind() : void
      {
         this._marker = 0;
         this.frame = 0;
         this.finished = false;
      }
   }
}

