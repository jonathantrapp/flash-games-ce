package xplor
{
   import flash.utils.ByteArray;
   import org.flixel.*;
   import xplor.Monster.*;
   
   public class MapStore
   {
      
      public var layers:Array = null;
      
      public var width:int = 0;
      
      public var height:int = 0;
      
      public function MapStore()
      {
         super();
      }
      
      public function GetLayer(param1:int) : Array
      {
         if(this.layers == null || param1 < 0 || param1 >= this.layers.length)
         {
            return null;
         }
         return this.layers[param1];
      }
      
      public function LoadFromArray(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         param1.uncompress();
         param1.position = 0;
         this.width = param1.readShort();
         this.height = param1.readShort();
         this.layers = new Array();
         _loc2_ = 0;
         while(_loc2_ < Level.LAYERS)
         {
            this.layers[_loc2_] = new Array();
            _loc3_ = 0;
            while(_loc3_ < this.width * this.height)
            {
               (this.layers[_loc2_] as Array).push(param1.readByte());
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function SaveToArray() : ByteArray
      {
         var _loc1_:int = 0;
         var _loc2_:ByteArray = null;
         var _loc3_:int = 0;
         _loc2_ = new ByteArray();
         _loc2_.writeShort(this.width);
         _loc2_.writeShort(this.height);
         _loc1_ = 0;
         while(_loc1_ < Level.LAYERS)
         {
            _loc3_ = 0;
            while(_loc3_ < this.width * this.height)
            {
               _loc2_.writeByte(this.layers[_loc1_][_loc3_]);
               _loc3_++;
            }
            _loc1_++;
         }
         _loc2_.compress();
         return _loc2_;
      }
      
      public function GetFromMap() : void
      {
         this.height = Global.level.height;
         this.width = Global.level.width;
         this.layers = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < Level.LAYERS)
         {
            this.layers.push(Global.level.GetLayer(_loc1_).getData());
            _loc1_++;
         }
      }
      
      public function AddGoodies(param1:Badguys) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Food = null;
         Global.level.jumps = new Array();
         _loc2_ = 0;
         while(_loc2_ < Global.level.width * Global.level.height)
         {
            Global.level.jumps[_loc2_] = 0;
            switch(this.layers[3][_loc2_])
            {
               case 1:
                  Global.portals.Add(_loc2_ % Global.level.width,_loc2_ / Global.level.width);
                  Global.level.GetLayer(Level.LAYER_DECOR).setTile(_loc2_ % Global.level.width,_loc2_ / Global.level.width,27);
                  break;
               case 2:
                  Global.campfire.tx = int(_loc2_ % Global.level.width);
                  Global.campfire.ty = int(_loc2_ / Global.level.width);
                  Global.campfire.x = int(_loc2_ % Global.level.width) * 16;
                  Global.campfire.y = int(_loc2_ / Global.level.width) * 16;
                  Global.tent.x = Global.campfire.x - 16;
                  Global.tent2.x = Global.campfire.x + 16;
                  Global.tent.y = Global.campfire.y + 8;
                  Global.tent2.y = Global.campfire.y + 8;
                  _loc3_ = 0;
                  while(_loc3_ < 5)
                  {
                     _loc4_ = Global.badguys.AddGuy(Food,Badguys.FOOD,0,0) as Food;
                     _loc4_.x = Global.campfire.x - 16 + _loc3_ * 8;
                     _loc4_.y = Global.campfire.y + 10;
                     _loc4_.frame = _loc3_;
                     _loc3_++;
                  }
                  break;
               case 3:
               case 4:
               case 5:
               case 6:
               case 7:
               case 8:
               case 9:
               case 10:
               case 11:
                  Global.level.jumps[_loc2_] = this.layers[3][_loc2_];
            }
            _loc2_++;
         }
      }
   }
}

