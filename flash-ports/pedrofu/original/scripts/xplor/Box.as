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
      
      public function Box(grp:FlxGroup, x:int, y:int, wid:int, hei:int)
      {
         var s:FlxSprite = null;
         this.myGrp = grp;
         this.myPtr = grp.length;
         this.myRect = new FlxRect(x,y,wid,hei);
         super();
         s = new FlxSprite(x,y);
         s.loadGraphic(CornerImage,true,false,6,6,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         grp.add(s);
         s = new FlxSprite(x + wid - 6,y);
         s.loadGraphic(CornerImage,true,false,6,6,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         s.frame = 1;
         grp.add(s);
         s = new FlxSprite(x,y + hei - 6);
         s.loadGraphic(CornerImage,true,false,6,6,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         s.frame = 2;
         grp.add(s);
         s = new FlxSprite(x + wid - 6,y + hei - 6);
         s.loadGraphic(CornerImage,true,false,6,6,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         s.frame = 3;
         grp.add(s);
         s = new FlxSprite(x + 6,y);
         s.loadGraphic(TopImage,true,false,1,6,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         s.frame = 0;
         s.origin.x = 0;
         s.scale.x = wid - 12;
         grp.add(s);
         s = new FlxSprite(x + 6,y + hei - 6);
         s.loadGraphic(TopImage,true,false,1,6,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         s.frame = 1;
         s.origin.x = 0;
         s.scale.x = wid - 12;
         grp.add(s);
         s = new FlxSprite(x,y + 6);
         s.loadGraphic(SideImage,true,false,6,1,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         s.frame = 0;
         s.origin.y = 0;
         s.scale.y = hei - 12;
         grp.add(s);
         s = new FlxSprite(x + wid - 6,y + 6);
         s.loadGraphic(SideImage,true,false,6,1,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         s.frame = 1;
         s.origin.y = 0;
         s.scale.y = hei - 12;
         grp.add(s);
         s = new FlxSprite(x + 6,y + 6);
         s.makeGraphic(wid - 12,hei - 12,4294967295,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         s.color = 4287078782;
         grp.add(s);
      }
      
      public function Bright(b:Boolean) : void
      {
         if(this.faded)
         {
            return;
         }
         if(this.bright == b)
         {
            return;
         }
         this.bright = b;
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
      
      public function Fade(f:Boolean) : void
      {
         var i:int = 0;
         if(this.faded == f)
         {
            return;
         }
         this.faded = f;
         if(this.faded == true)
         {
            this.faded = false;
            this.bright = true;
            this.Bright(false);
            this.faded = true;
         }
         for(i = 0; i <= 8; i++)
         {
            (this.myGrp.members[this.myPtr + i] as FlxSprite).alpha = 0.5 + 0.5 * int(!this.faded);
         }
      }
      
      public function OnMe(x:int, y:int) : Boolean
      {
         return x >= this.myRect.x && y >= this.myRect.y && x < this.myRect.x + this.myRect.width && y < this.myRect.y + this.myRect.height;
      }
   }
}

