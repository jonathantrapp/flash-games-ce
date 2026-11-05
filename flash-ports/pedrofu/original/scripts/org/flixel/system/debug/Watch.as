package org.flixel.system.debug
{
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import org.flixel.system.FlxWindow;
   
   public class Watch extends FlxWindow
   {
      
      protected static const MAX_LOG_LINES:uint = 1024;
      
      protected static const LINE_HEIGHT:uint = 15;
      
      public var editing:Boolean;
      
      protected var _names:Sprite;
      
      protected var _values:Sprite;
      
      protected var _watching:Array;
      
      public function Watch(Title:String, Width:Number, Height:Number, Resizable:Boolean = true, Bounds:Rectangle = null, BGColor:uint = 2139062143, TopColor:uint = 2130706432)
      {
         super(Title,Width,Height,Resizable,Bounds,BGColor,TopColor);
         this._names = new Sprite();
         this._names.x = 2;
         this._names.y = 15;
         addChild(this._names);
         this._values = new Sprite();
         this._values.x = 2;
         this._values.y = 15;
         addChild(this._values);
         this._watching = new Array();
         this.editing = false;
         this.removeAll();
      }
      
      override public function destroy() : void
      {
         removeChild(this._names);
         this._names = null;
         removeChild(this._values);
         this._values = null;
         var i:int = 0;
         var l:uint = this._watching.length;
         while(i < l)
         {
            (this._watching[i++] as WatchEntry).destroy();
         }
         this._watching = null;
         super.destroy();
      }
      
      public function add(AnyObject:Object, VariableName:String, DisplayName:String = null) : void
      {
         var watchEntry:WatchEntry = null;
         var i:int = 0;
         var l:uint = this._watching.length;
         while(i < l)
         {
            watchEntry = this._watching[i++] as WatchEntry;
            if(watchEntry.object == AnyObject && watchEntry.field == VariableName)
            {
               return;
            }
         }
         watchEntry = new WatchEntry(this._watching.length * LINE_HEIGHT,_width / 2,_width / 2 - 10,AnyObject,VariableName,DisplayName);
         this._names.addChild(watchEntry.nameDisplay);
         this._values.addChild(watchEntry.valueDisplay);
         this._watching.push(watchEntry);
      }
      
      public function remove(AnyObject:Object, VariableName:String = null) : void
      {
         var watchEntry:WatchEntry = null;
         var i:int = this._watching.length - 1;
         while(i >= 0)
         {
            watchEntry = this._watching[i];
            if(watchEntry.object == AnyObject && (VariableName == null || watchEntry.field == VariableName))
            {
               this._watching.splice(i,1);
               this._names.removeChild(watchEntry.nameDisplay);
               this._values.removeChild(watchEntry.valueDisplay);
               watchEntry.destroy();
            }
            i--;
         }
         watchEntry = null;
         i = 0;
         var l:uint = this._watching.length;
         while(i < l)
         {
            (this._watching[i] as WatchEntry).setY(i * LINE_HEIGHT);
            i++;
         }
      }
      
      public function removeAll() : void
      {
         var watchEntry:WatchEntry = null;
         var i:int = 0;
         var l:uint = this._watching.length;
         while(i < l)
         {
            watchEntry = this._watching.pop();
            this._names.removeChild(watchEntry.nameDisplay);
            this._values.removeChild(watchEntry.valueDisplay);
            watchEntry.destroy();
            i++;
         }
         this._watching.length = 0;
      }
      
      public function update() : void
      {
         this.editing = false;
         var i:uint = 0;
         var l:uint = this._watching.length;
         while(i < l)
         {
            if(!(this._watching[i++] as WatchEntry).updateValue())
            {
               this.editing = true;
            }
         }
      }
      
      public function submit() : void
      {
         var watchEntry:WatchEntry = null;
         var i:uint = 0;
         var l:uint = this._watching.length;
         while(i < l)
         {
            watchEntry = this._watching[i++] as WatchEntry;
            if(watchEntry.editing)
            {
               watchEntry.submit();
            }
         }
         this.editing = false;
      }
      
      override protected function updateSize() : void
      {
         if(_height < this._watching.length * LINE_HEIGHT + 17)
         {
            _height = this._watching.length * LINE_HEIGHT + 17;
         }
         super.updateSize();
         this._values.x = _width / 2 + 2;
         var i:int = 0;
         var l:uint = this._watching.length;
         while(i < l)
         {
            (this._watching[i++] as WatchEntry).updateWidth(_width / 2,_width / 2 - 10);
         }
      }
   }
}

