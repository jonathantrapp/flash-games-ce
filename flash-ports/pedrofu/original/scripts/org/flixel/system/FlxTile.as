package org.flixel.system
{
   import org.flixel.FlxObject;
   import org.flixel.FlxTilemap;
   
   public class FlxTile extends FlxObject
   {
      
      public var callback:Function;
      
      public var filter:Class;
      
      public var tilemap:FlxTilemap;
      
      public var index:uint;
      
      public var mapIndex:uint;
      
      public function FlxTile(Tilemap:FlxTilemap, Index:uint, Width:Number, Height:Number, Visible:Boolean, AllowCollisions:uint)
      {
         super(0,0,Width,Height);
         immovable = true;
         moves = false;
         this.callback = null;
         this.filter = null;
         this.tilemap = Tilemap;
         this.index = Index;
         visible = Visible;
         allowCollisions = AllowCollisions;
         this.mapIndex = 0;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.callback = null;
         this.tilemap = null;
      }
   }
}

