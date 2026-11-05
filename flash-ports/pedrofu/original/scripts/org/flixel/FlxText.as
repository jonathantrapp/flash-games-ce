package org.flixel
{
   import flash.display.BitmapData;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class FlxText extends FlxSprite
   {
      
      public var _textField:TextField;
      
      protected var _regen:Boolean;
      
      protected var _shadow:uint;
      
      public function FlxText(X:Number, Y:Number, Width:uint, Text:String = null, EmbeddedFont:Boolean = true)
      {
         super(X,Y);
         makeGraphic(Width,1,0);
         if(Text == null)
         {
            Text = "";
         }
         this._textField = new TextField();
         this._textField.width = Width;
         this._textField.embedFonts = EmbeddedFont;
         this._textField.selectable = false;
         this._textField.sharpness = 100;
         this._textField.multiline = true;
         this._textField.wordWrap = true;
         this._textField.text = Text;
         var format:TextFormat = new TextFormat("system",8,16777215);
         this._textField.defaultTextFormat = format;
         this._textField.setTextFormat(format);
         if(Text.length <= 0)
         {
            this._textField.height = 1;
         }
         else
         {
            this._textField.height = 10;
         }
         this._regen = true;
         this._shadow = 0;
         allowCollisions = NONE;
         this.calcFrame();
      }
      
      override public function destroy() : void
      {
         this._textField = null;
         super.destroy();
      }
      
      public function setFormat(Font:String = null, Size:Number = 8, Color:uint = 16777215, Alignment:String = null, ShadowColor:uint = 0) : FlxText
      {
         if(Font == null)
         {
            Font = "";
         }
         var format:TextFormat = this.dtfCopy();
         format.font = Font;
         format.size = Size;
         format.color = Color;
         format.align = Alignment;
         this._textField.defaultTextFormat = format;
         this._textField.setTextFormat(format);
         this._shadow = ShadowColor;
         this._regen = true;
         this.calcFrame();
         return this;
      }
      
      public function get text() : String
      {
         return this._textField.text;
      }
      
      public function set text(Text:String) : void
      {
         var ot:String = this._textField.text;
         this._textField.text = Text;
         if(this._textField.text != ot)
         {
            this._regen = true;
            this.calcFrame();
         }
      }
      
      public function get size() : Number
      {
         return this._textField.defaultTextFormat.size as Number;
      }
      
      public function set size(Size:Number) : void
      {
         var format:TextFormat = this.dtfCopy();
         format.size = Size;
         this._textField.defaultTextFormat = format;
         this._textField.setTextFormat(format);
         this._regen = true;
         this.calcFrame();
      }
      
      override public function get color() : uint
      {
         return this._textField.defaultTextFormat.color as uint;
      }
      
      override public function set color(Color:uint) : void
      {
         var format:TextFormat = this.dtfCopy();
         format.color = Color;
         this._textField.defaultTextFormat = format;
         this._textField.setTextFormat(format);
         this._regen = true;
         this.calcFrame();
      }
      
      public function get font() : String
      {
         return this._textField.defaultTextFormat.font;
      }
      
      public function set font(Font:String) : void
      {
         var format:TextFormat = this.dtfCopy();
         format.font = Font;
         this._textField.defaultTextFormat = format;
         this._textField.setTextFormat(format);
         this._regen = true;
         this.calcFrame();
      }
      
      public function get alignment() : String
      {
         return this._textField.defaultTextFormat.align;
      }
      
      public function set alignment(Alignment:String) : void
      {
         var format:TextFormat = this.dtfCopy();
         format.align = Alignment;
         this._textField.defaultTextFormat = format;
         this._textField.setTextFormat(format);
         this.calcFrame();
      }
      
      public function get shadow() : uint
      {
         return this._shadow;
      }
      
      public function set shadow(Color:uint) : void
      {
         this._shadow = Color;
         this.calcFrame();
      }
      
      override protected function calcFrame() : void
      {
         var i:uint = 0;
         var nl:uint = 0;
         var format:TextFormat = null;
         var formatAdjusted:TextFormat = null;
         if(this._regen)
         {
            i = 0;
            nl = uint(this._textField.numLines);
            height = 0;
            while(i < nl)
            {
               height += this._textField.getLineMetrics(i++).height;
            }
            height += 4;
            _pixels = new BitmapData(width,height,true,0);
            frameHeight = height;
            this._textField.height = height * 1.2;
            _flashRect.x = 0;
            _flashRect.y = 0;
            _flashRect.width = width;
            _flashRect.height = height;
            this._regen = false;
         }
         else
         {
            _pixels.fillRect(_flashRect,0);
         }
         if(this._textField != null && this._textField.text != null && this._textField.text.length > 0)
         {
            format = this._textField.defaultTextFormat;
            formatAdjusted = format;
            _matrix.identity();
            if(format.align == "center" && this._textField.numLines == 1)
            {
               formatAdjusted = new TextFormat(format.font,format.size,format.color,null,null,null,null,null,"left");
               this._textField.setTextFormat(formatAdjusted);
               _matrix.translate(Math.floor((width - this._textField.getLineMetrics(0).width) / 2),0);
            }
            if(this._shadow > 0)
            {
               this._textField.setTextFormat(new TextFormat(formatAdjusted.font,formatAdjusted.size,this._shadow,null,null,null,null,null,formatAdjusted.align));
               _matrix.translate(1,1);
               _pixels.draw(this._textField,_matrix,_colorTransform);
               _matrix.translate(-1,-1);
               this._textField.setTextFormat(new TextFormat(formatAdjusted.font,formatAdjusted.size,formatAdjusted.color,null,null,null,null,null,formatAdjusted.align));
            }
            _pixels.draw(this._textField,_matrix,_colorTransform);
            this._textField.setTextFormat(new TextFormat(format.font,format.size,format.color,null,null,null,null,null,format.align));
         }
         if(framePixels == null || framePixels.width != _pixels.width || framePixels.height != _pixels.height)
         {
            framePixels = new BitmapData(_pixels.width,_pixels.height,true,0);
         }
         framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
      }
      
      protected function dtfCopy() : TextFormat
      {
         var defaultTextFormat:TextFormat = this._textField.defaultTextFormat;
         return new TextFormat(defaultTextFormat.font,defaultTextFormat.size,defaultTextFormat.color,defaultTextFormat.bold,defaultTextFormat.italic,defaultTextFormat.underline,defaultTextFormat.url,defaultTextFormat.target,defaultTextFormat.align);
      }
   }
}

