package org.flixel.system.debug
{
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import org.flixel.system.FlxWindow;
   
   public class Log extends FlxWindow
   {
      
      protected static const MAX_LOG_LINES:uint = 200;
      
      protected var _text:TextField;
      
      protected var _lines:Array;
      
      public function Log(Title:String, Width:Number, Height:Number, Resizable:Boolean = true, Bounds:Rectangle = null, BGColor:uint = 2139062143, TopColor:uint = 2130706432)
      {
         super(Title,Width,Height,Resizable,Bounds,BGColor,TopColor);
         this._text = new TextField();
         this._text.x = 2;
         this._text.y = 15;
         this._text.multiline = true;
         this._text.wordWrap = true;
         this._text.selectable = true;
         this._text.defaultTextFormat = new TextFormat("Courier",12,16777215);
         addChild(this._text);
         this._lines = new Array();
      }
      
      override public function destroy() : void
      {
         removeChild(this._text);
         this._text = null;
         this._lines = null;
         super.destroy();
      }
      
      public function add(Text:String) : void
      {
         var newText:String = null;
         var i:uint = 0;
         if(this._lines.length <= 0)
         {
            this._text.text = "";
         }
         this._lines.push(Text);
         if(this._lines.length > MAX_LOG_LINES)
         {
            this._lines.shift();
            newText = "";
            for(i = 0; i < this._lines.length; i++)
            {
               newText += this._lines[i] + "\n";
            }
            this._text.text = newText;
         }
         else
         {
            this._text.appendText(Text + "\n");
         }
         this._text.scrollV = this._text.height;
      }
      
      override protected function updateSize() : void
      {
         super.updateSize();
         this._text.width = _width - 10;
         this._text.height = _height - 15;
      }
   }
}

