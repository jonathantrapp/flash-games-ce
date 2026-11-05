package org.flixel.system
{
   public class FlxAnim
   {
      
      public var name:String;
      
      public var delay:Number;
      
      public var frames:Array;
      
      public var looped:Boolean;
      
      public function FlxAnim(Name:String, Frames:Array, FrameRate:Number = 0, Looped:Boolean = true)
      {
         super();
         this.name = Name;
         this.delay = 0;
         if(FrameRate > 0)
         {
            this.delay = 1 / FrameRate;
         }
         this.frames = Frames;
         this.looped = Looped;
      }
      
      public function destroy() : void
      {
         this.frames = null;
      }
   }
}

