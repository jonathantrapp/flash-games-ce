package xplor.Menus
{
   import org.flixel.*;
   import xplor.*;
   
   public class ToolTip extends FlxSprite
   {
      
      public static const ITEM:int = 0;
      
      public static const HELP:int = 1;
      
      protected var BorderImage:Class = ToolTip_BorderImage;
      
      public var tipNum:int;
      
      public var words:Array;
      
      public var outline:Array;
      
      public function ToolTip()
      {
         var i:int = 0;
         var s:FlxSprite = null;
         var t:FlxText = null;
         super();
         this.tipNum = -1;
         scrollFactor.x = 0;
         scrollFactor.y = 0;
         this.words = new Array();
         this.outline = new Array();
         for(i = 0; i < 8; i++)
         {
            s = new FlxSprite(0,0);
            s.loadGraphic(this.BorderImage,true,false,2,2,true);
            s.frame = i;
            s.scrollFactor.x = 0;
            s.scrollFactor.y = 0;
            s.origin.x = 0;
            s.origin.y = 0;
            this.outline.push(s);
         }
         for(i = 0; i < 6; i++)
         {
            t = new FlxText(0,0,200,"");
            t.scrollFactor.x = 0;
            t.scrollFactor.y = 0;
            this.words.push(t);
         }
      }
      
      override public function draw() : void
      {
         var i:int = 0;
         var ypos:int = 0;
         var t:FlxText = null;
         if(this.tipNum == -1)
         {
            return;
         }
         x = FlxG.mouse.screenX + 10;
         y = FlxG.mouse.screenY + 10;
         if(x + width > 320)
         {
            x = FlxG.mouse.screenX - 3 - width;
         }
         if(y + height > 240)
         {
            y = FlxG.mouse.screenY - 3 - height;
         }
         if(x < 0)
         {
            x = 0;
         }
         if(y < 0)
         {
            y = 0;
         }
         super.draw();
         this.outline[0].x = x - 2;
         this.outline[0].y = y - 2;
         this.outline[1].x = x + width;
         this.outline[1].y = y - 2;
         this.outline[2].x = x + width;
         this.outline[2].y = y + height;
         this.outline[3].x = x - 2;
         this.outline[3].y = y + height;
         this.outline[4].x = x;
         this.outline[4].y = y + height;
         this.outline[5].x = x;
         this.outline[5].y = y - 2;
         this.outline[6].x = x - 2;
         this.outline[6].y = y;
         this.outline[7].x = x + width;
         this.outline[7].y = y;
         for(i = 0; i < 8; i++)
         {
            this.outline[i].draw();
         }
         ypos = y;
         for(i = 0; i < 6; i++)
         {
            t = this.words[i];
            t.x = x;
            t.y = ypos;
            t.draw();
            ypos += t._textField.textHeight + 1;
            if(i == 0)
            {
               ypos++;
            }
         }
      }
      
      public function Clear() : void
      {
         this.tipNum = -1;
      }
      
      public function HashString(s:String) : int
      {
         var i:int = 0;
         var total:int = 0;
         total = s.length;
         for(i = 0; i < s.length; i++)
         {
            total += s.charCodeAt(i) + i * 100;
         }
         return total;
      }
      
      public function Set(type:int, headColor:int = 16777215, heading:String = "", line1:String = "", line2:String = "", line3:String = "", line4:String = "", line5:String = "") : void
      {
         var t:int = 0;
         t = type * 5461 + headColor + this.HashString(heading) * 7 + this.HashString(line1) * 5 + this.HashString(line2) * 137 + this.HashString(line3) * 917 + this.HashString(line4) * 123 + this.HashString(line5) * 37;
         if(t == this.tipNum)
         {
            return;
         }
         this.tipNum = t;
         switch(type)
         {
            case ITEM:
               (this.words[0] as FlxText).text = heading;
               (this.words[0] as FlxText).setFormat("",8,headColor,"left",1);
               (this.words[1] as FlxText).text = line1;
               (this.words[1] as FlxText).setFormat("",8,16777215,"left",1);
               (this.words[2] as FlxText).text = line2;
               (this.words[2] as FlxText).setFormat("",8,16777215,"left",1);
               (this.words[3] as FlxText).text = line3;
               (this.words[3] as FlxText).setFormat("",8,16777215,"left",1);
               (this.words[4] as FlxText).text = line4;
               (this.words[4] as FlxText).setFormat("",8,16777215,"left",1);
               (this.words[5] as FlxText).text = line5;
               (this.words[5] as FlxText).setFormat("",8,16777215,"left",1);
               width = 1;
               height = 4;
               for(t = 0; t <= 5; t++)
               {
                  if((this.words[t] as FlxText)._textField.textWidth > width)
                  {
                     width = (this.words[t] as FlxText)._textField.textWidth;
                  }
                  height += (this.words[t] as FlxText)._textField.textHeight + 1;
               }
               width += 4;
         }
         makeGraphic(width,height,4280705202);
         (this.outline[4] as FlxSprite).scale.x = width / 2;
         (this.outline[5] as FlxSprite).scale.x = width / 2;
         (this.outline[6] as FlxSprite).scale.y = height / 2;
         (this.outline[7] as FlxSprite).scale.y = height / 2;
      }
      
      public function SetAdvanced(type:int, headColor:int, heading:String, line1:String, line2:String, line3:String, line4:String, line5:String, line1Color:int, line2Color:int, line3Color:int, line4Color:int, line5Color:int, line1Size:int, line2Size:int, line3Size:int, line4Size:int, line5Size:int) : void
      {
         var t:int = 0;
         t = type * 5461 + headColor + this.HashString(heading) * 7 + this.HashString(line1) * 5 + this.HashString(line2) * 137 + this.HashString(line3) * 917 + this.HashString(line4) * 123 + this.HashString(line5) * 37;
         if(t == this.tipNum)
         {
            return;
         }
         this.tipNum = t;
         switch(type)
         {
            case ITEM:
               (this.words[0] as FlxText).text = heading;
               (this.words[0] as FlxText).setFormat("",8,headColor,"left",1);
               (this.words[1] as FlxText).text = line1;
               (this.words[1] as FlxText).setFormat("",line1Size,line1Color,"left",1);
               (this.words[2] as FlxText).text = line2;
               (this.words[2] as FlxText).setFormat("",line2Size,line2Color,"left",1);
               (this.words[3] as FlxText).text = line3;
               (this.words[3] as FlxText).setFormat("",line3Size,line3Color,"left",1);
               (this.words[4] as FlxText).text = line4;
               (this.words[4] as FlxText).setFormat("",line4Size,line4Color,"left",1);
               (this.words[5] as FlxText).text = line5;
               (this.words[5] as FlxText).setFormat("",line5Size,line5Color,"left",1);
               width = 1;
               height = 4;
               for(t = 0; t <= 5; t++)
               {
                  if((this.words[t] as FlxText)._textField.textWidth > width)
                  {
                     width = (this.words[t] as FlxText)._textField.textWidth;
                  }
                  height += (this.words[t] as FlxText)._textField.textHeight + 1;
               }
               width += 4;
         }
         makeGraphic(width,height,4280705202);
         (this.outline[4] as FlxSprite).scale.x = width / 2;
         (this.outline[5] as FlxSprite).scale.x = width / 2;
         (this.outline[6] as FlxSprite).scale.y = height / 2;
         (this.outline[7] as FlxSprite).scale.y = height / 2;
      }
   }
}

