package xplor.Menus
{
   import org.flixel.FlxG;
   import org.flixel.FlxSprite;
   import org.flixel.FlxState;
   import org.flixel.FlxText;
   import xplor.Global;
   import xplor.Sky;
   import xplor.Sounds;
   import xplor.TitleState;
   
   public class WinState extends FlxState
   {
      
      public static const btnY:int = 210;
      
      protected var sky:Sky;
      
      public var button:FlxSprite;
      
      public var buttonText:FlxText;
      
      public var info:FlxText;
      
      public var volSpr:FlxSprite;
      
      public var dAlpha:Number;
      
      public function WinState()
      {
         super();
      }
      
      override public function create() : void
      {
         var s:FlxSprite = null;
         var t:FlxText = null;
         FlxG.timeScale = 1;
         Global.Init();
         Global.levelNum = 5;
         this.sky = new Sky();
         add(this.sky);
         Sounds.playSong(0);
         var title:FlxText = new FlxText(0,2,320,"YOU WIN!");
         title.setFormat("volks",20,16777215,"center",1);
         add(title);
         t = new FlxText(0,60,320,"And so Pedro defeated the Yak Clan and " + "recovered every last fan letter.\n\n" + "But with the Boys\' Life Mail Blimp destroyed, Pedro had no way to get back home from the Himalayas.\n\n" + "...Well, that\'s a story for another day!");
         t.setFormat("volks",12,16777215,"center",1);
         add(t);
         this.button = new FlxSprite((320 - 142) / 2,btnY);
         this.button.loadGraphic(TitleState.BtnImage,true,false,142,29,true);
         add(this.button);
         t = new FlxText(0,btnY + 2,320,"Yay!");
         t.setFormat("volks",16,16777215,"center",1);
         this.buttonText = t;
         add(t);
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
         cursor = -1;
         if(this.button.overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            cursor = 1;
            this.button.frame = 1;
            this.buttonText.x = 2;
            this.buttonText.y = btnY + 2 + 2;
         }
         else
         {
            this.button.frame = 0;
            this.buttonText.x = 0;
            this.buttonText.y = btnY + 2 + 0;
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            cursor = 5;
         }
         if(FlxG.mouse.justPressed())
         {
            switch(cursor)
            {
               case 1:
                  FlxG.switchState(new TitleState());
                  break;
               case 5:
                  FlxG.mute = !FlxG.mute;
            }
         }
         if(FlxG.keys.justPressed("ESCAPE"))
         {
            FlxG.switchState(new TitleState());
         }
         super.update();
      }
   }
}

