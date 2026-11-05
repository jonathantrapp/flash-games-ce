package org.flixel.system.debug
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import org.flixel.FlxG;
   import org.flixel.FlxU;
   
   public class VCR extends Sprite
   {
      
      protected static const FILE_TYPES:Array = [new FileFilter("Flixel Game Recording","*.fgr")];
      
      protected static const DEFAULT_FILE_NAME:String = "replay.fgr";
      
      protected var ImgOpen:Class = VCR_ImgOpen;
      
      protected var ImgRecordOff:Class = VCR_ImgRecordOff;
      
      protected var ImgRecordOn:Class = VCR_ImgRecordOn;
      
      protected var ImgStop:Class = VCR_ImgStop;
      
      protected var ImgFlixel:Class = VCR_ImgFlixel;
      
      protected var ImgRestart:Class = VCR_ImgRestart;
      
      protected var ImgPause:Class = VCR_ImgPause;
      
      protected var ImgPlay:Class = VCR_ImgPlay;
      
      protected var ImgStep:Class = VCR_ImgStep;
      
      public var paused:Boolean;
      
      public var stepRequested:Boolean;
      
      protected var _open:Bitmap;
      
      protected var _recordOff:Bitmap;
      
      protected var _recordOn:Bitmap;
      
      protected var _stop:Bitmap;
      
      protected var _flixel:Bitmap;
      
      protected var _restart:Bitmap;
      
      protected var _pause:Bitmap;
      
      protected var _play:Bitmap;
      
      protected var _step:Bitmap;
      
      protected var _overOpen:Boolean;
      
      protected var _overRecord:Boolean;
      
      protected var _overRestart:Boolean;
      
      protected var _overPause:Boolean;
      
      protected var _overStep:Boolean;
      
      protected var _pressingOpen:Boolean;
      
      protected var _pressingRecord:Boolean;
      
      protected var _pressingRestart:Boolean;
      
      protected var _pressingPause:Boolean;
      
      protected var _pressingStep:Boolean;
      
      protected var _file:FileReference;
      
      protected var _runtimeDisplay:TextField;
      
      protected var _runtime:uint;
      
      public function VCR()
      {
         super();
         var spacing:uint = 7;
         this._open = new this.ImgOpen();
         addChild(this._open);
         this._recordOff = new this.ImgRecordOff();
         this._recordOff.x = this._open.x + this._open.width + spacing;
         addChild(this._recordOff);
         this._recordOn = new this.ImgRecordOn();
         this._recordOn.x = this._recordOff.x;
         this._recordOn.visible = false;
         addChild(this._recordOn);
         this._stop = new this.ImgStop();
         this._stop.x = this._recordOff.x;
         this._stop.visible = false;
         addChild(this._stop);
         this._flixel = new this.ImgFlixel();
         this._flixel.x = this._recordOff.x + this._recordOff.width + spacing;
         addChild(this._flixel);
         this._restart = new this.ImgRestart();
         this._restart.x = this._flixel.x + this._flixel.width + spacing;
         addChild(this._restart);
         this._pause = new this.ImgPause();
         this._pause.x = this._restart.x + this._restart.width + spacing;
         addChild(this._pause);
         this._play = new this.ImgPlay();
         this._play.x = this._pause.x;
         this._play.visible = false;
         addChild(this._play);
         this._step = new this.ImgStep();
         this._step.x = this._pause.x + this._pause.width + spacing;
         addChild(this._step);
         this._runtimeDisplay = new TextField();
         this._runtimeDisplay.width = width;
         this._runtimeDisplay.x = width;
         this._runtimeDisplay.y = -2;
         this._runtimeDisplay.multiline = false;
         this._runtimeDisplay.wordWrap = false;
         this._runtimeDisplay.selectable = false;
         this._runtimeDisplay.defaultTextFormat = new TextFormat("Courier",12,16777215,null,null,null,null,null,"center");
         this._runtimeDisplay.visible = false;
         addChild(this._runtimeDisplay);
         this._runtime = 0;
         this.stepRequested = false;
         this._file = null;
         this.unpress();
         this.checkOver();
         this.updateGUI();
         addEventListener(Event.ENTER_FRAME,this.init);
      }
      
      public function destroy() : void
      {
         this._file = null;
         removeChild(this._open);
         this._open = null;
         removeChild(this._recordOff);
         this._recordOff = null;
         removeChild(this._recordOn);
         this._recordOn = null;
         removeChild(this._stop);
         this._stop = null;
         removeChild(this._flixel);
         this._flixel = null;
         removeChild(this._restart);
         this._restart = null;
         removeChild(this._pause);
         this._pause = null;
         removeChild(this._play);
         this._play = null;
         removeChild(this._step);
         this._step = null;
         parent.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         parent.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         parent.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      public function recording() : void
      {
         this._stop.visible = false;
         this._recordOff.visible = false;
         this._recordOn.visible = true;
      }
      
      public function stopped() : void
      {
         this._stop.visible = false;
         this._recordOn.visible = false;
         this._recordOff.visible = true;
      }
      
      public function playing() : void
      {
         this._recordOff.visible = false;
         this._recordOn.visible = false;
         this._stop.visible = true;
      }
      
      public function updateRuntime(Time:uint) : void
      {
         this._runtime += Time;
         this._runtimeDisplay.text = FlxU.formatTime(this._runtime / 1000,true);
         if(!this._runtimeDisplay.visible)
         {
            this._runtimeDisplay.visible = true;
         }
      }
      
      public function onOpen() : void
      {
         this._file = new FileReference();
         this._file.addEventListener(Event.SELECT,this.onOpenSelect);
         this._file.addEventListener(Event.CANCEL,this.onOpenCancel);
         this._file.browse(FILE_TYPES);
      }
      
      protected function onOpenSelect(E:Event = null) : void
      {
         this._file.removeEventListener(Event.SELECT,this.onOpenSelect);
         this._file.removeEventListener(Event.CANCEL,this.onOpenCancel);
         this._file.addEventListener(Event.COMPLETE,this.onOpenComplete);
         this._file.addEventListener(IOErrorEvent.IO_ERROR,this.onOpenError);
         this._file.load();
      }
      
      protected function onOpenComplete(E:Event = null) : void
      {
         this._file.removeEventListener(Event.COMPLETE,this.onOpenComplete);
         this._file.removeEventListener(IOErrorEvent.IO_ERROR,this.onOpenError);
         var fileContents:String = null;
         var data:ByteArray = this._file.data;
         if(data != null)
         {
            fileContents = data.readUTFBytes(data.bytesAvailable);
         }
         this._file = null;
         if(fileContents == null || fileContents.length <= 0)
         {
            FlxG.log("ERROR: Empty flixel gameplay record.");
            return;
         }
         FlxG.loadReplay(fileContents);
      }
      
      protected function onOpenCancel(E:Event = null) : void
      {
         this._file.removeEventListener(Event.SELECT,this.onOpenSelect);
         this._file.removeEventListener(Event.CANCEL,this.onOpenCancel);
         this._file = null;
      }
      
      protected function onOpenError(E:Event = null) : void
      {
         this._file.removeEventListener(Event.COMPLETE,this.onOpenComplete);
         this._file.removeEventListener(IOErrorEvent.IO_ERROR,this.onOpenError);
         this._file = null;
         FlxG.log("ERROR: Unable to open flixel gameplay record.");
      }
      
      public function onRecord(StandardMode:Boolean = false) : void
      {
         if(this._play.visible)
         {
            this.onPlay();
         }
         FlxG.recordReplay(StandardMode);
      }
      
      public function stopRecording() : void
      {
         var data:String = FlxG.stopRecording();
         if(data != null && data.length > 0)
         {
            this._file = new FileReference();
            this._file.addEventListener(Event.COMPLETE,this.onSaveComplete);
            this._file.addEventListener(Event.CANCEL,this.onSaveCancel);
            this._file.addEventListener(IOErrorEvent.IO_ERROR,this.onSaveError);
            this._file.save(data,DEFAULT_FILE_NAME);
         }
      }
      
      protected function onSaveComplete(E:Event = null) : void
      {
         this._file.removeEventListener(Event.COMPLETE,this.onSaveComplete);
         this._file.removeEventListener(Event.CANCEL,this.onSaveCancel);
         this._file.removeEventListener(IOErrorEvent.IO_ERROR,this.onSaveError);
         this._file = null;
         FlxG.log("FLIXEL: successfully saved flixel gameplay record.");
      }
      
      protected function onSaveCancel(E:Event = null) : void
      {
         this._file.removeEventListener(Event.COMPLETE,this.onSaveComplete);
         this._file.removeEventListener(Event.CANCEL,this.onSaveCancel);
         this._file.removeEventListener(IOErrorEvent.IO_ERROR,this.onSaveError);
         this._file = null;
      }
      
      protected function onSaveError(E:Event = null) : void
      {
         this._file.removeEventListener(Event.COMPLETE,this.onSaveComplete);
         this._file.removeEventListener(Event.CANCEL,this.onSaveCancel);
         this._file.removeEventListener(IOErrorEvent.IO_ERROR,this.onSaveError);
         this._file = null;
         FlxG.log("ERROR: problem saving flixel gameplay record.");
      }
      
      public function onStop() : void
      {
         FlxG.stopReplay();
      }
      
      public function onRestart(StandardMode:Boolean = false) : void
      {
         if(Boolean(FlxG.reloadReplay(StandardMode)))
         {
            this._recordOff.visible = false;
            this._recordOn.visible = false;
            this._stop.visible = true;
         }
      }
      
      public function onPause() : void
      {
         this.paused = true;
         this._pause.visible = false;
         this._play.visible = true;
      }
      
      public function onPlay() : void
      {
         this.paused = false;
         this._play.visible = false;
         this._pause.visible = true;
      }
      
      public function onStep() : void
      {
         if(!this.paused)
         {
            this.onPause();
         }
         this.stepRequested = true;
      }
      
      protected function init(E:Event = null) : void
      {
         if(root == null)
         {
            return;
         }
         removeEventListener(Event.ENTER_FRAME,this.init);
         parent.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         parent.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         parent.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      protected function onMouseMove(E:MouseEvent = null) : void
      {
         if(!this.checkOver())
         {
            this.unpress();
         }
         this.updateGUI();
      }
      
      protected function onMouseDown(E:MouseEvent = null) : void
      {
         this.unpress();
         if(this._overOpen)
         {
            this._pressingOpen = true;
         }
         if(this._overRecord)
         {
            this._pressingRecord = true;
         }
         if(this._overRestart)
         {
            this._pressingRestart = true;
         }
         if(this._overPause)
         {
            this._pressingPause = true;
         }
         if(this._overStep)
         {
            this._pressingStep = true;
         }
      }
      
      protected function onMouseUp(E:MouseEvent = null) : void
      {
         if(this._overOpen && this._pressingOpen)
         {
            this.onOpen();
         }
         else if(this._overRecord && this._pressingRecord)
         {
            if(this._stop.visible)
            {
               this.onStop();
            }
            else if(this._recordOn.visible)
            {
               this.stopRecording();
            }
            else
            {
               this.onRecord(!E.altKey);
            }
         }
         else if(this._overRestart && this._pressingRestart)
         {
            this.onRestart(!E.altKey);
         }
         else if(this._overPause && this._pressingPause)
         {
            if(this._play.visible)
            {
               this.onPlay();
            }
            else
            {
               this.onPause();
            }
         }
         else if(this._overStep && this._pressingStep)
         {
            this.onStep();
         }
         this.unpress();
         this.checkOver();
         this.updateGUI();
      }
      
      protected function checkOver() : Boolean
      {
         this._overOpen = this._overRecord = this._overRestart = this._overPause = this._overStep = false;
         if(mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > 15)
         {
            return false;
         }
         if(mouseX >= this._recordOff.x && mouseX <= this._recordOff.x + this._recordOff.width)
         {
            this._overRecord = true;
         }
         if(!this._recordOn.visible && !this._overRecord)
         {
            if(mouseX >= this._open.x && mouseX <= this._open.x + this._open.width)
            {
               this._overOpen = true;
            }
            else if(mouseX >= this._restart.x && mouseX <= this._restart.x + this._restart.width)
            {
               this._overRestart = true;
            }
            else if(mouseX >= this._pause.x && mouseX <= this._pause.x + this._pause.width)
            {
               this._overPause = true;
            }
            else if(mouseX >= this._step.x && mouseX <= this._step.x + this._step.width)
            {
               this._overStep = true;
            }
         }
         return true;
      }
      
      protected function unpress() : void
      {
         this._pressingOpen = false;
         this._pressingRecord = false;
         this._pressingRestart = false;
         this._pressingPause = false;
         this._pressingStep = false;
      }
      
      protected function updateGUI() : void
      {
         if(this._recordOn.visible)
         {
            this._open.alpha = this._restart.alpha = this._pause.alpha = this._step.alpha = 0.35;
            this._recordOn.alpha = 1;
            return;
         }
         if(this._overOpen && this._open.alpha != 1)
         {
            this._open.alpha = 1;
         }
         else if(!this._overOpen && this._open.alpha != 0.8)
         {
            this._open.alpha = 0.8;
         }
         if(this._overRecord && this._recordOff.alpha != 1)
         {
            this._recordOff.alpha = this._recordOn.alpha = this._stop.alpha = 1;
         }
         else if(!this._overRecord && this._recordOff.alpha != 0.8)
         {
            this._recordOff.alpha = this._recordOn.alpha = this._stop.alpha = 0.8;
         }
         if(this._overRestart && this._restart.alpha != 1)
         {
            this._restart.alpha = 1;
         }
         else if(!this._overRestart && this._restart.alpha != 0.8)
         {
            this._restart.alpha = 0.8;
         }
         if(this._overPause && this._pause.alpha != 1)
         {
            this._pause.alpha = this._play.alpha = 1;
         }
         else if(!this._overPause && this._pause.alpha != 0.8)
         {
            this._pause.alpha = this._play.alpha = 0.8;
         }
         if(this._overStep && this._step.alpha != 1)
         {
            this._step.alpha = 1;
         }
         else if(!this._overStep && this._step.alpha != 0.8)
         {
            this._step.alpha = 0.8;
         }
      }
   }
}

