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
      
      public static var skills:Array = new Array(new SkillDef("Fists Of Fury",0,0,0,SkillDef.FISTOFFURY),new SkillDef("Pedro Punch",0,0,1,SkillDef.PEDROPUNCH),new SkillDef("Recovery",0,0,2,SkillDef.RECOVERY),new SkillDef("Burro Bash",0,1,0,SkillDef.BURROBASH),new SkillDef("Gale Fist",0,1,1,SkillDef.GALEFIST),new SkillDef("Mighty Grab",0,1,2,SkillDef.MIGHTYGRAB),new SkillDef("Pedroken",0,2,0,SkillDef.PEDROKEN),new SkillDef("Piledriver",0,2,1,SkillDef.PILEDRIVER),new SkillDef("Coconut Bonk",0,2,2,SkillDef.COCONUTBONK),new SkillDef("Fists Of Flame",0,3,0,SkillDef.FISTSOFFLAME),new SkillDef("Atomic Piledriver",0,3,1,SkillDef.ATOMICPILEDRIVER),new SkillDef("Pressure Points",0,3,2,SkillDef.PRESSUREPOINTS),new SkillDef("Iron Fist",0,4,0,SkillDef.IRONFIST),new SkillDef("Strongarm",0,4,1,SkillDef.STRONGARM),new SkillDef("Lightning Fist",0,4,2,SkillDef.LIGHTNINGFIST),new SkillDef("Feet Of Fury",1,0,0,SkillDef.FEETOFFURY),new SkillDef("Flying Kick",1,0,1,SkillDef.FLYINGKICK),new SkillDef("Dodge",1,0,2,SkillDef
      .DODGE),new SkillDef("Dive Kick",1,1,0,SkillDef.DIVEKICK),new SkillDef("Fancy Footwork",1,1,1,SkillDef.FANCYFOOTWORK),new SkillDef("Dragon Kick",1,1,2,SkillDef.CHARGEKICK),new SkillDef("KO Kick",1,2,0,SkillDef.KOKICK),new SkillDef("Power Kick",1,2,1,SkillDef.POWERKICK),new SkillDef("Retaliate",1,2,2,SkillDef.RETALIATE),new SkillDef("Tornado Kick",1,3,0,SkillDef.TORNADOKICK),new SkillDef("Lead Foot",1,3,1,SkillDef.LEADFOOT),new SkillDef("Raging Burro",1,3,2,SkillDef.RAGINGBURRO),new SkillDef("Whirlwind",1,4,0,SkillDef.WHIRLWIND),new SkillDef("Steel Toes",1,4,1,SkillDef.STEELTOES),new SkillDef("Combo Bombo",1,4,2,SkillDef.COMBOBOMBO),new SkillDef("Furious Blast",2,0,0,SkillDef.FURIOUSBLAST),new SkillDef("Inner Fury",2,0,1,SkillDef.INNERFURY),new SkillDef("Furious Roar",2,0,2,SkillDef.FURIOUSROAR),new SkillDef("Furious Fix",2,1,0,SkillDef.FURIOUSFIX),new SkillDef("Furious Shield",2,1,1,SkillDef.FURIOUSSHIELD),new SkillDef("Furious Blood",2,1,2,SkillDef.FURIOUSBLOOD),new SkillDef("Furious Freeze"
      ,2,2,0,SkillDef.FURIOUSFREEZE),new SkillDef("Deep Freeze",2,2,1,SkillDef.DEEPFREEZE),new SkillDef("Heart of Fury",2,2,2,SkillDef.HEARTOFFURY),new SkillDef("Furious Frenzy",2,3,0,SkillDef.FURIOUSFRENZY),new SkillDef("Burning Fury",2,3,1,SkillDef.BURNINGFURY),new SkillDef("Fury Overload",2,3,2,SkillDef.FURYOVERLOAD),new SkillDef("Crushing Blow",2,4,0,SkillDef.CRUSHINGBLOW),new SkillDef("Maximum Force",2,4,1,SkillDef.MAXIMUMFORCE),new SkillDef("Master Of Fury",2,4,2,SkillDef.FURYMASTER));
      
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
      
      public function SkillBox(x:int, y:int, group:int, icon:int, pts:int, able:int) : void
      {
         var s:FlxSprite = null;
         s = new FlxSprite(x - 3,y - 3);
         s.loadGraphic(FrameImage,true,false,22,22,true);
         s.frame = 0;
         if(able < 1)
         {
            s.visible = false;
         }
         add(s);
         this.buttons.push(s);
         s = new FlxSprite(x,y);
         s.loadGraphic(IconImage,true,false,16,16,true);
         s.frame = group;
         if(able == 0)
         {
            s.frame += 3;
         }
         else if(able == -1)
         {
            s.frame = 6;
         }
         add(s);
         s = new FlxSprite(x,y + 15);
         s.loadGraphic(TrayImage,true,false,16,5,true);
         if(able < 1)
         {
            s.visible = false;
         }
         add(s);
         for(var i:int = 0; i < 5; i++)
         {
            s = new FlxSprite(x + 1 + i * 3,y + 16);
            s.loadGraphic(PointImage,true,false,2,3,true);
            if(i >= pts || able < 1)
            {
               s.visible = false;
            }
            add(s);
            this.points.push(s);
         }
      }
      
      override public function create() : void
      {
         var s:FlxSprite = null;
         var t:FlxText = null;
         var tx:int = 0;
         var ty:int = 0;
         var i:int = 0;
         var sk:SkillDef = null;
         Global.Init();
         this.sky = new Sky(0);
         add(this.sky);
         Sounds.playSong(0);
         var title:FlxText = new FlxText(0,-2,320,"SKILLS");
         title.setFormat("volks",20,16777215,"center",1);
         add(title);
         for(i = 0; i < 3; i++)
         {
            s = new FlxSprite(11 + i * (92 + 11),26);
            s.loadGraphic(BackImage,false,false,92,139,true);
            add(s);
         }
         this.ptsLeft = new FlxText(0,10,320,"Points Left: " + Profile.skillPts.toString());
         this.ptsLeft.setFormat("volks",12,16777215,"left",1);
         add(this.ptsLeft);
         this.progress = new FlxText(0,156,76,"");
         this.progress.setFormat("volks",8,16777215,"center",1);
         add(this.progress);
         this.buttons = new Array();
         this.points = new Array();
         tx = 20;
         ty = 50;
         for(i = 0; i < skills.length; i++)
         {
            sk = skills[i];
            this.SkillBox(11 + 16 + sk.group * (92 + 11) + sk.x * 23 + int(sk.group > 1) + int(sk.rank > 0 && sk.rank < 4) - int(sk.rank == 4),36 + sk.rank * 23,sk.group,sk.icon,Profile.skills[sk.icon],this.SkillEnabled(i));
         }
         s = new FlxSprite(10,210);
         s.loadGraphic(TitleState.BtnImage,true,false,142,29,true);
         this.buttons.push(s);
         add(s);
         t = new FlxText(10,212,136,"Reset Skills");
         t.setFormat("volks",16,16777215,"center",1);
         this.buttons.push(t);
         add(t);
         s = new FlxSprite(320 - 10 - 142,210);
         s.loadGraphic(TitleState.BtnImage,true,false,142,29,true);
         this.buttons.push(s);
         add(s);
         t = new FlxText(320 - 10 - 142,212,136,"Exit");
         t.setFormat("volks",16,16777215,"center",1);
         this.buttons.push(t);
         add(t);
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
      }
      
      public function SkillEnabled(which:int) : int
      {
         var n:int = 0;
         var i:int = 0;
         if(Profile.skillHave[which] == 0)
         {
            return -1;
         }
         if(this.PointsNeeded(which) <= 0)
         {
            return 1;
         }
         return 0;
      }
      
      public function PointsNeeded(which:int) : int
      {
         var n:int = 0;
         var i:int = 0;
         n = 0;
         for(i = 0; i < skills.length; i++)
         {
            if(skills[i].group == skills[which].group && skills[i].rank < skills[which].rank)
            {
               n += Profile.skills[skills[i].icon];
            }
         }
         return 3 * skills[which].rank - n;
      }
      
      public function SkillUp(n:int) : void
      {
         if(Profile.skills[n] == null)
         {
            Profile.skills[n] = 0;
         }
         if(Profile.skills[n] == 5)
         {
            return;
         }
         if(Profile.skillPts > 0)
         {
            --Profile.skillPts;
            this.ptsLeft.text = "Points Left: " + Profile.skillPts.toString();
         }
         ++Profile.skills[n];
         Profile.SaveGame();
         FlxG.switchState(new SkillState());
      }
      
      public function SkillDown(n:int) : void
      {
         if(Profile.skills[n] == null)
         {
            return;
         }
         if(Profile.skills[n] == 0)
         {
            return;
         }
         --Profile.skills[n];
         for(var i:int = 0; i < skills.length; i++)
         {
            if(this.PointsNeeded(i) > 0 && Profile.skills[skills[i].icon] > 0)
            {
               ++Profile.skills[n];
               return;
            }
         }
         ++Profile.skillPts;
         Profile.SaveGame();
         FlxG.switchState(new SkillState());
      }
      
      public function TipForSkill(w:int) : void
      {
         var s:Array = null;
         var i:int = 0;
         var headCol:int = 0;
         var ptsNeed:int = this.PointsNeeded(w);
         s = new Array();
         var pts:int = int(Profile.skills[skills[w].icon]);
         i = 0;
         headCol = 16777028;
         if(ptsNeed > 0)
         {
            s[0] = "Spend " + ptsNeed + " more points to unlock this!";
            s[1] = 16729156;
            s[2] = 8;
            i = 3;
            headCol = 16729156;
            this.canbuy = false;
         }
         if(pts > 0)
         {
            s[i++] = skills[w].Describe(pts);
            s[i++] = 16777215;
            s[i++] = 8;
         }
         if(pts < 5)
         {
            s[i++] = "Next Rank:";
            s[i++] = 16777028;
            s[i++] = 8;
            s[i++] = skills[w].Describe(pts + 1);
            s[i++] = 16777028;
            s[i++] = 8;
         }
         else
         {
            headCol = 16777215;
         }
         while(i < 5 * 3)
         {
            s[i++] = "";
            s[i++] = 0;
            s[i++] = 8;
         }
         this.toolTip.SetAdvanced(ToolTip.ITEM,headCol,skills[w].name + " (" + pts + "/5)",s[0],s[3],s[6],s[9],s[12],s[1],s[4],s[7],s[10],s[13],s[2],s[5],s[8],s[11],s[14]);
      }
      
      override public function update() : void
      {
         var i:int = 0;
         var p:int = 0;
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
         this.canbuy = true;
         for(i = 0; i < skills.length; i++)
         {
            if((this.buttons[i] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               p = this.SkillEnabled(i);
               if(p >= 0)
               {
                  cursor = i;
                  this.TipForSkill(i);
               }
               if(p == 1)
               {
                  (this.buttons[i] as FlxSprite).frame = 1;
               }
            }
            else if(this.SkillEnabled(i) == 1)
            {
               (this.buttons[i] as FlxSprite).frame = 0;
            }
         }
         if((this.buttons[i] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            cursor = 102;
            (this.buttons[i] as FlxSprite).frame = 1;
            (this.buttons[i + 1] as FlxText).x = 12;
            (this.buttons[i + 1] as FlxText).y = 210 + 4;
         }
         else
         {
            (this.buttons[i] as FlxSprite).frame = 0;
            (this.buttons[i + 1] as FlxText).x = 10;
            (this.buttons[i + 1] as FlxText).y = 210 + 2;
         }
         i += 2;
         if((this.buttons[i] as FlxSprite).overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            cursor = 100;
            (this.buttons[i] as FlxSprite).frame = 1;
            (this.buttons[i + 1] as FlxText).x = 320 - 142 - 10 + 2;
            (this.buttons[i + 1] as FlxText).y = 210 + 4;
         }
         else
         {
            (this.buttons[i] as FlxSprite).frame = 0;
            (this.buttons[i + 1] as FlxText).x = 320 - 142 - 10;
            (this.buttons[i + 1] as FlxText).y = 210 + 2;
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            cursor = 101;
            this.toolTip.Set(ToolTip.ITEM,16777215,"Sound & Music","Click to toggle sound","and music.");
         }
         if(cursor == 100)
         {
            this.toolTip.Set(ToolTip.ITEM,16777215,"Back","Return to the map screen!");
         }
         if(cursor == 102)
         {
            this.toolTip.Set(ToolTip.ITEM,16777215,"Reset Skills","Wipe your choices and","choose a new plan!","Your points will be refunded.");
         }
         if(cursor == -1)
         {
            this.toolTip.Clear();
         }
         super.update();
         if(FlxG.mouse.justPressed())
         {
            switch(cursor)
            {
               case 100:
                  FlxG.switchState(new MapState());
                  return;
               case 101:
                  FlxG.mute = !FlxG.mute;
                  break;
               case 102:
                  for(i = 0; i < 50; i++)
                  {
                     Profile.skillPts += Profile.skills[i];
                     Profile.skills[i] = 0;
                  }
                  Profile.SaveGame();
                  FlxG.switchState(new SkillState());
                  break;
               case -1:
                  break;
               default:
                  if(FlxG.keys.SHIFT)
                  {
                     this.SkillDown((skills[cursor] as SkillDef).icon);
                  }
                  else if(this.canbuy && Profile.skillPts > 0)
                  {
                     this.SkillUp((skills[cursor] as SkillDef).icon);
                  }
            }
         }
      }
   }
}

