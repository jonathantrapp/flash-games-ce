package org.flixel
{
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   
   public class FlxSound extends FlxBasic
   {
      
      public var x:Number;
      
      public var y:Number;
      
      public var survive:Boolean;
      
      public var name:String;
      
      public var artist:String;
      
      public var amplitude:Number;
      
      public var amplitudeLeft:Number;
      
      public var amplitudeRight:Number;
      
      public var autoDestroy:Boolean;
      
      protected var _sound:Sound;
      
      protected var _channel:SoundChannel;
      
      protected var _transform:SoundTransform;
      
      protected var _position:Number;
      
      protected var _volume:Number;
      
      protected var _volumeAdjust:Number;
      
      protected var _looped:Boolean;
      
      protected var _target:FlxObject;
      
      protected var _radius:Number;
      
      protected var _pan:Boolean;
      
      protected var _fadeOutTimer:Number;
      
      protected var _fadeOutTotal:Number;
      
      protected var _pauseOnFadeOut:Boolean;
      
      protected var _fadeInTimer:Number;
      
      protected var _fadeInTotal:Number;
      
      public function FlxSound()
      {
         super();
         this.createSound();
      }
      
      protected function createSound() : void
      {
         this.destroy();
         this.x = 0;
         this.y = 0;
         if(this._transform == null)
         {
            this._transform = new SoundTransform();
         }
         this._transform.pan = 0;
         this._sound = null;
         this._position = 0;
         this._volume = 1;
         this._volumeAdjust = 1;
         this._looped = false;
         this._target = null;
         this._radius = 0;
         this._pan = false;
         this._fadeOutTimer = 0;
         this._fadeOutTotal = 0;
         this._pauseOnFadeOut = false;
         this._fadeInTimer = 0;
         this._fadeInTotal = 0;
         exists = false;
         active = false;
         visible = false;
         this.name = null;
         this.artist = null;
         this.amplitude = 0;
         this.amplitudeLeft = 0;
         this.amplitudeRight = 0;
         this.autoDestroy = false;
      }
      
      override public function destroy() : void
      {
         this.kill();
         this._transform = null;
         this._sound = null;
         this._channel = null;
         this._target = null;
         this.name = null;
         this.artist = null;
         super.destroy();
      }
      
      override public function update() : void
      {
         var d:Number = NaN;
         if(this._position != 0)
         {
            return;
         }
         var radial:Number = 1;
         var fade:Number = 1;
         if(this._target != null)
         {
            radial = FlxU.getDistance(new FlxPoint(this._target.x,this._target.y),new FlxPoint(this.x,this.y)) / this._radius;
            if(radial < 0)
            {
               radial = 0;
            }
            if(radial > 1)
            {
               radial = 1;
            }
            if(this._pan)
            {
               d = (this._target.x - this.x) / this._radius;
               if(d < -1)
               {
                  d = -1;
               }
               else if(d > 1)
               {
                  d = 1;
               }
               this._transform.pan = d;
            }
         }
         if(this._fadeOutTimer > 0)
         {
            this._fadeOutTimer -= FlxG.elapsed;
            if(this._fadeOutTimer <= 0)
            {
               if(this._pauseOnFadeOut)
               {
                  this.pause();
               }
               else
               {
                  this.stop();
               }
            }
            fade = this._fadeOutTimer / this._fadeOutTotal;
            if(fade < 0)
            {
               fade = 0;
            }
         }
         else if(this._fadeInTimer > 0)
         {
            this._fadeInTimer -= FlxG.elapsed;
            fade = this._fadeInTimer / this._fadeInTotal;
            if(fade < 0)
            {
               fade = 0;
            }
            fade = 1 - fade;
         }
         this._volumeAdjust = radial * fade;
         this.updateTransform();
         if(this._transform.volume > 0 && this._channel != null)
         {
            this.amplitudeLeft = this._channel.leftPeak / this._transform.volume;
            this.amplitudeRight = this._channel.rightPeak / this._transform.volume;
            this.amplitude = (this.amplitudeLeft + this.amplitudeRight) * 0.5;
         }
      }
      
      override public function kill() : void
      {
         super.kill();
         if(this._channel != null)
         {
            this.stop();
         }
      }
      
      public function loadEmbedded(EmbeddedSound:Class, Looped:Boolean = false, AutoDestroy:Boolean = false) : FlxSound
      {
         this.stop();
         this.createSound();
         this._sound = new EmbeddedSound();
         this._looped = Looped;
         this.updateTransform();
         exists = true;
         return this;
      }
      
      public function loadStream(SoundURL:String, Looped:Boolean = false, AutoDestroy:Boolean = false) : FlxSound
      {
         this.stop();
         this.createSound();
         this._sound = new Sound();
         this._sound.addEventListener(Event.ID3,this.gotID3);
         this._sound.load(new URLRequest(SoundURL));
         this._looped = Looped;
         this.updateTransform();
         exists = true;
         return this;
      }
      
      public function proximity(X:Number, Y:Number, Object:FlxObject, Radius:Number, Pan:Boolean = true) : FlxSound
      {
         this.x = X;
         this.y = Y;
         this._target = Object;
         this._radius = Radius;
         this._pan = Pan;
         return this;
      }
      
      public function play(ForceRestart:Boolean = false) : void
      {
         var oldAutoDestroy:Boolean = false;
         if(this._position < 0)
         {
            return;
         }
         if(ForceRestart)
         {
            oldAutoDestroy = this.autoDestroy;
            this.autoDestroy = false;
            this.stop();
            this.autoDestroy = oldAutoDestroy;
         }
         if(this._looped)
         {
            if(this._position == 0)
            {
               if(this._channel == null)
               {
                  this._channel = this._sound.play(0,9999,this._transform);
               }
               if(this._channel == null)
               {
                  exists = false;
               }
            }
            else
            {
               this._channel = this._sound.play(this._position,0,this._transform);
               if(this._channel == null)
               {
                  exists = false;
               }
               else
               {
                  this._channel.addEventListener(Event.SOUND_COMPLETE,this.looped);
               }
            }
         }
         else if(this._position == 0)
         {
            if(this._channel == null)
            {
               this._channel = this._sound.play(0,0,this._transform);
               if(this._channel == null)
               {
                  exists = false;
               }
               else
               {
                  this._channel.addEventListener(Event.SOUND_COMPLETE,this.stopped);
               }
            }
         }
         else
         {
            this._channel = this._sound.play(this._position,0,this._transform);
            if(this._channel == null)
            {
               exists = false;
            }
         }
         active = this._channel != null;
         this._position = 0;
      }
      
      public function resume() : void
      {
         if(this._position <= 0)
         {
            return;
         }
         if(this._looped)
         {
            this._channel = this._sound.play(this._position,0,this._transform);
            if(this._channel == null)
            {
               exists = false;
            }
            else
            {
               this._channel.addEventListener(Event.SOUND_COMPLETE,this.looped);
            }
         }
         else
         {
            this._channel = this._sound.play(this._position,0,this._transform);
            if(this._channel == null)
            {
               exists = false;
            }
         }
         active = this._channel != null;
      }
      
      public function pause() : void
      {
         if(this._channel == null)
         {
            this._position = -1;
            return;
         }
         this._position = this._channel.position;
         this._channel.stop();
         if(this._looped)
         {
            while(this._position >= this._sound.length)
            {
               this._position -= this._sound.length;
            }
         }
         if(this._position <= 0)
         {
            this._position = 1;
         }
         this._channel = null;
         active = false;
      }
      
      public function stop() : void
      {
         this._position = 0;
         if(this._channel != null)
         {
            this._channel.stop();
            this.stopped();
         }
      }
      
      public function fadeOut(Seconds:Number, PauseInstead:Boolean = false) : void
      {
         this._pauseOnFadeOut = PauseInstead;
         this._fadeInTimer = 0;
         this._fadeOutTimer = Seconds;
         this._fadeOutTotal = this._fadeOutTimer;
      }
      
      public function fadeIn(Seconds:Number) : void
      {
         this._fadeOutTimer = 0;
         this._fadeInTimer = Seconds;
         this._fadeInTotal = this._fadeInTimer;
         this.play();
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      public function set volume(Volume:Number) : void
      {
         this._volume = Volume;
         if(this._volume < 0)
         {
            this._volume = 0;
         }
         else if(this._volume > 1)
         {
            this._volume = 1;
         }
         this.updateTransform();
      }
      
      public function getActualVolume() : Number
      {
         return this._volume * this._volumeAdjust;
      }
      
      internal function updateTransform() : void
      {
         this._transform.volume = (FlxG.mute ? 0 : 1) * FlxG.volume * this._volume * this._volumeAdjust;
         if(this._channel != null)
         {
            this._channel.soundTransform = this._transform;
         }
      }
      
      protected function looped(event:Event = null) : void
      {
         if(this._channel == null)
         {
            return;
         }
         this._channel.removeEventListener(Event.SOUND_COMPLETE,this.looped);
         this._channel = null;
         this.play();
      }
      
      protected function stopped(event:Event = null) : void
      {
         if(!this._looped)
         {
            this._channel.removeEventListener(Event.SOUND_COMPLETE,this.stopped);
         }
         else
         {
            this._channel.removeEventListener(Event.SOUND_COMPLETE,this.looped);
         }
         this._channel = null;
         active = false;
         if(this.autoDestroy)
         {
            this.destroy();
         }
      }
      
      protected function gotID3(event:Event = null) : void
      {
         FlxG.log("got ID3 info!");
         if(this._sound.id3.songName.length > 0)
         {
            this.name = this._sound.id3.songName;
         }
         if(this._sound.id3.artist.length > 0)
         {
            this.artist = this._sound.id3.artist;
         }
         this._sound.removeEventListener(Event.ID3,this.gotID3);
      }
   }
}

