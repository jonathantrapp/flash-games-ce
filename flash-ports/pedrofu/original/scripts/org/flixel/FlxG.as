package org.flixel
{
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import org.flixel.plugin.DebugPathDisplay;
   import org.flixel.plugin.TimerManager;
   import org.flixel.system.FlxQuadTree;
   import org.flixel.system.input.*;
   
   public class FlxG
   {
      
      public static var _game:FlxGame;
      
      public static var paused:Boolean;
      
      public static var debug:Boolean;
      
      public static var elapsed:Number;
      
      public static var timeScale:Number;
      
      public static var width:uint;
      
      public static var height:uint;
      
      public static var worldBounds:FlxRect;
      
      public static var worldDivisions:uint;
      
      public static var visualDebug:Boolean;
      
      public static var mobile:Boolean;
      
      public static var globalSeed:Number;
      
      public static var levels:Array;
      
      public static var level:int;
      
      public static var scores:Array;
      
      public static var score:int;
      
      public static var saves:Array;
      
      public static var save:int;
      
      public static var mouse:Mouse;
      
      public static var keys:Keyboard;
      
      public static var music:FlxSound;
      
      public static var sounds:FlxGroup;
      
      public static var mute:Boolean;
      
      protected static var _volume:Number;
      
      public static var cameras:Array;
      
      public static var camera:FlxCamera;
      
      public static var useBufferLocking:Boolean;
      
      protected static var _cameraRect:Rectangle;
      
      public static var plugins:Array;
      
      public static var volumeHandler:Function;
      
      public static var flashGfxSprite:Sprite;
      
      public static var flashGfx:Graphics;
      
      protected static var _cache:Object;
      
      public static var LIBRARY_NAME:String = "flixel";
      
      public static var LIBRARY_MAJOR_VERSION:uint = 2;
      
      public static var LIBRARY_MINOR_VERSION:uint = 55;
      
      public static const DEBUGGER_STANDARD:uint = 0;
      
      public static const DEBUGGER_MICRO:uint = 1;
      
      public static const DEBUGGER_BIG:uint = 2;
      
      public static const DEBUGGER_TOP:uint = 3;
      
      public static const DEBUGGER_LEFT:uint = 4;
      
      public static const DEBUGGER_RIGHT:uint = 5;
      
      public static const RED:uint = 4294901778;
      
      public static const GREEN:uint = 4278252069;
      
      public static const BLUE:uint = 4278227177;
      
      public static const PINK:uint = 4293926655;
      
      public static const WHITE:uint = 4294967295;
      
      public static const BLACK:uint = 4278190080;
      
      public function FlxG()
      {
         super();
      }
      
      public static function getLibraryName() : String
      {
         return FlxG.LIBRARY_NAME + " v" + FlxG.LIBRARY_MAJOR_VERSION + "." + FlxG.LIBRARY_MINOR_VERSION;
      }
      
      public static function log(Data:Object) : void
      {
         if(_game != null && _game._debugger != null)
         {
            _game._debugger.log.add(Data == null ? "ERROR: null object" : Data.toString());
         }
      }
      
      public static function watch(AnyObject:Object, VariableName:String, DisplayName:String = null) : void
      {
         if(_game != null && _game._debugger != null)
         {
            _game._debugger.watch.add(AnyObject,VariableName,DisplayName);
         }
      }
      
      public static function unwatch(AnyObject:Object, VariableName:String = null) : void
      {
         if(_game != null && _game._debugger != null)
         {
            _game._debugger.watch.remove(AnyObject,VariableName);
         }
      }
      
      public static function get framerate() : Number
      {
         return 1000 / _game._step;
      }
      
      public static function set framerate(Framerate:Number) : void
      {
         _game._step = 1000 / Framerate;
         if(_game._maxAccumulation < _game._step)
         {
            _game._maxAccumulation = _game._step;
         }
      }
      
      public static function get flashFramerate() : Number
      {
         if(_game.root != null)
         {
            return _game.stage.frameRate;
         }
         return 0;
      }
      
      public static function set flashFramerate(Framerate:Number) : void
      {
         _game._flashFramerate = Framerate;
         if(_game.root != null)
         {
            _game.stage.frameRate = _game._flashFramerate;
         }
         _game._maxAccumulation = 2000 / _game._flashFramerate - 1;
         if(_game._maxAccumulation < _game._step)
         {
            _game._maxAccumulation = _game._step;
         }
      }
      
      public static function random() : Number
      {
         return globalSeed = FlxU.srand(globalSeed);
      }
      
      public static function shuffle(Objects:Array, HowManyTimes:uint) : Array
      {
         var index1:uint = 0;
         var index2:uint = 0;
         var object:Object = null;
         var i:uint = 0;
         while(i < HowManyTimes)
         {
            index1 = FlxG.random() * Objects.length;
            index2 = FlxG.random() * Objects.length;
            object = Objects[index2];
            Objects[index2] = Objects[index1];
            Objects[index1] = object;
            i++;
         }
         return Objects;
      }
      
      public static function getRandom(Objects:Array, StartIndex:uint = 0, Length:uint = 0) : Object
      {
         var l:uint = 0;
         if(Objects != null)
         {
            l = Length;
            if(l == 0 || l > Objects.length - StartIndex)
            {
               l = Objects.length - StartIndex;
            }
            if(l > 0)
            {
               return Objects[StartIndex + uint(FlxG.random() * l)];
            }
         }
         return null;
      }
      
      public static function loadReplay(Data:String, State:FlxState = null, CancelKeys:Array = null, Timeout:Number = 0, Callback:Function = null) : void
      {
         _game._replay.load(Data);
         if(State == null)
         {
            FlxG.resetGame();
         }
         else
         {
            FlxG.switchState(State);
         }
         _game._replayCancelKeys = CancelKeys;
         _game._replayTimer = Timeout * 1000;
         _game._replayCallback = Callback;
         _game._replayRequested = true;
      }
      
      public static function reloadReplay(StandardMode:Boolean = true) : void
      {
         if(StandardMode)
         {
            FlxG.resetGame();
         }
         else
         {
            FlxG.resetState();
         }
         if(_game._replay.frameCount > 0)
         {
            _game._replayRequested = true;
         }
      }
      
      public static function stopReplay() : void
      {
         _game._replaying = false;
         if(_game._debugger != null)
         {
            _game._debugger.vcr.stopped();
         }
         resetInput();
      }
      
      public static function recordReplay(StandardMode:Boolean = true) : void
      {
         if(StandardMode)
         {
            FlxG.resetGame();
         }
         else
         {
            FlxG.resetState();
         }
         _game._recordingRequested = true;
      }
      
      public static function stopRecording() : String
      {
         _game._recording = false;
         if(_game._debugger != null)
         {
            _game._debugger.vcr.stopped();
         }
         return _game._replay.save();
      }
      
      public static function resetState() : void
      {
         _game._requestedState = new (FlxU.getClass(FlxU.getClassName(_game._state,false)))();
      }
      
      public static function resetGame() : void
      {
         _game._requestedReset = true;
      }
      
      public static function resetInput() : void
      {
         keys.reset();
         mouse.reset();
      }
      
      public static function playMusic(Music:Class, Volume:Number = 1) : void
      {
         if(music == null)
         {
            music = new FlxSound();
         }
         else if(music.active)
         {
            music.stop();
         }
         music.loadEmbedded(Music,true);
         music.volume = Volume;
         music.survive = true;
         music.play();
      }
      
      public static function loadSound(EmbeddedSound:Class = null, Volume:Number = 1, Looped:Boolean = false, AutoDestroy:Boolean = false, AutoPlay:Boolean = false, URL:String = null) : FlxSound
      {
         if(EmbeddedSound == null && URL == null)
         {
            FlxG.log("WARNING: FlxG.loadSound() requires either\nan embedded sound or a URL to work.");
            return null;
         }
         var sound:FlxSound = sounds.recycle(FlxSound) as FlxSound;
         if(EmbeddedSound != null)
         {
            sound.loadEmbedded(EmbeddedSound,Looped,AutoDestroy);
         }
         else
         {
            sound.loadStream(URL,Looped,AutoDestroy);
         }
         sound.volume = Volume;
         if(AutoPlay)
         {
            sound.play();
         }
         return sound;
      }
      
      public static function play(EmbeddedSound:Class, Volume:Number = 1, Looped:Boolean = false, AutoDestroy:Boolean = true) : FlxSound
      {
         return FlxG.loadSound(EmbeddedSound,Volume,Looped,AutoDestroy,true);
      }
      
      public static function stream(URL:String, Volume:Number = 1, Looped:Boolean = false, AutoDestroy:Boolean = true) : FlxSound
      {
         return FlxG.loadSound(null,Volume,Looped,AutoDestroy,true,URL);
      }
      
      public static function get volume() : Number
      {
         return _volume;
      }
      
      public static function set volume(Volume:Number) : void
      {
         _volume = Volume;
         if(_volume < 0)
         {
            _volume = 0;
         }
         else if(_volume > 1)
         {
            _volume = 1;
         }
         if(volumeHandler != null)
         {
            volumeHandler(FlxG.mute ? 0 : _volume);
         }
      }
      
      internal static function destroySounds(ForceDestroy:Boolean = false) : void
      {
         var sound:FlxSound = null;
         if(music != null && (ForceDestroy || !music.survive))
         {
            music.destroy();
            music = null;
         }
         var i:uint = 0;
         var l:uint = sounds.members.length;
         while(i < l)
         {
            sound = sounds.members[i++] as FlxSound;
            if(sound != null && (ForceDestroy || !sound.survive))
            {
               sound.destroy();
            }
         }
      }
      
      internal static function updateSounds() : void
      {
         if(music != null && music.active)
         {
            music.update();
         }
         if(sounds != null && sounds.active)
         {
            sounds.update();
         }
      }
      
      public static function pauseSounds() : void
      {
         var sound:FlxSound = null;
         if(music != null && music.exists && music.active)
         {
            music.pause();
         }
         var i:uint = 0;
         var l:uint = sounds.length;
         while(i < l)
         {
            sound = sounds.members[i++] as FlxSound;
            if(sound != null && sound.exists && sound.active)
            {
               sound.pause();
            }
         }
      }
      
      public static function resumeSounds() : void
      {
         var sound:FlxSound = null;
         if(music != null && music.exists)
         {
            music.play();
         }
         var i:uint = 0;
         var l:uint = sounds.length;
         while(i < l)
         {
            sound = sounds.members[i++] as FlxSound;
            if(sound != null && sound.exists)
            {
               sound.resume();
            }
         }
      }
      
      public static function checkBitmapCache(Key:String) : Boolean
      {
         return _cache[Key] != undefined && _cache[Key] != null;
      }
      
      public static function createBitmap(Width:uint, Height:uint, Color:uint, Unique:Boolean = false, Key:String = null) : BitmapData
      {
         var inc:uint = 0;
         var ukey:String = null;
         if(Key == null)
         {
            Key = Width + "x" + Height + ":" + Color;
            if(Unique && checkBitmapCache(Key))
            {
               inc = 0;
               do
               {
                  ukey = Key + inc++;
               }
               while(checkBitmapCache(ukey));
               Key = ukey;
            }
         }
         if(!checkBitmapCache(Key))
         {
            _cache[Key] = new BitmapData(Width,Height,true,Color);
         }
         return _cache[Key];
      }
      
      public static function addBitmap(Graphic:Class, Reverse:Boolean = false, Unique:Boolean = false, Key:String = null) : BitmapData
      {
         var inc:uint = 0;
         var ukey:String = null;
         var newPixels:BitmapData = null;
         var mtx:Matrix = null;
         var needReverse:Boolean = false;
         if(Key == null)
         {
            Key = String(Graphic) + (Reverse ? "_REVERSE_" : "");
            if(Unique && checkBitmapCache(Key))
            {
               inc = 0;
               do
               {
                  ukey = Key + inc++;
               }
               while(checkBitmapCache(ukey));
               Key = ukey;
            }
         }
         if(!checkBitmapCache(Key))
         {
            _cache[Key] = new Graphic().bitmapData;
            if(Reverse)
            {
               needReverse = true;
            }
         }
         var pixels:BitmapData = _cache[Key];
         if(!needReverse && Reverse && pixels.width == new Graphic().bitmapData.width)
         {
            needReverse = true;
         }
         if(needReverse)
         {
            newPixels = new BitmapData(pixels.width << 1,pixels.height,true,0);
            newPixels.draw(pixels);
            mtx = new Matrix();
            mtx.scale(-1,1);
            mtx.translate(newPixels.width,0);
            newPixels.draw(pixels,mtx);
            pixels = newPixels;
            _cache[Key] = pixels;
         }
         return pixels;
      }
      
      public static function clearBitmapCache() : void
      {
         _cache = new Object();
      }
      
      public static function get stage() : Stage
      {
         if(_game.root != null)
         {
            return _game.stage;
         }
         return null;
      }
      
      public static function get state() : FlxState
      {
         return _game._state;
      }
      
      public static function switchState(State:FlxState) : void
      {
         _game._requestedState = State;
      }
      
      public static function setDebuggerLayout(Layout:uint) : void
      {
         if(_game._debugger != null)
         {
            _game._debugger.setLayout(Layout);
         }
      }
      
      public static function resetDebuggerLayout() : void
      {
         if(_game._debugger != null)
         {
            _game._debugger.resetLayout();
         }
      }
      
      public static function addCamera(NewCamera:FlxCamera) : FlxCamera
      {
         FlxG._game.addChildAt(NewCamera._flashSprite,FlxG._game.getChildIndex(FlxG._game._mouse));
         FlxG.cameras.push(NewCamera);
         return NewCamera;
      }
      
      public static function removeCamera(Camera:FlxCamera, Destroy:Boolean = true) : void
      {
         try
         {
            FlxG._game.removeChild(Camera._flashSprite);
         }
         catch(E:Error)
         {
            FlxG.log("Error removing camera, not part of game.");
         }
         if(Destroy)
         {
            Camera.destroy();
         }
      }
      
      public static function resetCameras(NewCamera:FlxCamera = null) : void
      {
         var cam:FlxCamera = null;
         var i:uint = 0;
         var l:uint = cameras.length;
         while(i < l)
         {
            cam = FlxG.cameras[i++] as FlxCamera;
            FlxG._game.removeChild(cam._flashSprite);
            cam.destroy();
         }
         FlxG.cameras.length = 0;
         if(NewCamera == null)
         {
            NewCamera = new FlxCamera(0,0,FlxG.width,FlxG.height);
         }
         FlxG.camera = FlxG.addCamera(NewCamera);
      }
      
      public static function flash(Color:uint = 4294967295, Duration:Number = 1, OnComplete:Function = null, Force:Boolean = false) : void
      {
         var i:uint = 0;
         var l:uint = FlxG.cameras.length;
         while(i < l)
         {
            (FlxG.cameras[i++] as FlxCamera).flash(Color,Duration,OnComplete,Force);
         }
      }
      
      public static function fade(Color:uint = 4278190080, Duration:Number = 1, OnComplete:Function = null, Force:Boolean = false) : void
      {
         var i:uint = 0;
         var l:uint = FlxG.cameras.length;
         while(i < l)
         {
            (FlxG.cameras[i++] as FlxCamera).fade(Color,Duration,OnComplete,Force);
         }
      }
      
      public static function shake(Intensity:Number = 0.05, Duration:Number = 0.5, OnComplete:Function = null, Force:Boolean = true, Direction:uint = 0) : void
      {
         var i:uint = 0;
         var l:uint = FlxG.cameras.length;
         while(i < l)
         {
            (FlxG.cameras[i++] as FlxCamera).shake(Intensity,Duration,OnComplete,Force,Direction);
         }
      }
      
      public static function get bgColor() : uint
      {
         if(FlxG.camera == null)
         {
            return 4278190080;
         }
         return FlxG.camera.bgColor;
      }
      
      public static function set bgColor(Color:uint) : void
      {
         var i:uint = 0;
         var l:uint = FlxG.cameras.length;
         while(i < l)
         {
            (FlxG.cameras[i++] as FlxCamera).bgColor = Color;
         }
      }
      
      public static function overlap(ObjectOrGroup1:FlxBasic = null, ObjectOrGroup2:FlxBasic = null, NotifyCallback:Function = null, ProcessCallback:Function = null) : Boolean
      {
         if(ObjectOrGroup1 == null)
         {
            ObjectOrGroup1 = FlxG.state;
         }
         if(ObjectOrGroup2 === ObjectOrGroup1)
         {
            ObjectOrGroup2 = null;
         }
         FlxQuadTree.divisions = FlxG.worldDivisions;
         var quadTree:FlxQuadTree = new FlxQuadTree(FlxG.worldBounds.x,FlxG.worldBounds.y,FlxG.worldBounds.width,FlxG.worldBounds.height);
         quadTree.load(ObjectOrGroup1,ObjectOrGroup2,NotifyCallback,ProcessCallback);
         var result:Boolean = quadTree.execute();
         quadTree.destroy();
         return result;
      }
      
      public static function collide(ObjectOrGroup1:FlxBasic = null, ObjectOrGroup2:FlxBasic = null, NotifyCallback:Function = null) : Boolean
      {
         return overlap(ObjectOrGroup1,ObjectOrGroup2,NotifyCallback,FlxObject.separate);
      }
      
      public static function addPlugin(Plugin:FlxBasic) : FlxBasic
      {
         var pluginList:Array = FlxG.plugins;
         var i:uint = 0;
         var l:uint = pluginList.length;
         while(i < l)
         {
            if(pluginList[i++].toString() == Plugin.toString())
            {
               return Plugin;
            }
         }
         pluginList.push(Plugin);
         return Plugin;
      }
      
      public static function getPlugin(ClassType:Class) : FlxBasic
      {
         var pluginList:Array = FlxG.plugins;
         var i:uint = 0;
         var l:uint = pluginList.length;
         while(i < l)
         {
            if(pluginList[i] is ClassType)
            {
               return plugins[i];
            }
            i++;
         }
         return null;
      }
      
      public static function removePlugin(Plugin:FlxBasic) : FlxBasic
      {
         var pluginList:Array = FlxG.plugins;
         var i:int = pluginList.length - 1;
         while(i >= 0)
         {
            if(pluginList[i] == Plugin)
            {
               pluginList.splice(i,1);
            }
            i--;
         }
         return Plugin;
      }
      
      public static function removePluginType(ClassType:Class) : Boolean
      {
         var results:Boolean = false;
         var pluginList:Array = FlxG.plugins;
         var i:int = pluginList.length - 1;
         while(i >= 0)
         {
            if(pluginList[i] is ClassType)
            {
               pluginList.splice(i,1);
               results = true;
            }
            i--;
         }
         return results;
      }
      
      internal static function init(Game:FlxGame, Width:uint, Height:uint, Zoom:Number) : void
      {
         FlxG._game = Game;
         FlxG.width = Width;
         FlxG.height = Height;
         FlxG.mute = false;
         FlxG._volume = 0.5;
         FlxG.sounds = new FlxGroup();
         FlxG.volumeHandler = null;
         FlxG.clearBitmapCache();
         if(flashGfxSprite == null)
         {
            flashGfxSprite = new Sprite();
            flashGfx = flashGfxSprite.graphics;
         }
         FlxCamera.defaultZoom = Zoom;
         FlxG._cameraRect = new Rectangle();
         FlxG.cameras = new Array();
         useBufferLocking = false;
         plugins = new Array();
         addPlugin(new DebugPathDisplay());
         addPlugin(new TimerManager());
         FlxG.mouse = new Mouse(FlxG._game._mouse);
         FlxG.keys = new Keyboard();
         FlxG.mobile = false;
         FlxG.levels = new Array();
         FlxG.scores = new Array();
         FlxG.visualDebug = false;
      }
      
      internal static function reset() : void
      {
         FlxG.clearBitmapCache();
         FlxG.resetInput();
         FlxG.destroySounds(true);
         FlxG.levels.length = 0;
         FlxG.scores.length = 0;
         FlxG.level = 0;
         FlxG.score = 0;
         FlxG.paused = false;
         FlxG.timeScale = 1;
         FlxG.elapsed = 0;
         FlxG.globalSeed = Math.random();
         FlxG.worldBounds = new FlxRect(-10,-10,FlxG.width + 20,FlxG.height + 20);
         FlxG.worldDivisions = 6;
         var debugPathDisplay:DebugPathDisplay = FlxG.getPlugin(DebugPathDisplay) as DebugPathDisplay;
         if(debugPathDisplay != null)
         {
            debugPathDisplay.clear();
         }
      }
      
      internal static function updateInput() : void
      {
         FlxG.keys.update();
         if(!_game._debuggerUp || !_game._debugger.hasMouse)
         {
            FlxG.mouse.update(FlxG._game.mouseX,FlxG._game.mouseY);
         }
      }
      
      internal static function lockCameras() : void
      {
         var cam:FlxCamera = null;
         var cams:Array = FlxG.cameras;
         var i:uint = 0;
         var l:uint = cams.length;
         while(i < l)
         {
            cam = cams[i++] as FlxCamera;
            if(!(cam == null || !cam.exists || !cam.visible))
            {
               if(useBufferLocking)
               {
                  cam.buffer.lock();
               }
               cam.fill(cam.bgColor);
               cam.screen.dirty = true;
            }
         }
      }
      
      internal static function unlockCameras() : void
      {
         var cam:FlxCamera = null;
         var cams:Array = FlxG.cameras;
         var i:uint = 0;
         var l:uint = cams.length;
         while(i < l)
         {
            cam = cams[i++] as FlxCamera;
            if(!(cam == null || !cam.exists || !cam.visible))
            {
               cam.drawFX();
               if(useBufferLocking)
               {
                  cam.buffer.unlock();
               }
            }
         }
      }
      
      internal static function updateCameras() : void
      {
         var cam:FlxCamera = null;
         var cams:Array = FlxG.cameras;
         var i:uint = 0;
         var l:uint = cams.length;
         while(i < l)
         {
            cam = cams[i++] as FlxCamera;
            if(cam != null && cam.exists)
            {
               if(cam.active)
               {
                  cam.update();
               }
               cam._flashSprite.x = cam.x + cam._flashOffsetX;
               cam._flashSprite.y = cam.y + cam._flashOffsetY;
               cam._flashSprite.visible = cam.visible;
            }
         }
      }
      
      internal static function updatePlugins() : void
      {
         var plugin:FlxBasic = null;
         var pluginList:Array = FlxG.plugins;
         var i:uint = 0;
         var l:uint = pluginList.length;
         while(i < l)
         {
            plugin = pluginList[i++] as FlxBasic;
            if(plugin.exists && plugin.active)
            {
               plugin.update();
            }
         }
      }
      
      internal static function drawPlugins() : void
      {
         var plugin:FlxBasic = null;
         var pluginList:Array = FlxG.plugins;
         var i:uint = 0;
         var l:uint = pluginList.length;
         while(i < l)
         {
            plugin = pluginList[i++] as FlxBasic;
            if(plugin.exists && plugin.visible)
            {
               plugin.draw();
            }
         }
      }
   }
}

