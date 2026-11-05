package xplor.Menus
{
   import flash.net.*;
   import org.flixel.*;
   import xplor.*;
   
   public class MapState extends FlxState
   {
      
      public static const btnY:int = 90;
      
      protected var MapImage:Class = MapState_MapImage;
      
      protected var XImage:Class = MapState_XImage;
      
      protected var ButtonImage:Class = MapState_ButtonImage;
      
      protected var SkillPtBoxImage:Class = MapState_SkillPtBoxImage;
      
      public var levelData:Array = new Array(new Map_X(42,100,new Array()),new Map_X(93,110,new Array(57,105,68,107,79,110)),new Map_X(139,100,new Array(108,111,116,105,125,101)),new Map_X(174,87,new Array(153,100,162,94)),new Map_X(209,75,new Array(189,85,196,78)),new Map_X(247,103,new Array(223,79,233,83,240,91)),new Map_X(286,136,new Array(255,117,264,123,274,127)),new Map_X(280,175,new Array(286,151,282,160)),new Map_X(234,186,new Array(266,177,257,178,248,182)),new Map_X(189,198,new Array(220,190,212,195,203,197)),new Map_X(142,192,new Array(175,197,166,194,156,193)),new Map_X(95,198,new Array(127,193,119,198,109,199)),new Map_X(58,190,new Array(81,197,71,194)),new Map_X(42,169,new Array(45,182)),new Map_X(62,147,new Array(52,158)));
      
      protected var title:FlxSprite;
      
      public var back:FlxSprite;
      
      public var levels:Array;
      
      public var activeList:Array;
      
      public var activeDot:int;
      
      public var buttons:Array;
      
      public var volSpr:FlxSprite;
      
      public var dAlpha:Number;
      
      public var maxLevel:int;
      
      public var skillPts:FlxText;
      
      public function MapState()
      {
         super();
      }
      
      override public function create() : void
      {
         var s:FlxSprite = null;
         var t:FlxText = null;
         var i:int = 0;
         var j:int = 0;
         FlxG.timeScale = 1;
         this.back = new FlxSprite(0,0,this.MapImage);
         add(this.back);
         Sounds.playSong(0);
         this.levels = new Array();
         this.activeList = new Array();
         this.activeDot = -1;
         for(i = 0; i < this.levelData.length; i++)
         {
            if(i > Profile.levelsPassed)
            {
               break;
            }
            s = new FlxSprite(this.levelData[i].x - 9,this.levelData[i].y - 9);
            s.loadGraphic(this.XImage,true,false,19,18,true);
            add(s);
            this.levels.push(s);
            if(i == Profile.levelsPassed)
            {
               s.scale.x = 0;
               s.scale.y = 0;
               this.activeList.push(s);
            }
            for(j = 0; j < this.levelData[i].dots.length; j += 2)
            {
               s = new FlxSprite(this.levelData[i].dots[j] - 9,this.levelData[i].dots[j + 1] - 9);
               s.loadGraphic(this.XImage,true,false,19,18,true);
               s.frame = 3;
               add(s);
               if(i == Profile.levelsPassed)
               {
                  s.scale.x = 0;
                  s.scale.y = 0;
                  this.activeList.push(s);
               }
            }
         }
         if(this.activeList.length > 1)
         {
            this.activeDot = 1;
         }
         else if(this.activeList.length > 0)
         {
            this.activeDot = 0;
         }
         this.buttons = new Array();
         for(i = 1; i < 3; i++)
         {
            s = new FlxSprite(320 - 12 - 55 * 3 + i * 55,1);
            s.loadGraphic(this.ButtonImage,true,false,53,18,true);
            s.frame = i * 2;
            add(s);
            this.buttons.push(s);
         }
         if(Profile.skillPts > 0)
         {
            s = new FlxSprite(320 - 12 - 55 * 3 + 1 * 55 + 35,12,this.SkillPtBoxImage);
            add(s);
            this.skillPts = new FlxText(320 - 12 - 55 * 3 + 1 * 55 + 33,11,19,Profile.skillPts.toString());
            this.skillPts.setFormat("volks",12,16777215,"center",1);
            add(this.skillPts);
         }
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         add(this.volSpr);
         this.maxLevel = Profile.levelsPassed + 1;
         if(this.maxLevel > this.levels.length)
         {
            this.maxLevel = this.levels.length;
         }
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
         for(i = 0; i < this.maxLevel; i++)
         {
            if(Boolean(this.levels[i].overlapsPoint(FlxG.mouse.getScreenPosition())))
            {
               this.levels[i].frame = 1;
               cursor = 1000 + i;
            }
            else
            {
               this.levels[i].frame = 0;
            }
         }
         for(i = 0; i < 2; i++)
         {
            if(Boolean(this.buttons[i].overlapsPoint(FlxG.mouse.getScreenPosition())))
            {
               this.buttons[i].frame = i * 2 + 1 + 2;
               cursor = i;
            }
            else
            {
               this.buttons[i].frame = i * 2 + 2;
            }
         }
         if(FlxG.keys.justPressed("ESCAPE"))
         {
            FlxG.switchState(new TitleState());
            return;
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            cursor = 101;
         }
         if(FlxG.mouse.justPressed())
         {
            switch(cursor)
            {
               case 0:
                  Global.shopEntrance = 0;
                  FlxG.switchState(new SkillState());
                  return;
               case 1:
                  FlxG.switchState(new TitleState());
                  return;
               case 101:
                  FlxG.mute = !FlxG.mute;
                  break;
               case -1:
                  break;
               default:
                  Global.mode = Global.PLAY;
                  Global.levelNum = cursor - 1000;
                  FlxG.switchState(new PlayState());
                  return;
            }
         }
         if(this.activeDot != -1)
         {
            this.activeList[this.activeDot].scale.x += FlxG.elapsed * 4;
            this.activeList[this.activeDot].scale.y = this.activeList[this.activeDot].scale.x;
            if(this.activeList[this.activeDot].scale.x >= 1)
            {
               this.activeList[this.activeDot].scale.x = 1;
               this.activeList[this.activeDot].scale.y = 1;
               if(this.activeDot > 0)
               {
                  ++this.activeDot;
                  if(this.activeDot >= this.activeList.length)
                  {
                     this.activeDot = 0;
                  }
               }
               else
               {
                  this.activeDot = -1;
               }
            }
         }
         super.update();
      }
   }
}

