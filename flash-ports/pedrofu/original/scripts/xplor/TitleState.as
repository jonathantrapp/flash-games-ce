package xplor
{
   import flash.net.*;
   import org.flixel.*;
   import xplor.Menus.*;
   
   public class TitleState extends FlxState
   {
      
      public static const BtnImage:Class = TitleState_BtnImage;
      
      public static const btnY:int = 199;
      
      protected var TitleImage:Class = TitleState_TitleImage;
      
      protected var title:FlxSprite;
      
      public var back:FlxSprite;
      
      protected var copyText:FlxText;
      
      public var buttons:Array;
      
      public var volSpr:FlxSprite;
      
      public var dAlpha:Number;
      
      public function TitleState()
      {
         super();
      }
      
      override public function create() : void
      {
         var s:FlxSprite = null;
         var t:FlxText = null;
         Global.Init();
         Sounds.playSong(0);
         this.title = this.add(new FlxSprite(0,0,this.TitleImage)) as FlxSprite;
         var txt:Array = new Array("Play Game","Options");
         this.buttons = new Array();
         for(var i:int = 0; i < 2; i++)
         {
            s = new FlxSprite(12 + (142 + 12) * i,btnY);
            s.loadGraphic(BtnImage,true,false,142,29,true);
            this.buttons.push(s);
            add(s);
            t = new FlxText(12 + (142 + 12) * i,btnY + 2,142,txt[i]);
            t.setFormat("volks",16,16777215,"center",1);
            this.buttons.push(t);
            add(t);
         }
         t = new FlxText(0,230,320,"Music by Nosoapradio.us");
         t.scrollFactor.x = 0;
         t.setFormat("volks",8,16777215,"left",1);
         this.add(t);
         this.copyText = new FlxText(0,230,320,"Game copyright 2012, Hamumu Software");
         this.copyText.scrollFactor.x = 0;
         this.copyText.setFormat("volks",8,16777215,"right",1);
         this.add(this.copyText);
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         add(this.volSpr);
      }
      
      public function HamumuClick() : void
      {
         Sounds.play(Sounds.bipSnd);
         navigateToURL(new URLRequest("http://hamumu.com"),"_blank");
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
         for(i = 0; i < 2; i++)
         {
            if((this.buttons[i * 2] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               cursor = i;
               (this.buttons[i * 2] as FlxSprite).frame = 1;
               (this.buttons[i * 2 + 1] as FlxText).x = 12 + i * (142 + 12) + 4;
               (this.buttons[i * 2 + 1] as FlxText).y = btnY + 4;
            }
            else
            {
               (this.buttons[i * 2] as FlxSprite).frame = 0;
               (this.buttons[i * 2 + 1] as FlxText).x = 12 + i * (142 + 12) + 2;
               (this.buttons[i * 2 + 1] as FlxText).y = btnY + 2;
            }
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            cursor = 101;
         }
         if(this.copyText.overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            cursor = 100;
         }
         if(FlxG.mouse.justPressed())
         {
            switch(cursor)
            {
               case 0:
                  Global.mode = Global.PLAY;
                  Global.levelNum = 0;
                  if(Profile.LevelsPassed() == 0)
                  {
                     FlxG.switchState(new PlayState());
                  }
                  else
                  {
                     FlxG.switchState(new MapState());
                  }
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
         if(FlxG.keys.justPressed("E"))
         {
            Global.levelNum = 6;
            Global.time = 0;
            Global.mode = Global.EDIT;
            FlxG.switchState(new EditState());
         }
         super.update();
      }
   }
}

