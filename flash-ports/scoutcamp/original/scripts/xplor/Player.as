package xplor
{
   import org.flixel.*;
   import xplor.Bullet.Boom;
   import xplor.Menus.SkillDef;
   import xplor.Menus.ToolTip;
   import xplor.Monster.*;
   
   public class Player
   {
      
      public static var BoxImage:Class = Player_BoxImage;
      
      public static var CursorImage:Class = Player_CursorImage;
      
      public static var SelectImage:Class = Player_SelectImage;
      
      public static var RangeImage:Class = Player_RangeImage;
      
      public static const RADIUS_BITS:int = 24;
      
      public static const CANTPLACE:int = 0;
      
      public static const CANPLACE:int = 1;
      
      public static const CANUPGRADE:int = 2;
      
      public static const SELECTED:int = 3;
      
      public static const CANFOCUS:int = 4;
      
      public static const FOCUSMONSTER:int = 5;
      
      public static const BUILD:int = 6;
      
      public static const SENDWAVE:int = 7;
      
      public static const ONHUD:int = 8;
      
      public static const SLIDESPEED:int = 9;
      
      public static const PAUSE:int = 10;
      
      public var money:int;
      
      public var box:FlxSprite;
      
      public var boxX:int;
      
      public var boxY:int;
      
      public var target:BaseGuy;
      
      public var boxMode:int;
      
      public var cursor:FlxSprite;
      
      public var selects:FlxGroup;
      
      public var on:int;
      
      public var range:FlxSprite;
      
      public var toolTip:ToolTip;
      
      public var upcost1:Number;
      
      public var upcost2:Number;
      
      public var enabledButton:Array;
      
      public var prevTimeScale:Number;
      
      public var buildSkill:Array = new Array(SkillDef.ROCKTOWER,SkillDef.ROLYPOLY,SkillDef.SNOWFORT,SkillDef.SHOCKER);
      
      public var buildCost:Array = new Array(Tower_Rock.BasePrice(),Tower_Roll.BasePrice(),Tower_Snow.BasePrice(),Tower_Shock.BasePrice());
      
      public function Player()
      {
         var _loc1_:int = 0;
         var _loc2_:FlxSprite = null;
         super();
         this.prevTimeScale = 1;
         this.money = (120 + Global.levelNum * 20) * (1 + Profile.skills[SkillDef.BIGBUCKS] * 0.1);
         this.boxMode = CANTPLACE;
         this.cursor = new FlxSprite();
         this.cursor.loadGraphic(CursorImage,true,false,16,16,true);
         this.cursor.offset.x = 1;
         this.cursor.offset.y = 1;
         this.selects = new FlxGroup();
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            _loc2_ = new FlxSprite();
            _loc2_.loadGraphic(SelectImage,true,false,18,18,true);
            this.selects.add(_loc2_);
            _loc1_++;
         }
         this.range = new FlxSprite();
         this.range.blend = "add";
         this.range.loadGraphic(RangeImage,false,false,256,256,true);
         this.range.visible = false;
         this.toolTip = new ToolTip();
         this.enabledButton = new Array(0,0,0,0);
      }
      
      public function Str(param1:Number) : String
      {
         param1 = int(param1 * 100) / 100;
         return param1.toString();
      }
      
      public function AddBox() : void
      {
         this.box = new FlxSprite();
         this.box.loadGraphic(BoxImage,true,false,24,24,true);
         PlayState(FlxG.state).add(this.range);
         PlayState(FlxG.state).add(this.box);
         PlayState(FlxG.state).add(this.selects);
         this.selects.visible = false;
      }
      
      public function AddCursor() : void
      {
         PlayState(FlxG.state).add(this.toolTip);
         PlayState(FlxG.state).add(this.cursor);
         FlxG.mouse.hide();
      }
      
      public function ValidTowerPlace(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         if(param2 == Global.campfire.ty && param1 >= Global.campfire.tx - 1 && param1 <= Global.campfire.tx + 1)
         {
            return false;
         }
         if(param1 > 1 && param1 < Global.level.width - 2 && param2 > 1 && param2 < Global.level.height - 1 && Global.level.GetLayer(Level.LAYER_SOLID).getTile(param1,param2) == 0)
         {
            _loc3_ = int(Global.level.GetLayer(Level.LAYER_SOLID).getTile(param1,param2 + 1));
            if(Boolean(_loc3_) && !(Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt).isSlope[_loc3_])
            {
               _loc3_ = int(Global.level.GetLayer(Level.LAYER_BACK).getTile(param1,param2));
               if(_loc3_ >= 28 && _loc3_ <= 32)
               {
                  return false;
               }
               _loc3_ = int(Global.level.GetLayer(Level.LAYER_DECOR).getTile(param1,param2));
               if(_loc3_ == 0)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function PlaceTower() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Class = null;
         var _loc4_:int = 0;
         switch(this.on)
         {
            case 0:
               _loc4_ = Tower_Rock.BasePrice();
               _loc3_ = Tower_Rock;
               break;
            case 1:
               _loc4_ = Tower_Roll.BasePrice();
               _loc3_ = Tower_Roll;
               if(Profile.skills[SkillDef.ROLYPOLY] == 0)
               {
                  return;
               }
               break;
            case 2:
               _loc4_ = Tower_Snow.BasePrice();
               _loc3_ = Tower_Snow;
               if(Profile.skills[SkillDef.SNOWFORT] == 0)
               {
                  return;
               }
               break;
            case 3:
               _loc4_ = Tower_Shock.BasePrice();
               _loc3_ = Tower_Shock;
               if(Profile.skills[SkillDef.SHOCKER] == 0)
               {
                  return;
               }
         }
         if(this.money < _loc4_)
         {
            return;
         }
         if(this.ValidTowerPlace(this.boxX,this.boxY))
         {
            Sounds.play(Sounds.BuildSnd);
            this.money -= _loc4_;
            PlayState(FlxG.state).hud.SetCash();
            Global.badguys.AddGuy(_loc3_,Badguys.TOWERS,this.boxX,this.boxY);
            this.boxMode = CANTPLACE;
            this.selects.visible = false;
         }
      }
      
      public function SetMode(param1:int, param2:int) : void
      {
         if(this.boxMode != SELECTED && this.boxMode != FOCUSMONSTER && this.boxMode != BUILD && this.boxMode != ONHUD && this.boxMode != SLIDESPEED)
         {
            this.boxMode = param1;
            switch(param1)
            {
               case SENDWAVE:
                  this.cursor.frame = 4;
                  this.on = param2;
                  break;
               case CANTPLACE:
                  this.cursor.frame = 0;
            }
         }
      }
      
      public function BuildRadius() : void
      {
         this.range.scale.x = (this.target as Tower).range / 128;
         this.range.scale.y = this.range.scale.x;
         this.range.x = this.target.x + this.target.width / 2 - 128;
         this.range.y = this.target.y + this.target.height / 2 - 128;
         this.range.visible = true;
      }
      
      public function BuildPotentialRadius(param1:Number) : void
      {
         this.range.scale.x = param1 / 128;
         this.range.scale.y = this.range.scale.x;
         this.range.x = this.box.x + this.box.width / 2 - 128;
         this.range.y = this.box.y + this.box.height / 2 - 128;
         this.range.visible = true;
      }
      
      public function HideRadius() : void
      {
         this.range.visible = false;
      }
      
      public function SelectMoneyAdjust() : void
      {
         var _loc1_:int = 0;
         var _loc2_:FlxSprite = null;
         var _loc3_:int = 0;
         for each(_loc2_ in this.selects.members)
         {
            if(this.boxMode == BUILD)
            {
               if(this.money < this.buildCost[_loc1_] || !this.enabledButton[_loc1_])
               {
                  _loc2_.alpha = 0.5;
               }
               else
               {
                  _loc2_.alpha = 1;
               }
            }
            else
            {
               _loc2_.alpha = 1;
               if(_loc1_ == 0)
               {
                  if(this.money < this.upcost1 || !this.enabledButton[_loc1_])
                  {
                     _loc2_.alpha = 0.5;
                  }
               }
               if(_loc1_ == 1)
               {
                  if(this.money < this.upcost2 || !this.enabledButton[_loc1_])
                  {
                     _loc2_.alpha = 0.5;
                  }
               }
               if(_loc1_ == 2)
               {
                  _loc3_ = (this.target as Tower).UpgradePrice2((this.target as Tower).level) * (1 - Profile.skills[SkillDef.ENHANCEMENT] * 0.03);
                  if((this.target as Tower).level == 5 || this.money < _loc3_)
                  {
                     _loc2_.alpha = 0.5;
                  }
               }
            }
            _loc1_++;
         }
      }
      
      public function SetupSelect() : void
      {
         var _loc3_:int = 0;
         var _loc4_:FlxSprite = null;
         var _loc1_:Array = new Array(-17,23,-17,23);
         var _loc2_:Array = new Array(-17,-17,23,23);
         _loc3_ = 0;
         this.selects.visible = true;
         for each(_loc4_ in this.selects.members)
         {
            _loc4_.x = this.box.x + _loc1_[_loc3_];
            _loc4_.y = this.box.y + _loc2_[_loc3_];
            if(this.boxMode == BUILD)
            {
               _loc4_.frame = 12 + _loc3_;
               this.enabledButton[_loc3_] = 1;
               if(Profile.skills[this.buildSkill[_loc3_]] == 0)
               {
                  _loc4_.frame = 11;
                  this.enabledButton[_loc3_] = 0;
                  _loc4_.alpha = 0.5;
               }
            }
            else
            {
               this.enabledButton[_loc3_] = 1;
               if(_loc3_ == 0)
               {
                  if(this.target is Tower_Rock && Boolean(Profile.skills[SkillDef.SLINGSHOT]))
                  {
                     _loc4_.frame = 3;
                     this.upcost1 = Tower_Sling.BasePrice();
                  }
                  else if(this.target is Tower_Snow && Boolean(Profile.skills[SkillDef.ICELAUNCHER]))
                  {
                     _loc4_.frame = 7;
                     this.upcost1 = Tower_Ice.BasePrice();
                  }
                  else if(this.target is Tower_Roll && Boolean(Profile.skills[SkillDef.CRUSHER]))
                  {
                     _loc4_.frame = 5;
                     this.upcost1 = Tower_Crusher.BasePrice();
                  }
                  else if(this.target is Tower_Shock && Boolean(Profile.skills[SkillDef.CRIPPLER]))
                  {
                     _loc4_.frame = 9;
                     this.upcost1 = Tower_Crippler.BasePrice();
                  }
                  else
                  {
                     this.enabledButton[_loc3_] = 0;
                     _loc4_.alpha = 0.5;
                     _loc4_.frame = 0;
                  }
               }
               else if(_loc3_ == 1)
               {
                  if(this.target is Tower_Rock && Boolean(Profile.skills[SkillDef.SOAPBOX]))
                  {
                     _loc4_.frame = 4;
                     this.upcost2 = Tower_Soapbox.BasePrice();
                  }
                  else if(this.target is Tower_Snow && Boolean(Profile.skills[SkillDef.SLUSHEE]))
                  {
                     _loc4_.frame = 8;
                     this.upcost2 = Tower_Slushee.BasePrice();
                  }
                  else if(this.target is Tower_Roll && Boolean(Profile.skills[SkillDef.QUAKE]))
                  {
                     _loc4_.frame = 6;
                     this.upcost2 = Tower_Quake.BasePrice();
                  }
                  else if(this.target is Tower_Shock && Boolean(Profile.skills[SkillDef.LIGHTNINGROD]))
                  {
                     _loc4_.frame = 10;
                     this.upcost2 = Tower_LightningRod.BasePrice();
                  }
                  else
                  {
                     this.enabledButton[_loc3_] = 0;
                     _loc4_.alpha = 0.5;
                     _loc4_.frame = 0;
                  }
               }
               else if(_loc3_ == 2)
               {
                  _loc4_.frame = 2;
               }
               else
               {
                  _loc4_.frame = 1;
               }
            }
            _loc3_++;
         }
         this.SelectMoneyAdjust();
         if(this.boxMode == SELECTED)
         {
            this.BuildRadius();
         }
      }
      
      public function UpgradeTower() : void
      {
         if((this.target as Tower).level == 5)
         {
            return;
         }
         var _loc1_:int = (this.target as Tower).UpgradePrice2((this.target as Tower).level) * (1 - Profile.skills[SkillDef.ENHANCEMENT] * 0.03);
         if(this.money < _loc1_)
         {
            return;
         }
         Sounds.play(Sounds.UpgradeSnd);
         this.money -= _loc1_;
         PlayState(FlxG.state).hud.SetCash();
         (this.target as Tower).Upgrade();
      }
      
      public function UpdateSelect() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:FlxSprite = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc1_:FlxPoint = new FlxPoint(FlxG.mouse.x,FlxG.mouse.y);
         this.on = -1;
         _loc2_ = 0;
         if(this.boxMode == SELECTED)
         {
            _loc6_ = (this.target as Tower).range / 128;
            if(this.range.scale.x < _loc6_)
            {
               this.range.scale.x += FlxG.elapsed * 2;
            }
            if(this.range.scale.x > _loc6_)
            {
               this.range.scale.x = _loc6_;
            }
            this.range.scale.y = this.range.scale.x;
         }
         for each(_loc5_ in this.selects.members)
         {
            if(_loc5_.overlapsPoint(_loc1_) && Boolean(this.enabledButton[_loc2_]))
            {
               this.on = _loc2_;
               _loc5_.frame = _loc5_.frame % 16 + 16;
            }
            else
            {
               _loc5_.frame %= 16;
            }
            _loc2_++;
         }
         if(this.boxMode == BUILD)
         {
            if(this.on != -1 && Profile.skills[this.buildSkill[this.on]] == 0)
            {
               this.HideRadius();
               this.toolTip.Clear();
            }
            else
            {
               switch(this.on)
               {
                  case 0:
                     this.BuildPotentialRadius(Tower_Rock.RangeCalc(0));
                     if(this.money < Tower_Rock.BasePrice())
                     {
                        _loc4_ = 16724787;
                     }
                     else
                     {
                        _loc4_ = 16777215;
                     }
                     this.toolTip.Set(ToolTip.ITEM,_loc4_,"Rock Tower - $" + Tower_Rock.BasePrice().toString(),"Tosses rocks!","Damage: " + this.Str(Tower_Rock.DamageCalc(0)),"Rate: " + this.Str(Tower_Rock.RateCalc(0)),"Range: " + this.Str(Tower_Rock.RangeCalc(0)));
                     break;
                  case 1:
                     this.BuildPotentialRadius(Tower_Roll.RangeCalc(0));
                     if(this.money < Tower_Roll.BasePrice())
                     {
                        _loc4_ = 16724787;
                     }
                     else
                     {
                        _loc4_ = 16777215;
                     }
                     this.toolTip.Set(ToolTip.ITEM,_loc4_,"Roly Poly - $" + Tower_Roll.BasePrice().toString(),"Rolls boulders!","Damage: " + this.Str(Tower_Roll.DamageCalc(0)),"Distance: " + this.Str(Tower_Roll.SecondCalc(0)),"Rate: " + this.Str(Tower_Roll.RateCalc(0)),"Range: " + this.Str(Tower_Roll.RangeCalc(0)));
                     break;
                  case 2:
                     this.BuildPotentialRadius(Tower_Snow.RangeCalc(0));
                     if(this.money < Tower_Snow.BasePrice())
                     {
                        _loc4_ = 16724787;
                     }
                     else
                     {
                        _loc4_ = 16777215;
                     }
                     this.toolTip.Set(ToolTip.ITEM,_loc4_,"Snow Fort - $" + Tower_Snow.BasePrice().toString(),"Snowballs slow enemies!","Slow: " + this.Str(Tower_Snow.DamageCalc(0) * 100) + "%","Time: " + this.Str(Tower_Snow.SecondCalc(0)) + "s","Rate: " + this.Str(Tower_Snow.RateCalc(0)),"Range: " + this.Str(Tower_Snow.RangeCalc(0)));
                     break;
                  case 3:
                     this.BuildPotentialRadius(Tower_Shock.RangeCalc(0));
                     if(this.money < Tower_Shock.BasePrice())
                     {
                        _loc4_ = 16724787;
                     }
                     else
                     {
                        _loc4_ = 16777215;
                     }
                     this.toolTip.Set(ToolTip.ITEM,_loc4_,"Shock Tower - $" + Tower_Shock.BasePrice().toString(),"Electrocutes aliens!","Damage: " + this.Str(Tower_Shock.DamageCalc(0)),"Zap Time: " + this.Str(Profile.skills[SkillDef.SHOCKER] + 5).toString() + "s","Rate: " + this.Str(Tower_Shock.RateCalc(0)),"Range: " + this.Str(Tower_Shock.RangeCalc(0)));
                     break;
                  case -1:
                     this.HideRadius();
                     this.toolTip.Clear();
               }
            }
         }
         else
         {
            switch(this.on)
            {
               case 0:
                  if(this.target is Tower_Rock)
                  {
                     if(Profile.skills[SkillDef.SLINGSHOT] == 0)
                     {
                        this.on = -1;
                        this.toolTip.Clear();
                     }
                     else
                     {
                        this.BuildPotentialRadius(Tower_Sling.RangeCalc((this.target as Tower).level));
                        if(this.money < Tower_Sling.BasePrice())
                        {
                           _loc4_ = 16724787;
                        }
                        else
                        {
                           _loc4_ = 16777215;
                        }
                        this.toolTip.Set(ToolTip.ITEM,_loc4_,"Slingshot - $" + Tower_Sling.BasePrice().toString(),"Extreme range, shoots through walls!","Damage: " + this.Str(Tower_Sling.DamageCalc((this.target as Tower).level)),"Rate: " + this.Str(Tower_Sling.RateCalc((this.target as Tower).level)),"Range: " + this.Str(Tower_Sling.RangeCalc((this.target as Tower).level)),"");
                     }
                  }
                  else if(this.target is Tower_Snow)
                  {
                     if(Profile.skills[SkillDef.ICELAUNCHER] == 0)
                     {
                        this.on = -1;
                        this.toolTip.Clear();
                     }
                     else
                     {
                        this.BuildPotentialRadius(Tower_Ice.RangeCalc((this.target as Tower).level));
                        if(this.money < Tower_Ice.BasePrice())
                        {
                           _loc4_ = 16724787;
                        }
                        else
                        {
                           _loc4_ = 16777215;
                        }
                        this.toolTip.Set(ToolTip.ITEM,_loc4_,"Ice Launcher - $" + Tower_Ice.BasePrice().toString(),"Freezes aliens solid!","Damage: " + this.Str(Tower_Ice.DamageCalc((this.target as Tower).level)),"Freeze: " + this.Str(Tower_Ice.SecondCalc((this.target as Tower).level)) + "s","Rate: " + this.Str(Tower_Ice.RateCalc((this.target as Tower).level)),"Range: " + this.Str(Tower_Ice.RangeCalc((this.target as Tower).level)));
                     }
                  }
                  else if(this.target is Tower_Shock)
                  {
                     if(Profile.skills[SkillDef.CRIPPLER] == 0)
                     {
                        this.on = -1;
                        this.toolTip.Clear();
                     }
                     else
                     {
                        this.BuildPotentialRadius(Tower_Crippler.RangeCalc((this.target as Tower).level));
                        if(this.money < Tower_Crippler.BasePrice())
                        {
                           _loc4_ = 16724787;
                        }
                        else
                        {
                           _loc4_ = 16777215;
                        }
                        this.toolTip.Set(ToolTip.ITEM,_loc4_,"Crippler - $" + Tower_Crippler.BasePrice().toString(),"Makes an alien more vulnerable!","Also disables abilites.","Damage Bonus: " + this.Str(Tower_Crippler.DamageCalc((this.target as Tower).level)) + "%","Range: " + this.Str(Tower_Crippler.RangeCalc((this.target as Tower).level)));
                     }
                  }
                  else if(this.target is Tower_Roll)
                  {
                     if(Profile.skills[SkillDef.CRUSHER] == 0)
                     {
                        this.on = -1;
                        this.toolTip.Clear();
                     }
                     else
                     {
                        this.BuildPotentialRadius(1);
                        if(this.money < Tower_Crusher.BasePrice())
                        {
                           _loc4_ = 16724787;
                        }
                        else
                        {
                           _loc4_ = 16777215;
                        }
                        this.toolTip.Set(ToolTip.ITEM,_loc4_,"Crusher - $" + Tower_Crusher.BasePrice().toString(),"Drops boulders on aliens below!","Damage: " + this.Str(Tower_Crusher.DamageCalc((this.target as Tower).level)),"Rate: " + this.Str(Tower_Crusher.RateCalc((this.target as Tower).level)));
                     }
                  }
                  else
                  {
                     this.toolTip.Clear();
                  }
                  break;
               case 1:
                  if(this.target is Tower_Rock)
                  {
                     if(Profile.skills[SkillDef.SOAPBOX] == 0)
                     {
                        this.on = -1;
                        this.toolTip.Clear();
                     }
                     else
                     {
                        this.BuildPotentialRadius(Tower_Soapbox.RangeCalc((this.target as Tower).level));
                        if(this.money < Tower_Soapbox.BasePrice())
                        {
                           _loc4_ = 16724787;
                        }
                        else
                        {
                           _loc4_ = 16777215;
                        }
                        this.toolTip.Set(ToolTip.ITEM,_loc4_,"Soapbox - $" + Tower_Soapbox.BasePrice().toString(),"Beef up nearby towers!","","Damage Bonus: " + this.Str(Tower_Soapbox.DamageCalc((this.target as Tower).level)) + "%","Range: " + this.Str(Tower_Soapbox.RangeCalc((this.target as Tower).level)),"");
                     }
                  }
                  else if(this.target is Tower_Snow)
                  {
                     if(Profile.skills[SkillDef.SLUSHEE] == 0)
                     {
                        this.on = -1;
                        this.toolTip.Clear();
                     }
                     else
                     {
                        this.BuildPotentialRadius(1);
                        if(this.money < Tower_Slushee.BasePrice())
                        {
                           _loc4_ = 16724787;
                        }
                        else
                        {
                           _loc4_ = 16777215;
                        }
                        this.toolTip.Set(ToolTip.ITEM,_loc4_,"Slushee Maker - $" + Tower_Slushee.BasePrice().toString(),"Slows aliens that walk below!","Slow: " + this.Str(Tower_Slushee.DamageCalc(0) * 100) + "%","Time: " + this.Str(Tower_Slushee.SecondCalc(0)) + "s","Rate: " + this.Str(Tower_Slushee.RateCalc(0)));
                     }
                  }
                  else if(this.target is Tower_Shock)
                  {
                     if(Profile.skills[SkillDef.LIGHTNINGROD] == 0)
                     {
                        this.on = -1;
                        this.toolTip.Clear();
                     }
                     else
                     {
                        if(this.money < Tower_LightningRod.BasePrice())
                        {
                           _loc4_ = 16724787;
                        }
                        else
                        {
                           _loc4_ = 16777215;
                        }
                        this.toolTip.Set(ToolTip.ITEM,_loc4_,"Lightning Rod - $" + Tower_LightningRod.BasePrice().toString(),"Massive damage straight up!","Damage: " + this.Str(Tower_LightningRod.DamageCalc((this.target as Tower).level)),"Rate: " + this.Str(Tower_LightningRod.RateCalc((this.target as Tower).level)),"Range: To the moon!");
                     }
                  }
                  else if(this.target is Tower_Roll)
                  {
                     if(Profile.skills[SkillDef.QUAKE] == 0)
                     {
                        this.on = -1;
                        this.toolTip.Clear();
                     }
                     else
                     {
                        this.BuildPotentialRadius(Tower_Quake.RangeCalc((this.target as Tower).level));
                        if(this.money < Tower_Quake.BasePrice())
                        {
                           _loc4_ = 16724787;
                        }
                        else
                        {
                           _loc4_ = 16777215;
                        }
                        this.toolTip.Set(ToolTip.ITEM,_loc4_,"Quake-O-Matic - $" + Tower_Quake.BasePrice().toString(),"Shake the earth!","Damage: " + this.Str(Tower_Quake.DamageCalc((this.target as Tower).level)),"Rate: " + this.Str(Tower_Quake.RateCalc((this.target as Tower).level)),"Range: " + this.Str(Tower_Quake.RangeCalc((this.target as Tower).level)));
                     }
                  }
                  else
                  {
                     this.toolTip.Clear();
                  }
                  break;
               case 2:
                  _loc3_ = new Array();
                  (this.target as Tower).UpgradeText(_loc3_);
                  _loc7_ = (this.target as Tower).UpgradePrice2((this.target as Tower).level) * (1 - Profile.skills[SkillDef.ENHANCEMENT] * 0.03);
                  if((this.target as Tower).level < 5 && this.money < _loc7_)
                  {
                     _loc4_ = 16724787;
                  }
                  else
                  {
                     _loc4_ = 16777215;
                  }
                  this.toolTip.Set(ToolTip.ITEM,_loc4_,_loc3_[0],_loc3_[1],_loc3_[2],_loc3_[3],_loc3_[4],_loc3_[5]);
                  break;
               case 3:
                  _loc3_ = new Array();
                  (this.target as Tower).SellText(_loc3_);
                  this.toolTip.Set(ToolTip.ITEM,16777215,_loc3_[0],_loc3_[1],_loc3_[2],_loc3_[3],_loc3_[4],_loc3_[5]);
                  break;
               case -1:
                  this.toolTip.Clear();
            }
         }
      }
      
      public function Pause() : void
      {
         if(this.boxMode == PAUSE)
         {
            this.boxMode = CANTPLACE;
            this.cursor.frame = 0;
            this.box.visible = true;
         }
         else
         {
            this.boxMode = PAUSE;
            this.cursor.frame = 5;
            this.box.visible = false;
         }
      }
      
      public function ESCHit() : Boolean
      {
         if(this.boxMode == SELECTED || this.boxMode == BUILD || this.boxMode == FOCUSMONSTER)
         {
            this.selects.visible = false;
            this.boxMode = CANTPLACE;
            this.target = null;
            this.toolTip.Clear();
            this.HideRadius();
            return false;
         }
         this.Pause();
         return true;
      }
      
      public function FreeMode() : Boolean
      {
         return this.boxMode == CANPLACE || this.boxMode == CANTPLACE || this.boxMode == SENDWAVE || this.boxMode == CANFOCUS || this.boxMode == CANUPGRADE;
      }
      
      public function Update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:BaseGuy = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         this.cursor.x = FlxG.mouse.x;
         this.cursor.y = FlxG.mouse.y;
         _loc1_ = FlxG.mouse.x / 16;
         _loc2_ = FlxG.mouse.y / 16;
         if(this.boxMode == PAUSE)
         {
            this.box.visible = false;
            this.cursor.frame = 5;
            return;
         }
         if(FlxG.keys.justPressed("SPACE"))
         {
            if(FlxG.timeScale == 0)
            {
               FlxG.timeScale = this.prevTimeScale;
            }
            else
            {
               this.prevTimeScale = FlxG.timeScale;
               FlxG.timeScale = 0;
            }
         }
         if((FlxG.keys.justPressed("U") || FlxG.keys.justPressed("NUMPADZERO")) && (this.boxMode == CANUPGRADE || this.boxMode == CANFOCUS))
         {
            _loc3_ = Global.badguys.BoxOn(Badguys.TOWERS,_loc1_,_loc2_);
            if(_loc3_ != null)
            {
               this.target = _loc3_;
               this.UpgradeTower();
               this.target = null;
            }
         }
         if((FlxG.keys.justPressed("I") || FlxG.keys.justPressed("NUMPADSEVEN")) && (this.boxMode == CANPLACE || this.boxMode == CANFOCUS))
         {
            this.on = 0;
            this.PlaceTower();
         }
         if((FlxG.keys.justPressed("O") || FlxG.keys.justPressed("NUMPADNINE")) && this.boxMode == CANPLACE)
         {
            this.on = 1;
            this.PlaceTower();
         }
         if((FlxG.keys.justPressed("K") || FlxG.keys.justPressed("NUMPADONE")) && this.boxMode == CANPLACE)
         {
            this.on = 2;
            this.PlaceTower();
         }
         if((FlxG.keys.justPressed("L") || FlxG.keys.justPressed("NUMPADTHREE")) && this.boxMode == CANPLACE)
         {
            this.on = 3;
            this.PlaceTower();
         }
         if(FlxG.keys.justPressed("Z") && FlxG.keys.CONTROL && this.boxMode == CANTPLACE)
         {
            _loc3_ = Global.badguys.BoxOn(Badguys.TOWERS,_loc1_,_loc2_);
            if(_loc3_ != null)
            {
               this.target = _loc3_;
               this.SellTower();
            }
         }
         if(FlxG.keys.justPressed("NUMPADMINUS") || FlxG.keys.justPressed("MINUS"))
         {
            _loc4_ = FlxG.timeScale * (60 / 4);
            _loc4_ = _loc4_ - 5;
            if(_loc4_ < 0)
            {
               _loc4_ = 0;
            }
            FlxG.timeScale = _loc4_ / (60 / 4);
         }
         if(FlxG.keys.justPressed("NUMPADPLUS") || FlxG.keys.justPressed("PLUS"))
         {
            _loc4_ = FlxG.timeScale * (60 / 4);
            _loc4_ = _loc4_ + 5;
            if(_loc4_ > 60)
            {
               _loc4_ = 60;
            }
            FlxG.timeScale = _loc4_ / (60 / 4);
         }
         if(this.boxMode != SELECTED && this.boxMode != FOCUSMONSTER && this.boxMode != BUILD && this.boxMode != SENDWAVE && this.boxMode != ONHUD && this.boxMode != SLIDESPEED)
         {
            this.boxX = _loc1_;
            this.boxY = _loc2_;
            this.box.x = _loc1_ * 16 - 4;
            this.box.y = _loc2_ * 16 - 4;
            this.box.visible = true;
            if(FlxG.mouse.screenX >= 320 - 114 && FlxG.mouse.screenY < 40)
            {
               this.boxMode = ONHUD;
               this.cursor.frame = 5;
               this.box.visible = false;
               return;
            }
            if(!FlxG.keys.CONTROL && (Boolean(_loc3_ = Global.badguys.BoxOn(Badguys.TOWERS,_loc1_,_loc2_))))
            {
               this.cursor.frame = 3;
               this.boxMode = CANUPGRADE;
               this.box.frame = 3;
               if(FlxG.mouse.justPressed())
               {
                  this.boxMode = SELECTED;
                  this.target = _loc3_;
                  this.SetupSelect();
               }
            }
            else if(!FlxG.keys.SHIFT && (Boolean(_loc3_ = Global.badguys.CursorOn(Badguys.DEADLY,FlxG.mouse.x,FlxG.mouse.y))))
            {
               this.cursor.frame = 2;
               this.boxMode = CANFOCUS;
               this.box.visible = false;
               if(FlxG.mouse.justPressed())
               {
                  this.boxMode = FOCUSMONSTER;
                  this.target = _loc3_;
               }
            }
            else if(!FlxG.keys.CONTROL && this.ValidTowerPlace(_loc1_,_loc2_))
            {
               this.cursor.frame = 1;
               this.box.frame = 2;
               this.boxMode = CANPLACE;
               if(FlxG.mouse.justPressed())
               {
                  this.boxMode = BUILD;
                  this.SetupSelect();
               }
            }
            else
            {
               this.cursor.frame = 0;
               this.box.frame = 1;
               this.boxMode = CANTPLACE;
            }
         }
         else if(this.boxMode == FOCUSMONSTER)
         {
            this.box.visible = true;
            this.cursor.frame = 0;
            this.box.frame = 4;
            this.box.x = this.target.x + this.target.width / 2 - this.box.width / 2;
            this.box.y = this.target.y - this.box.height;
            if(this.target == null || this.target.health <= 0 || this.target.exists == false || FlxG.mouse.justPressed())
            {
               this.boxMode = CANTPLACE;
               this.target = null;
            }
            PlayState(FlxG.state).hud.monsLife.On(this.target as BaseMonster);
         }
         else if(this.boxMode == SELECTED)
         {
            this.box.visible = true;
            this.cursor.frame = 3;
            this.box.frame = 0;
            this.UpdateSelect();
            if(FlxG.mouse.justPressed())
            {
               if(this.on == -1 || this.enabledButton[this.on] == 0)
               {
                  this.selects.visible = false;
                  this.boxMode = CANTPLACE;
                  this.target = null;
                  this.toolTip.Clear();
                  this.HideRadius();
               }
               else if(this.on == 0 || this.on == 1)
               {
                  if(this.ConvertTower(this.on))
                  {
                     this.selects.visible = false;
                     this.boxMode = CANTPLACE;
                     this.target = null;
                     this.toolTip.Clear();
                     this.HideRadius();
                  }
               }
               else if(this.on == 2)
               {
                  this.UpgradeTower();
                  this.SetupSelect();
               }
               else if(this.on == 3)
               {
                  this.SellTower();
                  this.boxMode = CANTPLACE;
                  this.target = null;
                  this.toolTip.Clear();
                  this.HideRadius();
               }
            }
         }
         else if(this.boxMode == BUILD)
         {
            this.box.visible = true;
            this.cursor.frame = 1;
            this.box.frame = 5;
            this.UpdateSelect();
            if(FlxG.mouse.justPressed())
            {
               if(this.on == -1 || this.enabledButton[this.on] == 0)
               {
                  this.toolTip.Clear();
                  this.selects.visible = false;
                  this.boxMode = CANTPLACE;
               }
               else
               {
                  this.PlaceTower();
                  this.toolTip.Clear();
               }
            }
         }
         else if(this.boxMode == SENDWAVE)
         {
            if(FlxG.mouse.screenX >= 320 - 114 && FlxG.mouse.screenY < 40)
            {
               this.boxMode = ONHUD;
               this.cursor.frame = 5;
               this.box.visible = false;
               return;
            }
            this.box.visible = false;
            this.cursor.frame = 4;
            if(FlxG.mouse.justPressed())
            {
               Global.waveManager.SendWave(this.on);
            }
         }
         else if(this.boxMode == ONHUD)
         {
            this.cursor.frame = 5;
            if(FlxG.mouse.justPressed())
            {
               if(PlayState(FlxG.state).hud.Click())
               {
                  this.boxMode = SLIDESPEED;
               }
            }
            if(FlxG.mouse.screenX < 320 - 114 || FlxG.mouse.screenY >= 40)
            {
               this.box.visible = true;
               this.cursor.frame = 0;
               this.boxMode = CANTPLACE;
            }
         }
         else if(this.boxMode == SLIDESPEED)
         {
            if(!PlayState(FlxG.state).hud.SlideSpeed())
            {
               this.boxMode = ONHUD;
            }
         }
         if(this.boxMode == SELECTED || this.boxMode == BUILD)
         {
            _loc5_ = this.boxX * 16 - FlxG.camera.scroll.x;
            _loc6_ = this.boxY * 16 - FlxG.camera.scroll.y;
            if(_loc5_ < 20)
            {
               FlxG.camera.scroll.x -= 0.02 * 250;
            }
            if(_loc5_ > 300 - 16)
            {
               FlxG.camera.scroll.x += 0.02 * 250;
            }
            if(_loc6_ < 40)
            {
               FlxG.camera.scroll.y -= 0.02 * 250;
            }
            if(_loc6_ > 220 - 16)
            {
               FlxG.camera.scroll.y += 0.02 * 250;
            }
         }
         else
         {
            this.HideRadius();
         }
      }
      
      public function GetXP(param1:int) : void
      {
         Profile.xp += param1;
         if(Profile.xp > Profile.XPNeed())
         {
            Profile.xp -= Profile.XPNeed();
            if(Profile.level < 99)
            {
               ++Profile.level;
               ++Profile.skillPts;
            }
            Sounds.play(Sounds.LevelUpSnd);
            Profile.SaveGame();
            PlayState(FlxG.state).notice.Say("LEVEL UP!",5635959,FlxG.camera.scroll.x + 160,FlxG.camera.scroll.y + 120);
         }
         PlayState(FlxG.state).hud.SetXP();
      }
      
      public function GetMoney(param1:int) : void
      {
         this.money += param1;
         if(this.money > 9999)
         {
            this.money = 9999;
         }
         if(this.boxMode == SELECTED || this.boxMode == BUILD)
         {
            this.SelectMoneyAdjust();
         }
         PlayState(FlxG.state).hud.SetCash();
      }
      
      public function ConvertTower(param1:int) : Boolean
      {
         var _loc2_:Class = null;
         var _loc3_:int = 0;
         var _loc4_:Tower = null;
         _loc2_ = null;
         if(this.target is Tower_Rock)
         {
            if(param1 == 0)
            {
               _loc2_ = Tower_Sling;
               _loc3_ = Tower_Sling.BasePrice();
            }
            else
            {
               _loc2_ = Tower_Soapbox;
               _loc3_ = Tower_Soapbox.BasePrice();
            }
         }
         else if(this.target is Tower_Snow)
         {
            if(param1 == 0)
            {
               _loc2_ = Tower_Ice;
               _loc3_ = Tower_Ice.BasePrice();
            }
            else
            {
               _loc2_ = Tower_Slushee;
               _loc3_ = Tower_Slushee.BasePrice();
            }
         }
         else if(this.target is Tower_Shock)
         {
            if(param1 == 0)
            {
               _loc2_ = Tower_Crippler;
               _loc3_ = Tower_Crippler.BasePrice();
            }
            else
            {
               _loc2_ = Tower_LightningRod;
               _loc3_ = Tower_LightningRod.BasePrice();
            }
         }
         else if(this.target is Tower_Roll)
         {
            if(param1 == 0)
            {
               _loc2_ = Tower_Crusher;
               _loc3_ = Tower_Crusher.BasePrice();
            }
            else
            {
               _loc2_ = Tower_Quake;
               _loc3_ = Tower_Quake.BasePrice();
            }
         }
         if(_loc2_ != null)
         {
            if(this.money >= _loc3_)
            {
               this.money -= _loc3_;
               Sounds.play(Sounds.BuildSnd);
               PlayState(FlxG.state).hud.SetCash();
               _loc4_ = Global.badguys.AddGuy(_loc2_,Badguys.TOWERS,this.boxX,this.boxY) as Tower;
               _loc4_.level = (this.target as Tower).level;
               _loc4_.SetStats();
               this.target.exists = false;
               return true;
            }
         }
         return false;
      }
      
      public function SellTower() : void
      {
         this.GetMoney((this.target as Tower).SellPrice());
         Global.badguys.DeepFreeze((this.target as Tower).level);
         this.selects.visible = false;
         this.target.exists = false;
         Global.bullets.AddBullet(Boom,Bullets.NEUTRAL,this.target.x + this.target.width / 2,this.target.y + this.target.height / 2,0,0);
      }
   }
}

