package xplor
{
   import org.flixel.*;
   
   public class Hud extends FlxGroup
   {
      
      public static var HudBoxImage:Class = Hud_HudBoxImage;
      
      public static var HudSpeedImage:Class = Hud_HudSpeedImage;
      
      public static var BewareImage:Class = Hud_BewareImage;
      
      public var cash:FlxText;
      
      public var monsLife:MonsterLifeBar;
      
      public var waves:WaveDisplay;
      
      public var xpBar:FlxSprite;
      
      public var box:FlxSprite;
      
      public var speedSlider:FlxSprite;
      
      public var beware:FlxSprite;
      
      public var bewareText:Array;
      
      public function Hud()
      {
         var _loc1_:int = 0;
         var _loc2_:FlxSprite = null;
         var _loc3_:FlxText = null;
         super();
         this.waves = new WaveDisplay();
         add(this.waves);
         this.box = new FlxSprite(320 - 125,0,HudBoxImage);
         this.box.scrollFactor.x = 0;
         this.box.scrollFactor.y = 0;
         add(this.box);
         this.speedSlider = new FlxSprite(320 - 110,2,HudSpeedImage);
         this.speedSlider.scrollFactor.x = 0;
         this.speedSlider.scrollFactor.y = 0;
         add(this.speedSlider);
         this.cash = new FlxText(0,20,321,"$0");
         this.cash.setFormat("volks",16,16777215,"right",1);
         this.cash.scrollFactor.x = 0;
         this.cash.scrollFactor.y = 0;
         add(this.cash);
         this.monsLife = new MonsterLifeBar();
         add(this.monsLife);
         this.xpBar = new FlxSprite(320 - 125 + 18,29);
         this.xpBar.makeGraphic(57,4,4294967040,true);
         this.xpBar.origin.x = 0;
         this.xpBar.scale.x = Profile.xp / Profile.XPNeed();
         this.xpBar.scrollFactor.x = 0;
         this.xpBar.scrollFactor.y = 0;
         add(this.xpBar);
         this.beware = new FlxSprite();
         this.beware.loadGraphic(BewareImage,true,false,76,144,true);
         this.beware.visible = false;
         this.beware.scrollFactor.x = 0;
         this.beware.scrollFactor.y = 0;
         add(this.beware);
         this.bewareText = new Array();
         _loc3_ = new FlxText(160 - 80,120 - 144 / 2 + 144,160,"");
         _loc3_.setFormat("volks",12,16777215,"center",1);
         _loc3_.visible = false;
         _loc3_.scrollFactor.x = 0;
         _loc3_.scrollFactor.y = 0;
         add(_loc3_);
         this.bewareText.push(_loc3_);
         _loc3_ = new FlxText(160 - 80,120 - 144 / 2 + 144 + 13,80,"");
         _loc3_.setFormat("volks",12,16777215,"center",1);
         _loc3_.visible = false;
         _loc3_.scrollFactor.x = 0;
         _loc3_.scrollFactor.y = 0;
         add(_loc3_);
         this.bewareText.push(_loc3_);
         _loc3_ = new FlxText(160,120 - 144 / 2 + 144 + 13,80,"");
         _loc3_.setFormat("volks",12,16777215,"center",1);
         _loc3_.visible = false;
         _loc3_.scrollFactor.x = 0;
         _loc3_.scrollFactor.y = 0;
         add(_loc3_);
         this.bewareText.push(_loc3_);
         _loc3_ = new FlxText(160 - 80,120 - 144 / 2 + 144 + 26,160,"");
         _loc3_.setFormat("volks",12,16777215,"center",1);
         _loc3_.visible = false;
         _loc3_.scrollFactor.x = 0;
         _loc3_.scrollFactor.y = 0;
         add(_loc3_);
         this.bewareText.push(_loc3_);
      }
      
      public function SetBeware(param1:int, param2:int, param3:int) : void
      {
         this.beware.frame = param1;
         this.beware.visible = true;
         this.beware.x = 160 - 76 / 2;
         this.beware.y = 120 - 144 / 2;
         this.bewareText[0].visible = true;
         this.bewareText[1].visible = true;
         this.bewareText[2].visible = true;
         this.bewareText[3].visible = true;
         this.bewareText[0].text = "Number: " + param3;
         this.bewareText[1].text = "Life: " + WaveBlock.monsType[param1].Life(param2);
         this.bewareText[2].text = "Value: $" + WaveBlock.monsType[param1].Money(param2);
         if(param1 == 3 || param1 == 4 || param1 == 6 || param1 == 8)
         {
            this.bewareText[3].text = "Can be disabled!";
         }
         else
         {
            this.bewareText[3].text = "";
         }
      }
      
      public function HideBeware() : void
      {
         this.beware.visible = false;
         this.bewareText[0].visible = false;
         this.bewareText[1].visible = false;
         this.bewareText[2].visible = false;
         this.bewareText[3].visible = false;
      }
      
      public function SetXP() : void
      {
         this.xpBar.scale.x = Profile.xp / Profile.XPNeed();
      }
      
      public function SetCash() : void
      {
         this.cash.text = "$" + Global.player.money.toString();
      }
      
      public function Update() : void
      {
         this.speedSlider.x = 320 - 110 + FlxG.timeScale * (60 / 4);
         if(this.speedSlider.x < 320 - 110)
         {
            this.speedSlider.x = 320 - 110;
         }
         if(this.speedSlider.x > 320 - 110 + 60)
         {
            this.speedSlider.x = 320 - 110 + 60;
         }
      }
      
      public function Click() : Boolean
      {
         if(this.speedSlider.overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            return true;
         }
         return false;
      }
      
      public function SlideSpeed() : Boolean
      {
         if(!FlxG.mouse.pressed())
         {
            return false;
         }
         var _loc1_:Number = int((FlxG.mouse.screenX - (320 - 110)) / 5) * 5;
         if(_loc1_ < 0)
         {
            _loc1_ = 0;
         }
         if(_loc1_ > 60)
         {
            _loc1_ = 60;
         }
         this.speedSlider.x = 320 - 110 + _loc1_;
         FlxG.timeScale = _loc1_ / (60 / 4);
         return true;
      }
   }
}

