package org.flixel.system.replay
{
   public class FrameRecord
   {
      
      public var frame:int;
      
      public var keys:Array;
      
      public var mouse:MouseRecord;
      
      public function FrameRecord()
      {
         super();
         this.frame = 0;
         this.keys = null;
         this.mouse = null;
      }
      
      public function create(Frame:Number, Keys:Array = null, Mouse:MouseRecord = null) : FrameRecord
      {
         this.frame = Frame;
         this.keys = Keys;
         this.mouse = Mouse;
         return this;
      }
      
      public function destroy() : void
      {
         this.keys = null;
         this.mouse = null;
      }
      
      public function save() : String
      {
         var object:Object = null;
         var i:uint = 0;
         var l:uint = 0;
         var output:String = this.frame + "k";
         if(this.keys != null)
         {
            i = 0;
            l = this.keys.length;
            while(i < l)
            {
               if(i > 0)
               {
                  output += ",";
               }
               object = this.keys[i++];
               output += object.code + ":" + object.value;
            }
         }
         output += "m";
         if(this.mouse != null)
         {
            output += this.mouse.x + "," + this.mouse.y + "," + this.mouse.button + "," + this.mouse.wheel;
         }
         return output;
      }
      
      public function load(Data:String) : FrameRecord
      {
         var i:uint = 0;
         var l:uint = 0;
         var keyPair:Array = null;
         var array:Array = Data.split("k");
         this.frame = int(array[0] as String);
         array = (array[1] as String).split("m");
         var keyData:String = array[0];
         var mouseData:String = array[1];
         if(keyData.length > 0)
         {
            array = keyData.split(",");
            i = 0;
            l = array.length;
            while(i < l)
            {
               keyPair = (array[i++] as String).split(":");
               if(keyPair.length == 2)
               {
                  if(this.keys == null)
                  {
                     this.keys = new Array();
                  }
                  this.keys.push({
                     "code":int(keyPair[0] as String),
                     "value":int(keyPair[1] as String)
                  });
               }
            }
         }
         if(mouseData.length > 0)
         {
            array = mouseData.split(",");
            if(array.length >= 4)
            {
               this.mouse = new MouseRecord(int(array[0] as String),int(array[1] as String),int(array[2] as String),int(array[3] as String));
            }
         }
         return this;
      }
   }
}

