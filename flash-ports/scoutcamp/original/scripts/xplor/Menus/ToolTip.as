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
         var _loc1_:int = 0;
         var _loc2_:FlxSprite = null;
         var _loc3_:FlxText = null;
         super();
         this.tipNum = -1;
         scrollFactor.x = 0;
         scrollFactor.y = 0;
         this.words = new Array();
         this.outline = new Array();
         _loc1_ = 0;
         while(_loc1_ < 8)
         {
            _loc2_ = new FlxSprite(0,0);
            _loc2_.loadGraphic(this.BorderImage,true,false,2,2,true);
            _loc2_.frame = _loc1_;
            _loc2_.scrollFactor.x = 0;
            _loc2_.scrollFactor.y = 0;
            _loc2_.origin.x = 0;
            _loc2_.origin.y = 0;
            this.outline.push(_loc2_);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < 6)
         {
            _loc3_ = new FlxText(0,0,200,"");
            _loc3_.scrollFactor.x = 0;
            _loc3_.scrollFactor.y = 0;
            this.words.push(_loc3_);
            _loc1_++;
         }
      }
      
      override public function draw() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:FlxText = null;
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
         _loc1_ = 0;
         while(_loc1_ < 8)
         {
            this.outline[_loc1_].draw();
            _loc1_++;
         }
         _loc2_ = y;
         _loc1_ = 0;
         while(_loc1_ < 6)
         {
            _loc3_ = this.words[_loc1_];
            _loc3_.x = x;
            _loc3_.y = _loc2_;
            _loc3_.draw();
            _loc2_ += _loc3_._textField.textHeight + 1;
            if(_loc1_ == 0)
            {
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function Clear() : void
      {
         this.tipNum = -1;
      }
      
      public function HashString(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc3_ = param1.length;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ += param1.charCodeAt(_loc2_) + _loc2_ * 100;
            _loc2_++;
         }
         return _loc3_;
      }
      
      public function Set(param1:int, param2:int = 16777215, param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:String = "", param8:String = "") : void
      {
         var _loc9_:int = 0;
         _loc9_ = param1 * 5461 + param2 + this.HashString(param3) * 7 + this.HashString(param4) * 5 + this.HashString(param5) * 137 + this.HashString(param6) * 917 + this.HashString(param7) * 123 + this.HashString(param8) * 37;
         if(_loc9_ == this.tipNum)
         {
            return;
         }
         this.tipNum = _loc9_;
         switch(param1)
         {
            case ITEM:
               (this.words[0] as FlxText).text = param3;
               (this.words[0] as FlxText).setFormat("",8,param2,"left",1);
               (this.words[1] as FlxText).text = param4;
               (this.words[1] as FlxText).setFormat("",8,16777215,"left",1);
               (this.words[2] as FlxText).text = param5;
               (this.words[2] as FlxText).setFormat("",8,16777215,"left",1);
               (this.words[3] as FlxText).text = param6;
               (this.words[3] as FlxText).setFormat("",8,16777215,"left",1);
               (this.words[4] as FlxText).text = param7;
               (this.words[4] as FlxText).setFormat("",8,16777215,"left",1);
               (this.words[5] as FlxText).text = param8;
               (this.words[5] as FlxText).setFormat("",8,16777215,"left",1);
               width = 1;
               height = 4;
               _loc9_ = 0;
               while(_loc9_ <= 5)
               {
                  if((this.words[_loc9_] as FlxText)._textField.textWidth > width)
                  {
                     width = (this.words[_loc9_] as FlxText)._textField.textWidth;
                  }
                  height += (this.words[_loc9_] as FlxText)._textField.textHeight + 1;
                  _loc9_++;
               }
               width += 4;
         }
         makeGraphic(width,height,4280705202);
         (this.outline[4] as FlxSprite).scale.x = width / 2;
         (this.outline[5] as FlxSprite).scale.x = width / 2;
         (this.outline[6] as FlxSprite).scale.y = height / 2;
         (this.outline[7] as FlxSprite).scale.y = height / 2;
      }
      
      public function SetAdvanced(param1:int, param2:int, param3:String, param4:String, param5:String, param6:String, param7:String, param8:String, param9:int, param10:int, param11:int, param12:int, param13:int, param14:int, param15:int, param16:int, param17:int, param18:int) : void
      {
         var _loc19_:int = 0;
         _loc19_ = param1 * 5461 + param2 + this.HashString(param3) * 7 + this.HashString(param4) * 5 + this.HashString(param5) * 137 + this.HashString(param6) * 917 + this.HashString(param7) * 123 + this.HashString(param8) * 37;
         if(_loc19_ == this.tipNum)
         {
            return;
         }
         this.tipNum = _loc19_;
         switch(param1)
         {
            case ITEM:
               (this.words[0] as FlxText).text = param3;
               (this.words[0] as FlxText).setFormat("",8,param2,"left",1);
               (this.words[1] as FlxText).text = param4;
               (this.words[1] as FlxText).setFormat("",param14,param9,"left",1);
               (this.words[2] as FlxText).text = param5;
               (this.words[2] as FlxText).setFormat("",param15,param10,"left",1);
               (this.words[3] as FlxText).text = param6;
               (this.words[3] as FlxText).setFormat("",param16,param11,"left",1);
               (this.words[4] as FlxText).text = param7;
               (this.words[4] as FlxText).setFormat("",param17,param12,"left",1);
               (this.words[5] as FlxText).text = param8;
               (this.words[5] as FlxText).setFormat("",param18,param13,"left",1);
               width = 1;
               height = 4;
               _loc19_ = 0;
               while(_loc19_ <= 5)
               {
                  if((this.words[_loc19_] as FlxText)._textField.textWidth > width)
                  {
                     width = (this.words[_loc19_] as FlxText)._textField.textWidth;
                  }
                  height += (this.words[_loc19_] as FlxText)._textField.textHeight + 1;
                  _loc19_++;
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

