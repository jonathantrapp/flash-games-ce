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
      
      public var levelData:Array = new Array(new Map_X(93,219,new Array(88,241,91,232)),new Map_X(32,177,new Array(86,207,78,198,67,196,55,193,46,186)),new Map_X(70,155,new Array(32,163,38,156,47,153,56,153)),new Map_X(87,111,new Array(82,150,84,141,79,133,80,123)),new Map_X(31,92,new Array(74,105,64,103,55,107,45,111,35,108)),new Map_X(70,59,new Array(45,89,55,87,64,82,68,73)),new Map_X(111,62,new Array(81,62,90,62,99,62)),new Map_X(160,81,new Array(121,75,128,81,137,84,146,82)),new Map_X(208,79,new Array(173,80,181,76,189,75,196,79)),new Map_X(244,52,new Array(222,79,230,76,237,72,242,65)),new Map_X(277,65,new Array(257,55,264,61)),new Map_X(302,89,new Array(291,64,300,65,306,70,303,77)),new Map_X(275,128,new Array(301,102,299,111,294,119,288,126)),new Map_X(231,112,new Array(261,126,253,122,245,117)),new Map_X(225,160,new Array(223,124,218,131,221,139,224,147)),new Map_X(191,149,new Array(211,157,203,154)),new Map_X(163,110,new Array(178,148,169,148,160,150,152,146,149,137,155,130,161,124)));
      
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
         var _loc1_:FlxSprite = null;
         var _loc2_:FlxText = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         FlxG.timeScale = 1;
         this.back = new FlxSprite(0,0,this.MapImage);
         add(this.back);
         Sounds.playSong(0);
         this.levels = new Array();
         this.activeList = new Array();
         this.activeDot = -1;
         _loc3_ = 0;
         while(_loc3_ < this.levelData.length)
         {
            if(_loc3_ > Profile.levelsPassed)
            {
               break;
            }
            _loc1_ = new FlxSprite(this.levelData[_loc3_].x - 9,this.levelData[_loc3_].y - 9);
            _loc1_.loadGraphic(this.XImage,true,false,19,18,true);
            add(_loc1_);
            this.levels.push(_loc1_);
            if(_loc3_ == Profile.levelsPassed)
            {
               _loc1_.scale.x = 0;
               _loc1_.scale.y = 0;
               this.activeList.push(_loc1_);
            }
            _loc4_ = 0;
            while(_loc4_ < this.levelData[_loc3_].dots.length)
            {
               _loc1_ = new FlxSprite(this.levelData[_loc3_].dots[_loc4_] - 9,this.levelData[_loc3_].dots[_loc4_ + 1] - 9);
               _loc1_.loadGraphic(this.XImage,true,false,19,18,true);
               _loc1_.frame = 3;
               add(_loc1_);
               if(_loc3_ == Profile.levelsPassed)
               {
                  _loc1_.scale.x = 0;
                  _loc1_.scale.y = 0;
                  this.activeList.push(_loc1_);
               }
               _loc4_ += 2;
            }
            _loc3_++;
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
         _loc3_ = 1;
         while(_loc3_ < 3)
         {
            _loc1_ = new FlxSprite(320 - 12 - 55 * 3 + _loc3_ * 55,1);
            _loc1_.loadGraphic(this.ButtonImage,true,false,53,18,true);
            _loc1_.frame = _loc3_ * 2;
            add(_loc1_);
            this.buttons.push(_loc1_);
            _loc3_++;
         }
         if(Profile.skillPts > 0)
         {
            _loc1_ = new FlxSprite(320 - 12 - 55 * 3 + 1 * 55 + 35,12,this.SkillPtBoxImage);
            add(_loc1_);
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
         while(_loc1_ < this.maxLevel)
         {
            if(this.levels[_loc1_].overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               this.levels[_loc1_].frame = 1;
               _loc2_ = 1000 + _loc1_;
            }
            else
            {
               this.levels[_loc1_].frame = 0;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < 2)
         {
            if(this.buttons[_loc1_].overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               this.buttons[_loc1_].frame = _loc1_ * 2 + 1 + 2;
               _loc2_ = _loc1_;
            }
            else
            {
               this.buttons[_loc1_].frame = _loc1_ * 2 + 2;
            }
            _loc1_++;
         }
         if(FlxG.keys.justPressed("ESCAPE"))
         {
            FlxG.switchState(new TitleState());
            return;
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            _loc2_ = 101;
         }
         if(FlxG.mouse.justPressed())
         {
            switch(_loc2_)
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
                  Global.levelNum = _loc2_ - 1000;
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

