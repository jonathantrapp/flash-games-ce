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
         var s:FlxSprite = null;
         var t:FlxText = null;
         Global.Init();
         this.sky = new Sky(1);
         add(this.sky);
         this.resetStage = 0;
         Sounds.playSong(0);
         var title:FlxText = new FlxText(0,2,320,"OPTIONS");
         title.setFormat("volks",20,16777215,"center",1);
         add(title);
         var txt:Array = new Array("Sound: " + Profile.sndVol.toString() + "%","Music: " + Profile.musVol.toString() + "%","Reset Progress","Exit");
         this.buttons = new Array();
         for(var i:int = 0; i < 4; i++)
         {
            s = new FlxSprite((320 - 142) / 2,btnY + i * 34);
            s.loadGraphic(TitleState.BtnImage,true,false,142,29,true);
            this.buttons.push(s);
            add(s);
            t = new FlxText(0,btnY + 2 + i * 34,320,txt[i]);
            t.setFormat("volks",16,16777215,"center",1);
            this.buttons.push(t);
            add(t);
         }
         this.info = new FlxText(0,210,320,"");
         this.info.setFormat("volks",8,16777215,"center",1);
         add(this.info);
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         add(this.volSpr);
      }
      
      override public function update() : void
      {
         var i:int = 0;
         var cursor:int = 0;
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
         cursor = -1;
         for(i = 0; i < 4; i++)
         {
            if((this.buttons[i * 2] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               cursor = i;
               (this.buttons[i * 2] as FlxSprite).frame = 1;
               (this.buttons[i * 2 + 1] as FlxText).x = 2;
               (this.buttons[i * 2 + 1] as FlxText).y = btnY + 2 + i * 34 + 2;
            }
            else
            {
               (this.buttons[i * 2] as FlxSprite).frame = 0;
               (this.buttons[i * 2 + 1] as FlxText).x = 0;
               (this.buttons[i * 2 + 1] as FlxText).y = btnY + 2 + i * 34;
            }
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            cursor = 5;
         }
         switch(cursor)
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
            switch(cursor)
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
                     Sounds.play(Sounds.SmashSnd);
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

