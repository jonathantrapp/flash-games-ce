package xplor.Menus
{
   import flash.net.*;
   import org.flixel.*;
   import xplor.*;
   
   public class OptionState extends FlxState
   {
      
      public static const btnY:int = 40;
      
      protected var title:FlxSprite;
      
      public var back:FlxSprite;
      
      protected var sky:Sky;
      
      public var buttons:Array;
      
      public var info:FlxText;
      
      public var volSpr:FlxSprite;
      
      public var dAlpha:Number;
      
      public var resetStage:int;
      
      public function OptionState()
      {
         super();
      }
      
      override public function create() : void
      {
         var _loc2_:FlxSprite = null;
         var _loc3_:FlxText = null;
         Global.Init();
         this.sky = new Sky(1);
         add(this.sky);
         this.resetStage = 0;
         Sounds.playSong(0);
         var _loc1_:FlxText = new FlxText(0,2,320,"OPTIONS");
         _loc1_.setFormat("volks",20,16777215,"center",1);
         add(_loc1_);
         var _loc4_:Array = new Array("Sound: " + Profile.sndVol.toString() + "%","Music: " + Profile.musVol.toString() + "%","Reset Progress","Exit");
         this.buttons = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < 4)
         {
            _loc2_ = new FlxSprite((320 - 142) / 2,btnY + _loc5_ * 34);
            _loc2_.loadGraphic(TitleState.BtnImage,true,false,142,29,true);
            this.buttons.push(_loc2_);
            add(_loc2_);
            _loc3_ = new FlxText(0,btnY + 2 + _loc5_ * 34,320,_loc4_[_loc5_]);
            _loc3_.setFormat("volks",16,16777215,"center",1);
            this.buttons.push(_loc3_);
            add(_loc3_);
            _loc5_++;
         }
         this.info = new FlxText(0,210,320,"");
         this.info.setFormat("volks",8,16777215,"center",1);
         add(this.info);
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         add(this.volSpr);
         FlxG.mouse.show();
      }
      
      override public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(FlxG.mute)
         {
            this.volSpr.alpha = 0.5;
         }
         else
         {
            this.volSpr.alpha = 1;
         }
         if(FlxG.keys.Z || FlxG.keys.Y)
         {
         }
         _loc2_ = -1;
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            if((this.buttons[_loc1_ * 2] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               _loc2_ = _loc1_;
               (this.buttons[_loc1_ * 2] as FlxSprite).frame = 1;
               (this.buttons[_loc1_ * 2 + 1] as FlxText).x = 2;
               (this.buttons[_loc1_ * 2 + 1] as FlxText).y = btnY + 2 + _loc1_ * 34 + 2;
            }
            else
            {
               (this.buttons[_loc1_ * 2] as FlxSprite).frame = 0;
               (this.buttons[_loc1_ * 2 + 1] as FlxText).x = 0;
               (this.buttons[_loc1_ * 2 + 1] as FlxText).y = btnY + 2 + _loc1_ * 34;
            }
            _loc1_++;
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            _loc2_ = 5;
         }
         switch(_loc2_)
         {
            case 0:
               this.info.text = "Adjust sound volume.";
               break;
            case 1:
               this.info.text = "Adjust music volume.";
               break;
            case 2:
               this.info.text = "Erase all your progress in the game and start over.";
               break;
            case 5:
               this.info.text = "Click to toggle sounds and music.";
               break;
            default:
               this.info.text = "";
         }
         if(FlxG.mouse.justPressed())
         {
            switch(_loc2_)
            {
               case 0:
                  Profile.sndVol += 25;
                  if(Profile.sndVol > 100)
                  {
                     Profile.sndVol = 0;
                  }
                  Sounds.play(Sounds.bipSnd);
                  (this.buttons[0 * 2 + 1] as FlxText).text = "Sound: " + Profile.sndVol.toString() + "%";
                  break;
               case 1:
                  Profile.musVol += 25;
                  if(Profile.musVol > 100)
                  {
                     Profile.musVol = 0;
                  }
                  FlxG.music.volume = Profile.musVol / 100;
                  (this.buttons[1 * 2 + 1] as FlxText).text = "Music: " + Profile.musVol.toString() + "%";
                  break;
               case 2:
                  if(this.resetStage < 6)
                  {
                     ++this.resetStage;
                     Sounds.play(Sounds.SendWaveSnd);
                     switch(this.resetStage)
                     {
                        case 1:
                           (this.buttons[2 * 2 + 1] as FlxText).text = "Really reset?";
                           break;
                        case 2:
                           (this.buttons[2 * 2 + 1] as FlxText).text = "Are you sure!?";
                           break;
                        case 3:
                           (this.buttons[2 * 2 + 1] as FlxText).text = "You\'ll lose everything!";
                           break;
                        case 4:
                           (this.buttons[2 * 2 + 1] as FlxText).text = "One more click...";
                           break;
                        case 5:
                           (this.buttons[2 * 2 + 1] as FlxText).text = "Really, one more and it resets!";
                           break;
                        case 6:
                           Sounds.play(Sounds.BoomSnd);
                           Profile.ResetProgress();
                           (this.buttons[2 * 2 + 1] as FlxText).text = "PROGRESS IS CLEARED!";
                     }
                  }
                  break;
               case 3:
                  FlxG.switchState(new TitleState());
                  return;
               case 5:
                  FlxG.mute = !FlxG.mute;
            }
         }
         super.update();
      }
   }
}

