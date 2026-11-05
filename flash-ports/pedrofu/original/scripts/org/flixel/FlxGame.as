package org.flixel
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.*;
   import flash.text.AntiAliasType;
   import flash.text.GridFitType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import flash.utils.getTimer;
   import org.flixel.plugin.TimerManager;
   import org.flixel.system.FlxDebugger;
   import org.flixel.system.FlxReplay;
   
   public class FlxGame extends Sprite
   {
      
      protected var junk:String = "FlxGame_junk";
      
      protected var SndBeep:Class = FlxGame_SndBeep;
      
      protected var ImgLogo:Class = FlxGame_ImgLogo;
      
      public var useSoundHotKeys:Boolean;
      
      public var useSystemCursor:Boolean;
      
      public var forceDebugger:Boolean;
      
      internal var _state:FlxState;
      
      internal var _mouse:Sprite;
      
      protected var _iState:Class;
      
      protected var _created:Boolean;
      
      protected var _total:uint;
      
      protected var _accumulator:int;
      
      protected var _lostFocus:Boolean;
      
      internal var _step:uint;
      
      internal var _flashFramerate:uint;
      
      internal var _maxAccumulation:uint;
      
      internal var _requestedState:FlxState;
      
      internal var _requestedReset:Boolean;
      
      protected var _focus:Sprite;
      
      protected var _soundTray:Sprite;
      
      protected var _soundTrayTimer:Number;
      
      protected var _soundTrayBars:Array;
      
      internal var _debugger:FlxDebugger;
      
      internal var _debuggerUp:Boolean;
      
      internal var _replay:FlxReplay;
      
      internal var _replayRequested:Boolean;
      
      internal var _recordingRequested:Boolean;
      
      internal var _replaying:Boolean;
      
      internal var _recording:Boolean;
      
      internal var _replayCancelKeys:Array;
      
      internal var _replayTimer:int;
      
      internal var _replayCallback:Function;
      
      public function FlxGame(GameSizeX:uint, GameSizeY:uint, InitialState:Class, Zoom:Number = 1, GameFramerate:uint = 60, FlashFramerate:uint = 30, UseSystemCursor:Boolean = false)
      {
         super();
         this._lostFocus = false;
         this._focus = new Sprite();
         this._focus.visible = false;
         this._soundTray = new Sprite();
         this._mouse = new Sprite();
         FlxG.init(this,GameSizeX,GameSizeY,Zoom);
         FlxG.framerate = GameFramerate;
         FlxG.flashFramerate = FlashFramerate;
         this._accumulator = this._step;
         this._total = 0;
         this._state = null;
         this.useSoundHotKeys = true;
         this.useSystemCursor = UseSystemCursor;
         if(!this.useSystemCursor)
         {
            Mouse.hide();
         }
         this.forceDebugger = false;
         this._debuggerUp = false;
         this._replay = new FlxReplay();
         this._replayRequested = false;
         this._recordingRequested = false;
         this._replaying = false;
         this._recording = false;
         this._iState = InitialState;
         this._requestedState = null;
         this._requestedReset = true;
         this._created = false;
         addEventListener(Event.ENTER_FRAME,this.create);
      }
      
      internal function showSoundTray(Silent:Boolean = false) : void
      {
         if(!Silent)
         {
            FlxG.play(this.SndBeep);
         }
         this._soundTrayTimer = 1;
         this._soundTray.y = 0;
         this._soundTray.visible = true;
         var globalVolume:uint = Math.round(FlxG.volume * 10);
         if(FlxG.mute)
         {
            globalVolume = 0;
         }
         for(var i:uint = 0; i < this._soundTrayBars.length; i++)
         {
            if(i < globalVolume)
            {
               this._soundTrayBars[i].alpha = 1;
            }
            else
            {
               this._soundTrayBars[i].alpha = 0.5;
            }
         }
      }
      
      protected function onKeyUp(FlashEvent:KeyboardEvent) : void
      {
         var c:int = 0;
         var code:String = null;
         if(this._debuggerUp && this._debugger.watch.editing)
         {
            return;
         }
         if(!FlxG.mobile)
         {
            if(this._debugger != null && (FlashEvent.keyCode == 192 || FlashEvent.keyCode == 220))
            {
               this._debugger.visible = !this._debugger.visible;
               this._debuggerUp = this._debugger.visible;
               if(this._debugger.visible)
               {
                  Mouse.show();
               }
               else if(!this.useSystemCursor)
               {
                  Mouse.hide();
               }
               return;
            }
            if(this.useSoundHotKeys)
            {
               c = int(FlashEvent.keyCode);
               code = String.fromCharCode(FlashEvent.charCode);
               switch(c)
               {
                  case 48:
                  case 96:
                     FlxG.mute = !FlxG.mute;
                     if(FlxG.volumeHandler != null)
                     {
                        FlxG.volumeHandler(FlxG.mute ? 0 : FlxG.volume);
                     }
                     this.showSoundTray();
                     return;
                  case 109:
                  case 189:
                     FlxG.mute = false;
                     FlxG.volume -= 0.1;
                     this.showSoundTray();
                     return;
                  case 107:
                  case 187:
                     FlxG.mute = false;
                     FlxG.volume += 0.1;
                     this.showSoundTray();
                     return;
               }
            }
         }
         if(this._replaying)
         {
            return;
         }
         FlxG.keys.handleKeyUp(FlashEvent);
      }
      
      protected function onKeyDown(FlashEvent:KeyboardEvent) : void
      {
         var cancel:Boolean = false;
         var replayCancelKey:String = null;
         var i:uint = 0;
         var l:uint = 0;
         if(this._debuggerUp && this._debugger.watch.editing)
         {
            return;
         }
         if(this._replaying && this._replayCancelKeys != null && this._debugger == null && FlashEvent.keyCode != 192 && FlashEvent.keyCode != 220)
         {
            cancel = false;
            i = 0;
            l = this._replayCancelKeys.length;
            while(i < l)
            {
               replayCancelKey = this._replayCancelKeys[i++];
               if(replayCancelKey == "ANY" || FlxG.keys.getKeyCode(replayCancelKey) == FlashEvent.keyCode)
               {
                  if(this._replayCallback != null)
                  {
                     this._replayCallback();
                     this._replayCallback = null;
                  }
                  else
                  {
                     FlxG.stopReplay();
                  }
                  break;
               }
            }
            return;
         }
         FlxG.keys.handleKeyDown(FlashEvent);
      }
      
      protected function onMouseDown(FlashEvent:MouseEvent) : void
      {
         var replayCancelKey:String = null;
         var i:uint = 0;
         var l:uint = 0;
         if(this._debuggerUp)
         {
            if(this._debugger.hasMouse)
            {
               return;
            }
            if(this._debugger.watch.editing)
            {
               this._debugger.watch.submit();
            }
         }
         if(this._replaying && this._replayCancelKeys != null)
         {
            i = 0;
            l = this._replayCancelKeys.length;
            while(i < l)
            {
               replayCancelKey = this._replayCancelKeys[i++] as String;
               if(replayCancelKey == "MOUSE" || replayCancelKey == "ANY")
               {
                  if(this._replayCallback != null)
                  {
                     this._replayCallback();
                     this._replayCallback = null;
                  }
                  else
                  {
                     FlxG.stopReplay();
                  }
                  break;
               }
            }
            return;
         }
         FlxG.mouse.handleMouseDown(FlashEvent);
      }
      
      protected function onMouseUp(FlashEvent:MouseEvent) : void
      {
         if(this._debuggerUp && this._debugger.hasMouse || this._replaying)
         {
            return;
         }
         FlxG.mouse.handleMouseUp(FlashEvent);
      }
      
      protected function onMouseWheel(FlashEvent:MouseEvent) : void
      {
         if(this._debuggerUp && this._debugger.hasMouse || this._replaying)
         {
            return;
         }
         FlxG.mouse.handleMouseWheel(FlashEvent);
      }
      
      public function onFocus(FlashEvent:Event = null) : void
      {
         if(!this._debuggerUp && !this.useSystemCursor)
         {
            Mouse.hide();
         }
         FlxG.resetInput();
         this._lostFocus = this._focus.visible = false;
         stage.frameRate = this._flashFramerate;
         FlxG.resumeSounds();
      }
      
      public function onFocusLost(FlashEvent:Event = null) : void
      {
         if(x != 0 || y != 0)
         {
            x = 0;
            y = 0;
         }
         Mouse.show();
         this._lostFocus = this._focus.visible = true;
         stage.frameRate = 10;
         FlxG.pauseSounds();
      }
      
      protected function onEnterFrame(FlashEvent:Event = null) : void
      {
         var mark:uint = uint(getTimer());
         var elapsedMS:uint = mark - this._total;
         this._total = mark;
         this.updateSoundTray(elapsedMS);
         if(!this._lostFocus)
         {
            if(this._debugger != null && this._debugger.vcr.paused)
            {
               if(this._debugger.vcr.stepRequested)
               {
                  this._debugger.vcr.stepRequested = false;
                  this.step();
               }
            }
            else
            {
               this._accumulator += elapsedMS;
               if(this._accumulator > this._maxAccumulation)
               {
                  this._accumulator = this._maxAccumulation;
               }
               while(this._accumulator >= this._step)
               {
                  this.step();
                  this._accumulator -= this._step;
               }
            }
            FlxBasic._VISIBLECOUNT = 0;
            this.draw();
            if(this._debuggerUp)
            {
               this._debugger.perf.flash(elapsedMS);
               this._debugger.perf.visibleObjects(FlxBasic._VISIBLECOUNT);
               this._debugger.perf.update();
               this._debugger.watch.update();
            }
         }
      }
      
      protected function switchState() : void
      {
         FlxG.resetCameras();
         FlxG.resetInput();
         FlxG.destroySounds();
         FlxG.clearBitmapCache();
         if(this._debugger != null)
         {
            this._debugger.watch.removeAll();
         }
         var timerManager:TimerManager = FlxTimer.manager;
         if(timerManager != null)
         {
            timerManager.clear();
         }
         if(this._state != null)
         {
            this._state.destroy();
         }
         this._state = this._requestedState;
         this._state.create();
      }
      
      protected function step() : void
      {
         if(this._requestedReset)
         {
            this._requestedReset = false;
            this._requestedState = new this._iState();
            this._replayTimer = 0;
            this._replayCancelKeys = null;
            FlxG.reset();
         }
         if(this._recordingRequested)
         {
            this._recordingRequested = false;
            this._replay.create(FlxG.globalSeed);
            this._recording = true;
            if(this._debugger != null)
            {
               this._debugger.vcr.recording();
               FlxG.log("FLIXEL: starting new flixel gameplay record.");
            }
         }
         else if(this._replayRequested)
         {
            this._replayRequested = false;
            this._replay.rewind();
            FlxG.globalSeed = this._replay.seed;
            if(this._debugger != null)
            {
               this._debugger.vcr.playing();
            }
            this._replaying = true;
         }
         if(this._state != this._requestedState)
         {
            this.switchState();
         }
         FlxBasic._ACTIVECOUNT = 0;
         if(this._replaying)
         {
            this._replay.playNextFrame();
            if(this._replayTimer > 0)
            {
               this._replayTimer -= this._step;
               if(this._replayTimer <= 0)
               {
                  if(this._replayCallback != null)
                  {
                     this._replayCallback();
                     this._replayCallback = null;
                  }
                  else
                  {
                     FlxG.stopReplay();
                  }
               }
            }
            if(this._replaying && this._replay.finished)
            {
               FlxG.stopReplay();
               if(this._replayCallback != null)
               {
                  this._replayCallback();
                  this._replayCallback = null;
               }
            }
            if(this._debugger != null)
            {
               this._debugger.vcr.updateRuntime(this._step);
            }
         }
         else
         {
            FlxG.updateInput();
         }
         if(this._recording)
         {
            this._replay.recordFrame();
            if(this._debugger != null)
            {
               this._debugger.vcr.updateRuntime(this._step);
            }
         }
         this.update();
         FlxG.mouse.wheel = 0;
         if(this._debuggerUp)
         {
            this._debugger.perf.activeObjects(FlxBasic._ACTIVECOUNT);
         }
      }
      
      protected function updateSoundTray(MS:Number) : void
      {
         var soundPrefs:FlxSave = null;
         if(this._soundTray != null)
         {
            if(this._soundTrayTimer > 0)
            {
               this._soundTrayTimer -= MS / 1000;
            }
            else if(this._soundTray.y > -this._soundTray.height)
            {
               this._soundTray.y -= MS / 1000 * FlxG.height * 2;
               if(this._soundTray.y <= -this._soundTray.height)
               {
                  this._soundTray.visible = false;
                  soundPrefs = new FlxSave();
                  if(soundPrefs.bind("flixel"))
                  {
                     if(soundPrefs.data.sound == null)
                     {
                        soundPrefs.data.sound = new Object();
                     }
                     soundPrefs.data.sound.mute = FlxG.mute;
                     soundPrefs.data.sound.volume = FlxG.volume;
                     soundPrefs.close();
                  }
               }
            }
         }
      }
      
      protected function update() : void
      {
         var mark:uint = uint(getTimer());
         FlxG.elapsed = FlxG.timeScale * (this._step / 1000);
         FlxG.updateSounds();
         FlxG.updatePlugins();
         this._state.update();
         FlxG.updateCameras();
         if(this._debuggerUp)
         {
            this._debugger.perf.flixelUpdate(getTimer() - mark);
         }
      }
      
      protected function draw() : void
      {
         var mark:uint = uint(getTimer());
         FlxG.lockCameras();
         this._state.draw();
         FlxG.drawPlugins();
         FlxG.unlockCameras();
         if(this._debuggerUp)
         {
            this._debugger.perf.flixelDraw(getTimer() - mark);
         }
      }
      
      public function CreateExtra() : void
      {
      }
      
      protected function create(FlashEvent:Event) : void
      {
         if(root == null)
         {
            return;
         }
         removeEventListener(Event.ENTER_FRAME,this.create);
         this.CreateExtra();
         this._total = getTimer();
         stage.scaleMode = StageScaleMode.NO_SCALE;
         stage.align = StageAlign.TOP_LEFT;
         stage.frameRate = this._flashFramerate;
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         addChild(this._mouse);
         if(!FlxG.mobile)
         {
            if(FlxG.debug || this.forceDebugger)
            {
               this._debugger = new FlxDebugger(FlxG.width * FlxCamera.defaultZoom,FlxG.height * FlxCamera.defaultZoom);
               addChild(this._debugger);
            }
            this.createSoundTray();
            stage.addEventListener(Event.DEACTIVATE,this.onFocusLost);
            stage.addEventListener(Event.ACTIVATE,this.onFocus);
            this.createFocusScreen();
         }
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      protected function createSoundTray() : void
      {
         this._soundTray.visible = false;
         this._soundTray.scaleX = 2;
         this._soundTray.scaleY = 2;
         var tmp:Bitmap = new Bitmap(new BitmapData(80,30,true,2130706432));
         this._soundTray.x = FlxG.width / 2 * FlxCamera.defaultZoom - tmp.width / 2 * this._soundTray.scaleX;
         this._soundTray.addChild(tmp);
         var text:TextField = new TextField();
         text.width = tmp.width;
         text.height = tmp.height;
         text.multiline = true;
         text.wordWrap = true;
         text.selectable = false;
         text.embedFonts = true;
         text.antiAliasType = AntiAliasType.NORMAL;
         text.gridFitType = GridFitType.PIXEL;
         text.defaultTextFormat = new TextFormat("system",8,16777215,null,null,null,null,null,"center");
         this._soundTray.addChild(text);
         text.text = "VOLUME";
         text.y = 16;
         var bx:uint = 10;
         var by:uint = 14;
         this._soundTrayBars = new Array();
         var i:uint = 0;
         while(i < 10)
         {
            tmp = new Bitmap(new BitmapData(4,++i,false,16777215));
            tmp.x = bx;
            tmp.y = by;
            this._soundTrayBars.push(this._soundTray.addChild(tmp));
            bx += 6;
            by--;
         }
         this._soundTray.y = -this._soundTray.height;
         this._soundTray.visible = false;
         addChild(this._soundTray);
         var soundPrefs:FlxSave = new FlxSave();
         if(soundPrefs.bind("flixel") && soundPrefs.data.sound != null)
         {
            if(soundPrefs.data.sound.volume != null)
            {
               FlxG.volume = soundPrefs.data.sound.volume;
            }
            if(soundPrefs.data.sound.mute != null)
            {
               FlxG.mute = soundPrefs.data.sound.mute;
            }
            soundPrefs.destroy();
         }
      }
      
      protected function createFocusScreen() : void
      {
         var gfx:Graphics = this._focus.graphics;
         var screenWidth:uint = FlxG.width * FlxCamera.defaultZoom;
         var screenHeight:uint = FlxG.height * FlxCamera.defaultZoom;
         gfx.moveTo(0,0);
         gfx.beginFill(0,0.5);
         gfx.lineTo(screenWidth,0);
         gfx.lineTo(screenWidth,screenHeight);
         gfx.lineTo(0,screenHeight);
         gfx.lineTo(0,0);
         gfx.endFill();
         var halfWidth:uint = screenWidth / 2;
         var halfHeight:uint = screenHeight / 2;
         var helper:uint = FlxU.min(halfWidth,halfHeight) / 3;
         gfx.moveTo(halfWidth - helper,halfHeight - helper);
         gfx.beginFill(16777215,0.65);
         gfx.lineTo(halfWidth + helper,halfHeight);
         gfx.lineTo(halfWidth - helper,halfHeight + helper);
         gfx.lineTo(halfWidth - helper,halfHeight - helper);
         gfx.endFill();
         var logo:Bitmap = new this.ImgLogo();
         logo.scaleX = int(helper / 10);
         if(logo.scaleX < 1)
         {
            logo.scaleX = 1;
         }
         logo.scaleY = logo.scaleX;
         logo.x -= logo.scaleX;
         logo.alpha = 0.35;
         this._focus.addChild(logo);
         addChild(this._focus);
      }
   }
}

