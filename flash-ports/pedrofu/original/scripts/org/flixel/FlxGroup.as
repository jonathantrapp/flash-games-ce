package org.flixel
{
   public class FlxGroup extends FlxBasic
   {
      
      public static const ASCENDING:int = -1;
      
      public static const DESCENDING:int = 1;
      
      public var members:Array;
      
      public var length:Number;
      
      protected var _maxSize:uint;
      
      protected var _marker:uint;
      
      protected var _sortIndex:String;
      
      protected var _sortOrder:int;
      
      public function FlxGroup(MaxSize:uint = 0)
      {
         super();
         this.members = new Array();
         this.length = 0;
         this._maxSize = MaxSize;
         this._marker = 0;
         this._sortIndex = null;
      }
      
      override public function destroy() : void
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         if(this.members != null)
         {
            i = 0;
            while(i < this.length)
            {
               basic = this.members[i++] as FlxBasic;
               if(basic != null)
               {
                  basic.destroy();
               }
            }
            this.members.length = 0;
            this.members = null;
         }
         this._sortIndex = null;
      }
      
      override public function preUpdate() : void
      {
      }
      
      override public function update() : void
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null && basic.exists && basic.active)
            {
               basic.preUpdate();
               basic.update();
               basic.postUpdate();
            }
         }
      }
      
      override public function draw() : void
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null && basic.exists && basic.visible)
            {
               basic.draw();
            }
         }
      }
      
      public function get maxSize() : uint
      {
         return this._maxSize;
      }
      
      public function set maxSize(Size:uint) : void
      {
         var basic:FlxBasic = null;
         this._maxSize = Size;
         if(this._marker >= this._maxSize)
         {
            this._marker = 0;
         }
         if(this._maxSize == 0 || this.members == null || this._maxSize >= this.members.length)
         {
            return;
         }
         var i:uint = this._maxSize;
         var l:uint = this.members.length;
         while(i < l)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null)
            {
               basic.destroy();
            }
         }
         this.length = this.members.length = this._maxSize;
      }
      
      public function add(Object:FlxBasic) : FlxBasic
      {
         if(this.members.indexOf(Object) >= 0)
         {
            return Object;
         }
         var i:uint = 0;
         var l:uint = this.members.length;
         while(i < l)
         {
            if(this.members[i] == null)
            {
               this.members[i] = Object;
               if(i >= this.length)
               {
                  this.length = i + 1;
               }
               return Object;
            }
            i++;
         }
         if(this._maxSize > 0)
         {
            if(this.members.length >= this._maxSize)
            {
               return Object;
            }
            if(this.members.length * 2 <= this._maxSize)
            {
               this.members.length *= 2;
            }
            else
            {
               this.members.length = this._maxSize;
            }
         }
         else
         {
            this.members.length *= 2;
         }
         this.members[i] = Object;
         this.length = i + 1;
         return Object;
      }
      
      public function recycle(ObjectClass:Class = null) : FlxBasic
      {
         var basic:FlxBasic = null;
         if(this._maxSize > 0)
         {
            if(this.length < this._maxSize)
            {
               if(ObjectClass == null)
               {
                  return null;
               }
               return this.add(new ObjectClass() as FlxBasic);
            }
            basic = this.members[this._marker++];
            if(this._marker >= this._maxSize)
            {
               this._marker = 0;
            }
            return basic;
         }
         basic = this.getFirstAvailable(ObjectClass);
         if(basic != null)
         {
            return basic;
         }
         if(ObjectClass == null)
         {
            return null;
         }
         return this.add(new ObjectClass() as FlxBasic);
      }
      
      public function remove(Object:FlxBasic, Splice:Boolean = false) : FlxBasic
      {
         var index:int = this.members.indexOf(Object);
         if(index < 0 || index >= this.members.length)
         {
            return null;
         }
         if(Splice)
         {
            this.members.splice(index,1);
            --this.length;
         }
         else
         {
            this.members[index] = null;
         }
         return Object;
      }
      
      public function replace(OldObject:FlxBasic, NewObject:FlxBasic) : FlxBasic
      {
         var index:int = this.members.indexOf(OldObject);
         if(index < 0 || index >= this.members.length)
         {
            return null;
         }
         this.members[index] = NewObject;
         return NewObject;
      }
      
      public function sort(Index:String = "y", Order:int = -1) : void
      {
         this._sortIndex = Index;
         this._sortOrder = Order;
         this.members.sort(this.sortHandler);
      }
      
      public function setAll(VariableName:String, Value:Object, Recurse:Boolean = true) : void
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null)
            {
               if(Recurse && basic is FlxGroup)
               {
                  (basic as FlxGroup).setAll(VariableName,Value,Recurse);
               }
               else
               {
                  basic[VariableName] = Value;
               }
            }
         }
      }
      
      public function callAll(FunctionName:String, Recurse:Boolean = true) : void
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null)
            {
               if(Recurse && basic is FlxGroup)
               {
                  (basic as FlxGroup).callAll(FunctionName,Recurse);
               }
               else
               {
                  basic[FunctionName]();
               }
            }
         }
      }
      
      public function getFirstAvailable(ObjectClass:Class = null) : FlxBasic
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null && !basic.exists && (ObjectClass == null || basic is ObjectClass))
            {
               return basic;
            }
         }
         return null;
      }
      
      public function getFirstNull() : int
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         var l:uint = this.members.length;
         while(i < l)
         {
            if(this.members[i] == null)
            {
               return i;
            }
            i++;
         }
         return -1;
      }
      
      public function getFirstExtant() : FlxBasic
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null && basic.exists)
            {
               return basic;
            }
         }
         return null;
      }
      
      public function getFirstAlive() : FlxBasic
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null && basic.exists && basic.alive)
            {
               return basic;
            }
         }
         return null;
      }
      
      public function getFirstDead() : FlxBasic
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null && !basic.alive)
            {
               return basic;
            }
         }
         return null;
      }
      
      public function countLiving() : int
      {
         var basic:FlxBasic = null;
         var count:int = -1;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null)
            {
               if(count < 0)
               {
                  count = 0;
               }
               if(basic.exists && basic.alive)
               {
                  count++;
               }
            }
         }
         return count;
      }
      
      public function countDead() : int
      {
         var basic:FlxBasic = null;
         var count:int = -1;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null)
            {
               if(count < 0)
               {
                  count = 0;
               }
               if(!basic.alive)
               {
                  count++;
               }
            }
         }
         return count;
      }
      
      public function getRandom(StartIndex:uint = 0, Length:uint = 0) : FlxBasic
      {
         if(Length == 0)
         {
            Length = this.length;
         }
         return FlxG.getRandom(this.members,StartIndex,Length) as FlxBasic;
      }
      
      public function clear() : void
      {
         this.length = this.members.length = 0;
      }
      
      override public function kill() : void
      {
         var basic:FlxBasic = null;
         var i:uint = 0;
         while(i < this.length)
         {
            basic = this.members[i++] as FlxBasic;
            if(basic != null && basic.exists)
            {
               basic.kill();
            }
         }
         super.kill();
      }
      
      protected function sortHandler(Obj1:FlxBasic, Obj2:FlxBasic) : int
      {
         if(Obj1[this._sortIndex] < Obj2[this._sortIndex])
         {
            return this._sortOrder;
         }
         if(Obj1[this._sortIndex] > Obj2[this._sortIndex])
         {
            return -this._sortOrder;
         }
         return 0;
      }
   }
}

