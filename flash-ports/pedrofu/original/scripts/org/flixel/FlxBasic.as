package org.flixel
{
   public class FlxBasic
   {
      
      internal static var _ACTIVECOUNT:uint;
      
      internal static var _VISIBLECOUNT:uint;
      
      public var ID:int;
      
      public var exists:Boolean;
      
      public var active:Boolean;
      
      public var visible:Boolean;
      
      public var alive:Boolean;
      
      public var cameras:Array;
      
      public var ignoreDrawDebug:Boolean;
      
      public function FlxBasic()
      {
         super();
         this.ID = -1;
         this.exists = true;
         this.active = true;
         this.visible = true;
         this.alive = true;
         this.ignoreDrawDebug = false;
      }
      
      public function destroy() : void
      {
      }
      
      public function preUpdate() : void
      {
         ++_ACTIVECOUNT;
      }
      
      public function update() : void
      {
      }
      
      public function postUpdate() : void
      {
      }
      
      public function draw() : void
      {
         var camera:FlxCamera = null;
         if(this.cameras == null)
         {
            this.cameras = FlxG.cameras;
         }
         var i:uint = 0;
         var l:uint = this.cameras.length;
         while(i < l)
         {
            camera = this.cameras[i++];
            ++_VISIBLECOUNT;
            if(FlxG.visualDebug && !this.ignoreDrawDebug)
            {
               this.drawDebug(camera);
            }
         }
      }
      
      public function drawDebug(Camera:FlxCamera = null) : void
      {
      }
      
      public function kill() : void
      {
         this.alive = false;
         this.exists = false;
      }
      
      public function revive() : void
      {
         this.alive = true;
         this.exists = true;
      }
      
      public function toString() : String
      {
         return FlxU.getClassName(this,true);
      }
   }
}

