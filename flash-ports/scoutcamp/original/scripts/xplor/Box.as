package xplor
{
   import org.flixel.*;
   
   public class Box
   {
      
      public static var CornerImage:Class = Box_CornerImage;
      
      public static var SideImage:Class = Box_SideImage;
      
      public static var TopImage:Class = Box_TopImage;
      
      public var bright:Boolean = false;
      
      public var myGrp:FlxGroup;
      
      public var myPtr:uint;
      
      public var myRect:FlxRect;
      
      public var faded:Boolean = false;
      
      public function Box(param1:FlxGroup, param2:int, param3:int, param4:int, param5:int)
      {
         var _loc6_:FlxSprite = null;
         this.myGrp = param1;
         this.myPtr = param1.length;
         this.myRect = new FlxRect(param2,param3,param4,param5);
         super();
         _loc6_ = new FlxSprite(param2,param3);
         _loc6_.loadGraphic(CornerImage,true,false,6,6,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         param1.add(_loc6_);
         _loc6_ = new FlxSprite(param2 + param4 - 6,param3);
         _loc6_.loadGraphic(CornerImage,true,false,6,6,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         _loc6_.frame = 1;
         param1.add(_loc6_);
         _loc6_ = new FlxSprite(param2,param3 + param5 - 6);
         _loc6_.loadGraphic(CornerImage,true,false,6,6,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         _loc6_.frame = 2;
         param1.add(_loc6_);
         _loc6_ = new FlxSprite(param2 + param4 - 6,param3 + param5 - 6);
         _loc6_.loadGraphic(CornerImage,true,false,6,6,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         _loc6_.frame = 3;
         param1.add(_loc6_);
         _loc6_ = new FlxSprite(param2 + 6,param3);
         _loc6_.loadGraphic(TopImage,true,false,1,6,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         _loc6_.frame = 0;
         _loc6_.origin.x = 0;
         _loc6_.scale.x = param4 - 12;
         param1.add(_loc6_);
         _loc6_ = new FlxSprite(param2 + 6,param3 + param5 - 6);
         _loc6_.loadGraphic(TopImage,true,false,1,6,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         _loc6_.frame = 1;
         _loc6_.origin.x = 0;
         _loc6_.scale.x = param4 - 12;
         param1.add(_loc6_);
         _loc6_ = new FlxSprite(param2,param3 + 6);
         _loc6_.loadGraphic(SideImage,true,false,6,1,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         _loc6_.frame = 0;
         _loc6_.origin.y = 0;
         _loc6_.scale.y = param5 - 12;
         param1.add(_loc6_);
         _loc6_ = new FlxSprite(param2 + param4 - 6,param3 + 6);
         _loc6_.loadGraphic(SideImage,true,false,6,1,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         _loc6_.frame = 1;
         _loc6_.origin.y = 0;
         _loc6_.scale.y = param5 - 12;
         param1.add(_loc6_);
         _loc6_ = new FlxSprite(param2 + 6,param3 + 6);
         _loc6_.makeGraphic(param4 - 12,param5 - 12,4294967295,true);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         _loc6_.color = 4287078782;
         param1.add(_loc6_);
      }
      
      public function Bright(param1:Boolean) : void
      {
         if(this.faded)
         {
            return;
         }
         if(this.bright == param1)
         {
            return;
         }
         this.bright = param1;
         (this.myGrp.members[this.myPtr + 0] as FlxSprite).frame = 0 + int(this.bright) * 4;
         (this.myGrp.members[this.myPtr + 1] as FlxSprite).frame = 1 + int(this.bright) * 4;
         (this.myGrp.members[this.myPtr + 2] as FlxSprite).frame = 2 + int(this.bright) * 4;
         (this.myGrp.members[this.myPtr + 3] as FlxSprite).frame = 3 + int(this.bright) * 4;
         (this.myGrp.members[this.myPtr + 4] as FlxSprite).frame = 0 + int(this.bright) * 2;
         (this.myGrp.members[this.myPtr + 5] as FlxSprite).frame = 1 + int(this.bright) * 2;
         (this.myGrp.members[this.myPtr + 6] as FlxSprite).frame = 0 + int(this.bright) * 2;
         (this.myGrp.members[this.myPtr + 7] as FlxSprite).frame = 1 + int(this.bright) * 2;
         if(this.bright)
         {
            (this.myGrp.members[this.myPtr + 8] as FlxSprite).color = 4294952196;
         }
         else
         {
            (this.myGrp.members[this.myPtr + 8] as FlxSprite).color = 4287078782;
         }
      }
      
      public function Fade(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(this.faded == param1)
         {
            return;
         }
         this.faded = param1;
         if(this.faded == true)
         {
            this.faded = false;
            this.bright = true;
            this.Bright(false);
            this.faded = true;
         }
         _loc2_ = 0;
         while(_loc2_ <= 8)
         {
            (this.myGrp.members[this.myPtr + _loc2_] as FlxSprite).alpha = 0.5 + 0.5 * int(!this.faded);
            _loc2_++;
         }
      }
      
      public function OnMe(param1:int, param2:int) : Boolean
      {
         return param1 >= this.myRect.x && param2 >= this.myRect.y && param1 < this.myRect.x + this.myRect.width && param2 < this.myRect.y + this.myRect.height;
      }
   }
}

