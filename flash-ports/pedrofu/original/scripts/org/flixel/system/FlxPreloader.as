package org.flixel.system
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import org.flixel.FlxG;
   
   public class FlxPreloader extends MovieClip
   {
      
      protected var ImgLogo:Class;
      
      protected var ImgLogoCorners:Class;
      
      protected var ImgLogoLight:Class;
      
      protected var _init:Boolean;
      
      protected var _buffer:Sprite;
      
      protected var _bmpBar:Bitmap;
      
      protected var _text:TextField;
      
      protected var _width:uint;
      
      protected var _height:uint;
      
      protected var _logo:Bitmap;
      
      protected var _logoGlow:Bitmap;
      
      protected var _min:uint;
      
      public var className:String;
      
      public var myURL:String;
      
      public var minDisplayTime:Number;
      
      public function FlxPreloader()
      {
         var tmp:Bitmap = null;
         var re:RegExp = null;
         var format:TextFormat = null;
         var textField:TextField = null;
         this.ImgLogo = FlxPreloader_ImgLogo;
         this.ImgLogoCorners = FlxPreloader_ImgLogoCorners;
         this.ImgLogoLight = FlxPreloader_ImgLogoLight;
         super();
         this.minDisplayTime = 0;
         stop();
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         try
         {
            throw new Error("Setting global debug flag...");
         }
         catch(E:Error)
         {
            re = /\[.*:[0-9]+\]/;
            FlxG.debug = re.test(E.getStackTrace());
         }
         if(!FlxG.debug && this.myURL != null && root.loaderInfo.url.indexOf(this.myURL) < 0)
         {
            tmp = new Bitmap(new BitmapData(stage.stageWidth,stage.stageHeight,true,4294967295));
            addChild(tmp);
            format = new TextFormat();
            format.color = 0;
            format.size = 16;
            format.align = "center";
            format.bold = true;
            format.font = "system";
            textField = new TextField();
            textField.width = tmp.width - 16;
            textField.height = tmp.height - 16;
            textField.y = 8;
            textField.multiline = true;
            textField.wordWrap = true;
            textField.embedFonts = true;
            textField.defaultTextFormat = format;
            textField.text = "Hi there!  It looks like somebody copied this game without my permission.  Just click anywhere, or copy-paste this URL into your browser.\n\n" + this.myURL + "\n\nto play the game at my site.  Thanks, and have fun!";
            addChild(textField);
            textField.addEventListener(MouseEvent.CLICK,this.goToMyURL);
            tmp.addEventListener(MouseEvent.CLICK,this.goToMyURL);
            return;
         }
         this._init = false;
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function goToMyURL(event:MouseEvent = null) : void
      {
         navigateToURL(new URLRequest("http://" + this.myURL));
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var mainClass:Class = null;
         var app:Object = null;
         var percent:Number = NaN;
         if(!this._init)
         {
            if(stage.stageWidth <= 0 || stage.stageHeight <= 0)
            {
               return;
            }
            this.create();
            this._init = true;
         }
         graphics.clear();
         var time:uint = uint(getTimer());
         if(framesLoaded >= totalFrames && time > this._min)
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            nextFrame();
            mainClass = Class(getDefinitionByName(this.className));
            if(Boolean(mainClass))
            {
               app = new mainClass();
               addChild(app as DisplayObject);
            }
            this.destroy();
         }
         else
         {
            percent = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
            if(this._min > 0 && percent > time / this._min)
            {
               percent = time / this._min;
            }
            this.update(percent);
         }
      }
      
      protected function create() : void
      {
         this._min = 0;
         if(!FlxG.debug)
         {
            this._min = this.minDisplayTime * 1000;
         }
         this._buffer = new Sprite();
         this._buffer.scaleX = 2;
         this._buffer.scaleY = 2;
         addChild(this._buffer);
         this._width = stage.stageWidth / this._buffer.scaleX;
         this._height = stage.stageHeight / this._buffer.scaleY;
         this._buffer.addChild(new Bitmap(new BitmapData(this._width,this._height,false,13406)));
         var bitmap:Bitmap = new this.ImgLogoLight();
         bitmap.smoothing = true;
         bitmap.width = bitmap.height = this._height;
         bitmap.x = (this._width - bitmap.width) / 2;
         this._buffer.addChild(bitmap);
         this._bmpBar = new Bitmap(new BitmapData(1,7,false,6253311));
         this._bmpBar.x = 4;
         this._bmpBar.y = this._height - 11;
         this._buffer.addChild(this._bmpBar);
         this._text = new TextField();
         this._text.defaultTextFormat = new TextFormat("system",8,6253311);
         this._text.embedFonts = true;
         this._text.selectable = false;
         this._text.multiline = false;
         this._text.x = 2;
         this._text.y = this._bmpBar.y - 11;
         this._text.width = 80;
         this._buffer.addChild(this._text);
         this._logo = new this.ImgLogo();
         this._logo.scaleX = this._logo.scaleY = this._height / 8;
         this._logo.x = (this._width - this._logo.width) / 2;
         this._logo.y = (this._height - this._logo.height) / 2;
         this._buffer.addChild(this._logo);
         this._logoGlow = new this.ImgLogo();
         this._logoGlow.smoothing = true;
         this._logoGlow.blendMode = "screen";
         this._logoGlow.scaleX = this._logoGlow.scaleY = this._height / 8;
         this._logoGlow.x = (this._width - this._logoGlow.width) / 2;
         this._logoGlow.y = (this._height - this._logoGlow.height) / 2;
         this._buffer.addChild(this._logoGlow);
         bitmap = new this.ImgLogoCorners();
         bitmap.smoothing = true;
         bitmap.width = this._width;
         bitmap.height = this._height;
         this._buffer.addChild(bitmap);
         bitmap = new Bitmap(new BitmapData(this._width,this._height,false,16777215));
         var i:uint = 0;
         var j:uint = 0;
         while(i < this._height)
         {
            j = 0;
            while(j < this._width)
            {
               bitmap.bitmapData.setPixel(j++,i,0);
            }
            i += 2;
         }
         bitmap.blendMode = "overlay";
         bitmap.alpha = 0.25;
         this._buffer.addChild(bitmap);
      }
      
      protected function destroy() : void
      {
         removeChild(this._buffer);
         this._buffer = null;
         this._bmpBar = null;
         this._text = null;
         this._logo = null;
         this._logoGlow = null;
      }
      
      protected function update(Percent:Number) : void
      {
         this._bmpBar.scaleX = Percent * (this._width - 8);
         this._text.text = "FLX v" + FlxG.LIBRARY_MAJOR_VERSION + "." + FlxG.LIBRARY_MINOR_VERSION + " " + Math.floor(Percent * 100) + "%";
         this._text.setTextFormat(this._text.defaultTextFormat);
         if(Percent < 0.1)
         {
            this._logoGlow.alpha = 0;
            this._logo.alpha = 0;
         }
         else if(Percent < 0.15)
         {
            this._logoGlow.alpha = Math.random();
            this._logo.alpha = 0;
         }
         else if(Percent < 0.2)
         {
            this._logoGlow.alpha = 0;
            this._logo.alpha = 0;
         }
         else if(Percent < 0.25)
         {
            this._logoGlow.alpha = 0;
            this._logo.alpha = Math.random();
         }
         else if(Percent < 0.7)
         {
            this._logoGlow.alpha = (Percent - 0.45) / 0.45;
            this._logo.alpha = 1;
         }
         else if(Percent > 0.8 && Percent < 0.9)
         {
            this._logoGlow.alpha = 1 - (Percent - 0.8) / 0.1;
            this._logo.alpha = 0;
         }
         else if(Percent > 0.9)
         {
            this._buffer.alpha = 1 - (Percent - 0.9) / 0.1;
         }
      }
   }
}

