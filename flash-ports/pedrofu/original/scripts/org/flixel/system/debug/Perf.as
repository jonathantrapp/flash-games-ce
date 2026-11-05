package org.flixel.system.debug
{
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   import org.flixel.FlxG;
   import org.flixel.system.FlxWindow;
   
   public class Perf extends FlxWindow
   {
      
      protected var _text:TextField;
      
      protected var _lastTime:int;
      
      protected var _updateTimer:int;
      
      protected var _flixelUpdate:Array;
      
      protected var _flixelUpdateMarker:uint;
      
      protected var _flixelDraw:Array;
      
      protected var _flixelDrawMarker:uint;
      
      protected var _flash:Array;
      
      protected var _flashMarker:uint;
      
      protected var _activeObject:Array;
      
      protected var _objectMarker:uint;
      
      protected var _visibleObject:Array;
      
      protected var _visibleObjectMarker:uint;
      
      public function Perf(Title:String, Width:Number, Height:Number, Resizable:Boolean = true, Bounds:Rectangle = null, BGColor:uint = 2139062143, TopColor:uint = 2130706432)
      {
         super(Title,Width,Height,Resizable,Bounds,BGColor,TopColor);
         resize(90,66);
         this._lastTime = 0;
         this._updateTimer = 0;
         this._text = new TextField();
         this._text.width = _width;
         this._text.x = 2;
         this._text.y = 15;
         this._text.multiline = true;
         this._text.wordWrap = true;
         this._text.selectable = true;
         this._text.defaultTextFormat = new TextFormat("Courier",12,16777215);
         addChild(this._text);
         this._flixelUpdate = new Array(32);
         this._flixelUpdateMarker = 0;
         this._flixelDraw = new Array(32);
         this._flixelDrawMarker = 0;
         this._flash = new Array(32);
         this._flashMarker = 0;
         this._activeObject = new Array(32);
         this._objectMarker = 0;
         this._visibleObject = new Array(32);
         this._visibleObjectMarker = 0;
      }
      
      override public function destroy() : void
      {
         removeChild(this._text);
         this._text = null;
         this._flixelUpdate = null;
         this._flixelDraw = null;
         this._flash = null;
         this._activeObject = null;
         this._visibleObject = null;
         super.destroy();
      }
      
      public function update() : void
      {
         var i:uint = 0;
         var output:String = null;
         var flashPlayerFramerate:Number = NaN;
         var updateTime:uint = 0;
         var activeCount:uint = 0;
         var te:uint = 0;
         var drawTime:uint = 0;
         var visibleCount:uint = 0;
         var time:int = getTimer();
         var elapsed:int = time - this._lastTime;
         var updateEvery:uint = 500;
         if(elapsed > updateEvery)
         {
            elapsed = int(updateEvery);
         }
         this._lastTime = time;
         this._updateTimer += elapsed;
         if(this._updateTimer > updateEvery)
         {
            output = "";
            flashPlayerFramerate = 0;
            i = 0;
            while(i < this._flashMarker)
            {
               flashPlayerFramerate += this._flash[i++];
            }
            flashPlayerFramerate /= this._flashMarker;
            output += uint(1 / (flashPlayerFramerate / 1000)) + "/" + FlxG.flashFramerate + "fps\n";
            output += Number((System.totalMemory * 9.54e-7).toFixed(2)) + "MB\n";
            updateTime = 0;
            i = 0;
            while(i < this._flixelUpdateMarker)
            {
               updateTime += this._flixelUpdate[i++];
            }
            activeCount = 0;
            te = 0;
            i = 0;
            while(i < this._objectMarker)
            {
               activeCount += this._activeObject[i];
               visibleCount += this._visibleObject[i++];
            }
            activeCount /= this._objectMarker;
            output += "U:" + activeCount + " " + uint(updateTime / this._flixelDrawMarker) + "ms\n";
            drawTime = 0;
            i = 0;
            while(i < this._flixelDrawMarker)
            {
               drawTime += this._flixelDraw[i++];
            }
            visibleCount = 0;
            i = 0;
            while(i < this._visibleObjectMarker)
            {
               visibleCount += this._visibleObject[i++];
            }
            visibleCount /= this._visibleObjectMarker;
            output += "D:" + visibleCount + " " + uint(drawTime / this._flixelDrawMarker) + "ms";
            this._text.text = output;
            this._flixelUpdateMarker = 0;
            this._flixelDrawMarker = 0;
            this._flashMarker = 0;
            this._objectMarker = 0;
            this._visibleObjectMarker = 0;
            this._updateTimer -= updateEvery;
         }
      }
      
      public function flixelUpdate(Time:int) : void
      {
         this._flixelUpdate[this._flixelUpdateMarker++] = Time;
      }
      
      public function flixelDraw(Time:int) : void
      {
         this._flixelDraw[this._flixelDrawMarker++] = Time;
      }
      
      public function flash(Time:int) : void
      {
         this._flash[this._flashMarker++] = Time;
      }
      
      public function activeObjects(Count:int) : void
      {
         this._activeObject[this._objectMarker++] = Count;
      }
      
      public function visibleObjects(Count:int) : void
      {
         this._visibleObject[this._visibleObjectMarker++] = Count;
      }
   }
}

