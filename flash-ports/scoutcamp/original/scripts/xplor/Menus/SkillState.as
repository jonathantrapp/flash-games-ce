package xplor.Menus
{
   import flash.net.*;
   import org.flixel.*;
   import xplor.*;
   
   public class SkillState extends FlxState
   {
      
      public static var BackImage:Class = SkillState_BackImage;
      
      public static var FrameImage:Class = SkillState_FrameImage;
      
      public static var IconImage:Class = SkillState_IconImage;
      
      public static var TrayImage:Class = SkillState_TrayImage;
      
      public static var PointImage:Class = SkillState_PointImage;
      
      public var skills:Array = new Array(new SkillDef("Rock Tower",0,0,0,SkillDef.ROCKTOWER),new SkillDef("Big Bucks",0,0,2,SkillDef.BIGBUCKS),new SkillDef("Slingshot",0,1,0,SkillDef.SLINGSHOT),new SkillDef("Soapbox",0,1,2,SkillDef.SOAPBOX),new SkillDef("Hard Rock",0,2,0,SkillDef.HARDROCK),new SkillDef("Finish Him!",0,2,2,SkillDef.FINISHHIM),new SkillDef("Gathered Moss",0,3,0,SkillDef.GATHEREDMOSS),new SkillDef("Head Trauma",0,3,1,SkillDef.CONFUSION),new SkillDef("Encouragement",0,3,2,SkillDef.ENCOURAGEMENT),new SkillDef("Free Pebbles",0,4,0,SkillDef.FREE_PEBBLES),new SkillDef("Firepower",0,4,1,SkillDef.FIREPOWER),new SkillDef("Shatter",0,4,2,SkillDef.SHATTER),new SkillDef("Snow Fort",1,0,0,SkillDef.SNOWFORT),new SkillDef("Cash Flow",1,0,2,SkillDef.CASHFLOW),new SkillDef("Ice Launcher",1,1,0,SkillDef.ICELAUNCHER),new SkillDef("Slushee Maker",1,1,2,SkillDef.SLUSHEE),new SkillDef("Frostbite",1,2,0,SkillDef.FROSTBITE),new SkillDef("Refrigeration",1,2,2,SkillDef.REFRIGERATION),new SkillDef("Brain Freeze"
      ,1,3,0,SkillDef.BRAINFREEZE),new SkillDef("Ice Shards",1,3,1,SkillDef.ICESHARDS),new SkillDef("Blue Raspberry",1,3,2,SkillDef.BLUERAZZ),new SkillDef("Cold Hard Cash",1,4,0,SkillDef.SELL_TOWER),new SkillDef("Eagle Eye",1,4,1,SkillDef.EAGLEEYE),new SkillDef("Conductance",1,4,2,SkillDef.CONDUCTANCE),new SkillDef("Shocker",2,0,0,SkillDef.SHOCKER),new SkillDef("Construction",2,0,2,SkillDef.CONSTRUCTION),new SkillDef("Crippler",2,1,0,SkillDef.CRIPPLER),new SkillDef("Lightning Rod",2,1,2,SkillDef.LIGHTNINGROD),new SkillDef("Chain Lightning",2,2,0,SkillDef.CHAINLIGHTNING),new SkillDef("Shock Trap",2,2,2,SkillDef.SHOCKTRAP),new SkillDef("Arcing",2,3,0,SkillDef.ARCING),new SkillDef("Megawatt",2,3,1,SkillDef.MEGAWATT),new SkillDef("Heartstopper",2,3,2,SkillDef.HEARTSTOPPER),new SkillDef("Shock Rock",2,4,0,SkillDef.SHOCK_ROCK),new SkillDef("Rapid Fire",2,4,1,SkillDef.RAPIDFIRE),new SkillDef("Rolling Thunder",2,4,2,SkillDef.ROLLING_THUNDER),new SkillDef("Roly Poly",3,0,0,SkillDef.ROLYPOLY),new SkillDef("Enhancement"
      ,3,0,2,SkillDef.ENHANCEMENT),new SkillDef("Crusher",3,1,0,SkillDef.CRUSHER),new SkillDef("Quake-o-matic",3,1,2,SkillDef.QUAKE),new SkillDef("Rock n\' Roll",3,2,0,SkillDef.ROCKNROLL),new SkillDef("Poison Trap",3,2,2,SkillDef.POISONTRAP),new SkillDef("Rollback",3,3,0,SkillDef.ROLLBACK),new SkillDef("Flatten",3,3,1,SkillDef.FLATTEN),new SkillDef("Seismology",3,3,2,SkillDef.QUAKEUP),new SkillDef("Brittle Bones",3,4,0,SkillDef.BRITTLE_BONES),new SkillDef("Critical Strike",3,4,1,SkillDef.CRITICAL),new SkillDef("On A Roll",3,4,2,SkillDef.ON_A_ROLL));
      
      protected var sky:Sky;
      
      public var buttons:Array;
      
      public var points:Array;
      
      public var info:FlxText;
      
      public var info2:FlxText;
      
      public var progress:FlxText;
      
      public var volSpr:FlxSprite;
      
      public var dAlpha:Number;
      
      public var ptsLeft:FlxText;
      
      public var toolTip:ToolTip;
      
      public var canbuy:Boolean;
      
      public function SkillState()
      {
         super();
      }
      
      public function SkillBox(param1:int, param2:int, param3:int, param4:int, param5:int, param6:Boolean) : void
      {
         var _loc7_:FlxSprite = null;
         var _loc8_:int = 0;
         _loc7_ = new FlxSprite(param1 - 3,param2 - 3);
         _loc7_.loadGraphic(FrameImage,true,false,22,22,true);
         if(!param6)
         {
            _loc7_.frame = 0;
         }
         else
         {
            _loc7_.frame = param3 + 1;
         }
         add(_loc7_);
         this.buttons.push(_loc7_);
         _loc7_ = new FlxSprite(param1,param2);
         _loc7_.loadGraphic(IconImage,true,false,16,16,true);
         _loc7_.frame = param4;
         if(!param6)
         {
            _loc7_.frame += 48;
         }
         add(_loc7_);
         _loc7_ = new FlxSprite(param1,param2 + 15);
         _loc7_.loadGraphic(TrayImage,true,false,16,5,true);
         _loc7_.frame = param3;
         if(!param6)
         {
            _loc7_.visible = false;
         }
         add(_loc7_);
         _loc8_ = 0;
         while(_loc8_ < 5)
         {
            _loc7_ = new FlxSprite(param1 + 1 + _loc8_ * 3,param2 + 16);
            _loc7_.loadGraphic(PointImage,true,false,2,3,true);
            _loc7_.frame = param3;
            if(_loc8_ >= param5 || !param6)
            {
               _loc7_.visible = false;
            }
            add(_loc7_);
            this.points.push(_loc7_);
            _loc8_++;
         }
      }
      
      override public function create() : void
      {
         var _loc2_:FlxSprite = null;
         var _loc3_:FlxText = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:SkillDef = null;
         Global.Init();
         this.sky = new Sky(0);
         add(this.sky);
         Sounds.playSong(0);
         var _loc1_:FlxText = new FlxText(0,-2,320,"SKILLS");
         _loc1_.setFormat("volks",20,16777215,"center",1);
         add(_loc1_);
         _loc6_ = 0;
         while(_loc6_ < 4)
         {
            _loc2_ = new FlxSprite(0 + _loc6_ * 81 + int(_loc6_ > 1),26);
            _loc2_.loadGraphic(BackImage,true,false,76,130,true);
            _loc2_.frame = _loc6_;
            add(_loc2_);
            _loc6_++;
         }
         this.ptsLeft = new FlxText(0,10,320,"Points Left: " + Profile.skillPts.toString());
         this.ptsLeft.setFormat("volks",12,16777215,"left",1);
         add(this.ptsLeft);
         this.progress = new FlxText(0,156,76,"");
         this.progress.setFormat("volks",8,16777215,"center",1);
         add(this.progress);
         this.buttons = new Array();
         this.points = new Array();
         _loc4_ = 20;
         _loc5_ = 50;
         _loc6_ = 0;
         while(_loc6_ < this.skills.length)
         {
            _loc7_ = this.skills[_loc6_];
            this.SkillBox(7 + _loc7_.group * 81 + _loc7_.x * 23 + int(_loc7_.group > 1),33 + _loc7_.rank * 25,_loc7_.group,_loc7_.icon,Profile.skills[_loc7_.icon],this.SkillEnabled(_loc6_));
            _loc6_++;
         }
         _loc2_ = new FlxSprite(10,210);
         _loc2_.loadGraphic(TitleState.BtnImage,true,false,142,29,true);
         this.buttons.push(_loc2_);
         add(_loc2_);
         _loc3_ = new FlxText(10,212,136,"Reset Skills");
         _loc3_.setFormat("volks",16,16777215,"center",1);
         this.buttons.push(_loc3_);
         add(_loc3_);
         _loc2_ = new FlxSprite(320 - 10 - 142,210);
         _loc2_.loadGraphic(TitleState.BtnImage,true,false,142,29,true);
         this.buttons.push(_loc2_);
         add(_loc2_);
         _loc3_ = new FlxText(320 - 10 - 142,212,136,"Exit");
         _loc3_.setFormat("volks",16,16777215,"center",1);
         this.buttons.push(_loc3_);
         add(_loc3_);
         this.info = new FlxText(0,170,320,"");
         this.info.setFormat("volks",16,16777215,"center",1);
         add(this.info);
         this.info2 = new FlxText(0,185,320,"");
         this.info2.setFormat("volks",12,16777215,"center",1);
         add(this.info2);
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         add(this.volSpr);
         this.toolTip = new ToolTip();
         add(this.toolTip);
         FlxG.mouse.show();
      }
      
      public function SkillEnabled(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         return this.PointsNeeded(param1) <= 0;
      }
      
      public function PointsNeeded(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc2_ = 0;
         if((this.skills[param1].icon == SkillDef.LIGHTNINGROD || this.skills[param1].icon == SkillDef.CRIPPLER) && Profile.skills[SkillDef.SHOCKER] == 0)
         {
            return 999;
         }
         if((this.skills[param1].icon == SkillDef.ICELAUNCHER || this.skills[param1].icon == SkillDef.SLUSHEE) && Profile.skills[SkillDef.SNOWFORT] == 0)
         {
            return 999;
         }
         if((this.skills[param1].icon == SkillDef.CRUSHER || this.skills[param1].icon == SkillDef.QUAKE) && Profile.skills[SkillDef.ROLYPOLY] == 0)
         {
            return 999;
         }
         _loc3_ = 0;
         while(_loc3_ < this.skills.length)
         {
            if(this.skills[_loc3_].group == this.skills[param1].group && this.skills[_loc3_].rank < this.skills[param1].rank)
            {
               _loc2_ += Profile.skills[this.skills[_loc3_].icon];
            }
            _loc3_++;
         }
         return 3 * this.skills[param1].rank - _loc2_;
      }
      
      public function SkillUp(param1:int) : void
      {
         if(Profile.skills[param1] == null)
         {
            Profile.skills[param1] = 0;
         }
         if(Profile.skills[param1] == 5)
         {
            return;
         }
         if(Profile.skillPts > 0)
         {
            --Profile.skillPts;
            this.ptsLeft.text = "Points Left: " + Profile.skillPts.toString();
         }
         ++Profile.skills[param1];
         Profile.SaveGame();
         FlxG.switchState(new SkillState());
      }
      
      public function SkillDown(param1:int) : void
      {
         if(Profile.skills[param1] == null)
         {
            return;
         }
         if(Profile.skills[param1] == 0)
         {
            return;
         }
         if(param1 == SkillDef.ROCKTOWER && Profile.skills[param1] == 1)
         {
            return;
         }
         --Profile.skills[param1];
         var _loc2_:int = 0;
         while(_loc2_ < this.skills.length)
         {
            if(this.PointsNeeded(_loc2_) > 0 && Profile.skills[this.skills[_loc2_].icon] > 0)
            {
               ++Profile.skills[param1];
               return;
            }
            _loc2_++;
         }
         ++Profile.skillPts;
         Profile.SaveGame();
         FlxG.switchState(new SkillState());
      }
      
      public function TipForSkill(param1:int) : void
      {
         var _loc2_:Array = null;
         var _loc3_:* = 0;
         var _loc4_:int = 0;
         var _loc5_:int = this.PointsNeeded(param1);
         _loc2_ = new Array();
         var _loc6_:int = int(Profile.skills[this.skills[param1].icon]);
         _loc3_ = 0;
         _loc4_ = 16777028;
         if(_loc5_ > 0)
         {
            if(_loc5_ == 999)
            {
               if(this.skills[param1].icon == SkillDef.CRIPPLER || this.skills[param1].icon == SkillDef.LIGHTNINGROD)
               {
                  _loc2_[0] = "You need points in Shocker to get this!";
               }
               else if(this.skills[param1].icon == SkillDef.SLUSHEE || this.skills[param1].icon == SkillDef.ICELAUNCHER)
               {
                  _loc2_[0] = "You need points in Snow Fort to get this!";
               }
               else if(this.skills[param1].icon == SkillDef.CRUSHER || this.skills[param1].icon == SkillDef.QUAKE)
               {
                  _loc2_[0] = "You need points in Roly Poly to get this!";
               }
            }
            else
            {
               _loc2_[0] = "Spend " + _loc5_ + " more points to unlock this!";
            }
            _loc2_[1] = 16729156;
            _loc2_[2] = 8;
            _loc3_ = 3;
            _loc4_ = 16729156;
            this.canbuy = false;
         }
         if(_loc6_ > 0)
         {
            var _loc7_:Number;
            _loc2_[_loc7_ = _loc3_++] = this.skills[param1].Describe(_loc6_);
            var _loc8_:Number;
            _loc2_[_loc8_ = _loc3_++] = 16777215;
            var _loc9_:Number;
            _loc2_[_loc9_ = _loc3_++] = 8;
         }
         if(_loc6_ < 5)
         {
            _loc2_[_loc7_ = _loc3_++] = "Next Rank:";
            _loc2_[_loc8_ = _loc3_++] = 16777028;
            _loc2_[_loc9_ = _loc3_++] = 8;
            var _loc10_:Number;
            _loc2_[_loc10_ = _loc3_++] = this.skills[param1].Describe(_loc6_ + 1);
            var _loc11_:Number;
            _loc2_[_loc11_ = _loc3_++] = 16777028;
            var _loc12_:Number;
            _loc2_[_loc12_ = _loc3_++] = 8;
         }
         else
         {
            _loc4_ = 16777215;
         }
         while(_loc3_ < 5 * 3)
         {
            _loc2_[_loc7_ = _loc3_++] = "";
            _loc2_[_loc8_ = _loc3_++] = 0;
            _loc2_[_loc9_ = _loc3_++] = 8;
         }
         this.toolTip.SetAdvanced(ToolTip.ITEM,_loc4_,this.skills[param1].name + " (" + _loc6_ + "/5)",_loc2_[0],_loc2_[3],_loc2_[6],_loc2_[9],_loc2_[12],_loc2_[1],_loc2_[4],_loc2_[7],_loc2_[10],_loc2_[13],_loc2_[2],_loc2_[5],_loc2_[8],_loc2_[11],_loc2_[14]);
      }
      
      override public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
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
         _loc3_ = -1;
         this.canbuy = true;
         _loc1_ = 0;
         while(_loc1_ < this.skills.length)
         {
            if((this.buttons[_loc1_] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               _loc3_ = _loc1_;
               (this.buttons[_loc1_] as FlxSprite).frame = (this.buttons[_loc1_] as FlxSprite).frame % 5 + 5;
               this.TipForSkill(_loc1_);
            }
            else
            {
               (this.buttons[_loc1_] as FlxSprite).frame %= 5;
            }
            _loc1_++;
         }
         if((this.buttons[_loc1_] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            _loc3_ = 102;
            (this.buttons[_loc1_] as FlxSprite).frame = 1;
            (this.buttons[_loc1_ + 1] as FlxText).x = 12;
            (this.buttons[_loc1_ + 1] as FlxText).y = 210 + 4;
         }
         else
         {
            (this.buttons[_loc1_] as FlxSprite).frame = 0;
            (this.buttons[_loc1_ + 1] as FlxText).x = 10;
            (this.buttons[_loc1_ + 1] as FlxText).y = 210 + 2;
         }
         _loc1_ += 2;
         if((this.buttons[_loc1_] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            _loc3_ = 100;
            (this.buttons[_loc1_] as FlxSprite).frame = 1;
            (this.buttons[_loc1_ + 1] as FlxText).x = 320 - 142 - 10 + 2;
            (this.buttons[_loc1_ + 1] as FlxText).y = 210 + 4;
         }
         else
         {
            (this.buttons[_loc1_] as FlxSprite).frame = 0;
            (this.buttons[_loc1_ + 1] as FlxText).x = 320 - 142 - 10;
            (this.buttons[_loc1_ + 1] as FlxText).y = 210 + 2;
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            _loc3_ = 101;
            this.toolTip.Set(ToolTip.ITEM,16777215,"Sound & Music","Click to toggle sound","and music.");
         }
         if(_loc3_ == 100)
         {
            this.toolTip.Set(ToolTip.ITEM,16777215,"Exit","Return to the map screen!");
         }
         if(_loc3_ == 102)
         {
            this.toolTip.Set(ToolTip.ITEM,16777215,"Reset Skills","Wipe your choices and","choose a new plan!","Your points will be refunded.");
         }
         if(_loc3_ == -1)
         {
            this.toolTip.Clear();
         }
         super.update();
         if(FlxG.mouse.justPressed())
         {
            switch(_loc3_)
            {
               case 100:
                  FlxG.switchState(new MapState());
                  return;
               case 101:
                  FlxG.mute = !FlxG.mute;
                  break;
               case 102:
                  _loc1_ = 0;
                  while(_loc1_ < 50)
                  {
                     Profile.skillPts += Profile.skills[_loc1_];
                     Profile.skills[_loc1_] = 0;
                     _loc1_++;
                  }
                  --Profile.skillPts;
                  Profile.skills[SkillDef.ROCKTOWER] = 1;
                  Profile.SaveGame();
                  FlxG.switchState(new SkillState());
                  break;
               case -1:
                  break;
               default:
                  if(FlxG.keys.SHIFT)
                  {
                     this.SkillDown((this.skills[_loc3_] as SkillDef).icon);
                  }
                  else if(this.canbuy && Profile.skillPts > 0)
                  {
                     this.SkillUp((this.skills[_loc3_] as SkillDef).icon);
                  }
            }
         }
      }
   }
}

