package xplor
{
   import flash.net.*;
   import org.flixel.*;
   import xplor.Menus.*;
   
   public class TitleState extends FlxState
   {
      
      public static const BtnImage:Class = TitleState_BtnImage;
      
      public static const btnY:int = 174;
      
      protected var TitleImage:Class = TitleState_TitleImage;
      
      protected var title:FlxSprite;
      
      public var back:FlxSprite;
      
      protected var copyText:FlxText;
      
      public var buttons:Array;
      
      public var info:FlxText;
      
      public var volSpr:FlxSprite;
      
      public var dAlpha:Number;
      
      public function TitleState()
      {
         super();
      }
      
      override public function create() : void
      {
         var _loc1_:FlxSprite = null;
         var _loc2_:FlxText = null;
         Global.Init();
         Sounds.playSong(0);
         this.title = this.add(new FlxSprite(0,0,this.TitleImage)) as FlxSprite;
         var _loc3_:Array = new Array("Play Game","Options");
         this.buttons = new Array();
         var _loc4_:int = 0;
         while(_loc4_ < 2)
         {
            _loc1_ = new FlxSprite((320 - 142) / 2,btnY + _loc4_ * 30);
            _loc1_.loadGraphic(BtnImage,true,false,142,29,true);
            this.buttons.push(_loc1_);
            add(_loc1_);
            _loc2_ = new FlxText((320 - 142) / 2,btnY + 2 + _loc4_ * 30,142,_loc3_[_loc4_]);
            _loc2_.setFormat("volks",16,16777215,"center",1);
            this.buttons.push(_loc2_);
            add(_loc2_);
            _loc4_++;
         }
         this.info = new FlxText(0,0,320,"");
         this.info.setFormat("volks",8,16777215,"center",1);
         add(this.info);
         _loc2_ = new FlxText(0,230,320,"Music by Nosoapradio.us");
         _loc2_.scrollFactor.x = 0;
         _loc2_.setFormat("volks",8,16777215,"left",1);
         this.add(_loc2_);
         this.copyText = new FlxText(0,230,320,"Game copyright 2012, Hamumu Software");
         this.copyText.scrollFactor.x = 0;
         this.copyText.setFormat("volks",8,16777215,"right",1);
         this.add(this.copyText);
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         add(this.volSpr);
         FlxG.mouse.show();
      }
      
      public function HamumuClick() : void
      {
         Sounds.play(Sounds.bipSnd);
         navigateToURL(new URLRequest("http://hamumu.com"),"_blank");
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
         while(_loc1_ < 2)
         {
            if((this.buttons[_loc1_ * 2] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               _loc2_ = _loc1_;
               (this.buttons[_loc1_ * 2] as FlxSprite).frame = 1;
               (this.buttons[_loc1_ * 2 + 1] as FlxText).x = (320 - 142) / 2 + 2;
               (this.buttons[_loc1_ * 2 + 1] as FlxText).y = btnY + 2 + _loc1_ * 30 + 2;
            }
            else
            {
               (this.buttons[_loc1_ * 2] as FlxSprite).frame = 0;
               (this.buttons[_loc1_ * 2 + 1] as FlxText).x = (320 - 142) / 2;
               (this.buttons[_loc1_ * 2 + 1] as FlxText).y = btnY + 2 + _loc1_ * 30;
            }
            _loc1_++;
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            _loc2_ = 101;
         }
         if(this.copyText.overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            _loc2_ = 100;
         }
         switch(_loc2_)
         {
            case 0:
               this.info.text = "Smack down some aliens!";
               break;
            case 1:
               this.info.text = "Adjust game settings or reset progress.";
               break;
            case 101:
               this.info.text = "Click to toggle sounds and music.";
               break;
            case 100:
               this.info.text = "Hamumu makes tons of Dumb games for your PC or Mac!";
               break;
            default:
               this.info.text = "";
         }
         if(FlxG.mouse.justPressed())
         {
            switch(_loc2_)
            {
               case 0:
                  Global.mode = Global.PLAY;
                  Global.levelNum = 0;
                  FlxG.switchState(new MapState());
                  break;
               case 1:
                  FlxG.switchState(new OptionState());
                  break;
               case 101:
                  FlxG.mute = !FlxG.mute;
                  break;
               case 100:
                  this.HamumuClick();
            }
         }
         super.update();
      }
   }
}

