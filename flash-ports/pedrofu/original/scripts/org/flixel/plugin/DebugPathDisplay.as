package org.flixel.plugin
{
   import org.flixel.*;
   
   public class DebugPathDisplay extends FlxBasic
   {
      
      protected var _paths:Array;
      
      public function DebugPathDisplay()
      {
         super();
         this._paths = new Array();
         active = false;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.clear();
         this._paths = null;
      }
      
      override public function draw() : void
      {
         if(!FlxG.visualDebug || ignoreDrawDebug)
         {
            return;
         }
         if(cameras == null)
         {
            cameras = FlxG.cameras;
         }
         var i:uint = 0;
         var l:uint = cameras.length;
         while(i < l)
         {
            this.drawDebug(cameras[i++]);
         }
      }
      
      override public function drawDebug(Camera:FlxCamera = null) : void
      {
         var path:FlxPath = null;
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         var i:int = this._paths.length - 1;
         while(i >= 0)
         {
            path = this._paths[i--] as FlxPath;
            if(path != null && !path.ignoreDrawDebug)
            {
               path.drawDebug(Camera);
            }
         }
      }
      
      public function add(Path:FlxPath) : void
      {
         this._paths.push(Path);
      }
      
      public function remove(Path:FlxPath) : void
      {
         var index:int = this._paths.indexOf(Path);
         if(index >= 0)
         {
            this._paths.splice(index,1);
         }
      }
      
      public function clear() : void
      {
         var path:FlxPath = null;
         var i:int = this._paths.length - 1;
         while(i >= 0)
         {
            path = this._paths[i--] as FlxPath;
            if(path != null)
            {
               path.destroy();
            }
         }
         this._paths.length = 0;
      }
   }
}

