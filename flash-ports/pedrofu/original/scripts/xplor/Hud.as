package xplor
{
   import flash.geom.Rectangle;
   import org.flixel.*;
   import xplor.Monster.BaseMonster;
   
   public class Hud extends FlxGroup
   {
      
      public static var HeartImage:Class = Hud_HeartImage;
      
      public static var MailImage:Class = Hud_MailImage;
      
      public static var FuryImage:Class = Hud_FuryImage;
      
      public static var FuryInnardsImage:Class = Hud_FuryInnardsImage;
      
      public static var FuryBoxImage:Class = Hud_FuryBoxImage;
      
      public static var XPMeterImage:Class = Hud_XPMeterImage;
      
      public static var BadguyMeterImage:Class = Hud_BadguyMeterImage;
      
      public static var BadguyMeterInsideImage:Class = Hud_BadguyMeterInsideImage;
      
      public var monsLife:MonsterLifeBar;
      
      public var xpBar:FlxSprite;
      
      public var hearts:Array;
      
      public var mail:Array;
      
      public var fury_meter:FlxSprite;
      
      public var fury_meter2:FlxSprite;
      
      public var fury_box:Array;
      
      public var flash:Number;
      
      public var badguy_meter:FlxSprite;
      
      public var badguy_meter2:FlxSprite;
      
      public var badguy_name:FlxText;
      
      public var badguy_timer:Number;
      
      public var levelText:FlxText;
      
      public function Hud()
      {
         var i:int = 0;
         var s:FlxSprite = null;
         super();
         this.monsLife = new MonsterLifeBar();
         add(this.monsLife);
         s = new FlxSprite(163,240 - 8);
         s.loadGraphic(XPMeterImage,true,false,68,6,true);
         s.scrollFactor.x = 0;
         s.scrollFactor.y = 0;
         add(s);
         this.xpBar = new FlxSprite(163,240 - 8);
         this.xpBar.loadGraphic(XPMeterImage,true,false,68,6,true);
         this.xpBar.clip = new Rectangle(0,0,68,6);
         this.xpBar.clip.width = 0;
         this.xpBar.scrollFactor.x = 0;
         this.xpBar.scrollFactor.y = 0;
         this.xpBar.frame = 1;
         add(this.xpBar);
         this.levelText = new FlxText(163,240 - 8 - 10,68,"Level " + (Profile.level + 1));
         this.levelText.scrollFactor.x = 0;
         this.levelText.scrollFactor.y = 0;
         this.levelText.origin.y = 10;
         this.levelText.setFormat("volks",8,16777215,"center",1);
         add(this.levelText);
         this.badguy_meter = new FlxSprite((320 - 63) / 2,1,BadguyMeterImage);
         this.badguy_meter.scrollFactor.x = 0;
         this.badguy_meter.scrollFactor.y = 0;
         add(this.badguy_meter);
         this.badguy_meter2 = new FlxSprite((320 - 63) / 2 + 2,3);
         this.badguy_meter2.loadGraphic(BadguyMeterInsideImage,false,false,59,5,true);
         this.badguy_meter2.clip = new Rectangle(0,0,59,5);
         this.badguy_meter2.clip.width = 0;
         this.badguy_meter2.scrollFactor.x = 0;
         this.badguy_meter2.scrollFactor.y = 0;
         add(this.badguy_meter2);
         this.badguy_meter.visible = false;
         this.badguy_meter2.visible = false;
         this.badguy_name = new FlxText(0,10,320,"");
         this.badguy_name.setFormat("volks",10,16777215,"center",1);
         this.badguy_name.scrollFactor.x = 0;
         this.badguy_name.scrollFactor.y = 0;
         add(this.badguy_name);
         this.badguy_name.visible = false;
         this.badguy_timer = 0;
         this.hearts = new Array();
         for(i = 0; i < 20; i++)
         {
            s = new FlxSprite(i * 8 + 1,240 - 10);
            s.loadGraphic(HeartImage,true,false,9,9,true);
            s.scrollFactor.x = 0;
            s.scrollFactor.y = 0;
            s.frame = 1;
            if(i >= Profile.max_life)
            {
               s.visible = false;
            }
            add(s);
            this.hearts.push(s);
         }
         this.mail = new Array();
         for(i = 0; i < Global.mailLeft; i++)
         {
            s = new FlxSprite(i * 12 + 1,240 - 22);
            s.loadGraphic(MailImage,true,false,11,11,true);
            s.scrollFactor.x = 0;
            s.scrollFactor.y = 0;
            s.frame = 0;
            add(s);
            this.mail.push(s);
         }
         this.fury_meter = new FlxSprite(320 - 64,240 - 10);
         this.fury_meter.loadGraphic(FuryImage,true,false,63,9,true);
         this.fury_meter.scrollFactor.x = 0;
         this.fury_meter.scrollFactor.y = 0;
         add(this.fury_meter);
         this.fury_meter2 = new FlxSprite(320 - 64 + 1,240 - 10 + 1);
         this.fury_meter2.loadGraphic(FuryInnardsImage,true,false,61,7,true);
         this.fury_meter2.clip = new Rectangle(0,0,61,7);
         this.fury_meter2.origin.x = 60;
         this.fury_meter2.clip.width = 0;
         this.fury_meter2.scrollFactor.x = 0;
         this.fury_meter2.scrollFactor.y = 0;
         add(this.fury_meter2);
         this.flash = 0;
         this.fury_box = new Array();
         for(i = 0; i < 4; i++)
         {
            s = new FlxSprite(320 - 64 - 6 * (i + 1),240 - 10);
            s.loadGraphic(FuryBoxImage,true,false,7,9,true);
            s.scrollFactor.x = 0;
            s.scrollFactor.y = 0;
            if(i >= Profile.max_fury - 1)
            {
               s.visible = false;
            }
            add(s);
            this.fury_box.push(s);
         }
      }
      
      public function HitBadguy(guy:BaseMonster) : void
      {
         this.badguy_timer = 3;
         this.badguy_name.text = guy.name;
         this.badguy_meter2.clip.width = 59 * guy.health / guy.maxHealth;
         this.badguy_meter.visible = true;
         this.badguy_meter2.visible = true;
         this.badguy_name.visible = true;
         this.badguy_meter.alpha = 1;
         this.badguy_meter2.alpha = 1;
         this.badguy_name.alpha = 1;
         if(guy.health == 0)
         {
            this.badguy_timer = 0;
         }
      }
      
      public function SetXP() : void
      {
         this.xpBar.scale.x = Profile.xp / Profile.XPNeed();
      }
      
      public function SetCash() : void
      {
      }
      
      public function Update() : void
      {
         var i:int = 0;
         var blink:int = 0;
         var f:FlxSprite = null;
         if(this.badguy_timer > 0)
         {
            this.badguy_timer -= FlxG.elapsed;
         }
         else if(this.badguy_meter.alpha > 0)
         {
            this.badguy_meter.alpha -= FlxG.elapsed;
            this.badguy_meter2.alpha -= FlxG.elapsed;
            this.badguy_name.alpha -= FlxG.elapsed;
         }
         else
         {
            this.badguy_meter.visible = false;
            this.badguy_meter2.visible = false;
            this.badguy_name.visible = false;
         }
         this.flash += FlxG.elapsed;
         if(this.flash >= 0.2)
         {
            this.flash -= 0.2;
         }
         if(this.flash > 0.1)
         {
            blink = 1;
         }
         else
         {
            blink = 0;
         }
         if(this.levelText.scale.x > 1)
         {
            this.levelText.scale.x -= FlxG.elapsed;
            if(this.levelText.scale.x < 1)
            {
               this.levelText.scale.x = 1;
            }
            this.levelText.scale.y = this.levelText.scale.x;
         }
         for(i = 0; i < this.hearts.length; i++)
         {
            f = this.hearts[i];
            if(f.scale.x > 1)
            {
               f.scale.x -= FlxG.elapsed * 4;
               if(f.scale.x < 1)
               {
                  f.scale.x = 1;
               }
               f.scale.y = f.scale.x;
            }
            if(i < Global.pedro.health)
            {
               if(f.frame == 0)
               {
                  f.scale.x = 2;
                  f.scale.y = 2;
               }
               if(Global.pedro.health < 3)
               {
                  f.frame = 1 + blink;
               }
               else
               {
                  f.frame = 1;
               }
            }
            else
            {
               f.frame = 0;
            }
         }
         for(i = 0; i < this.mail.length; i++)
         {
            if(this.mail.length - i > Global.mailLeft)
            {
               (this.mail[i] as FlxSprite).frame = 1;
            }
         }
         if(Global.pedro.fury == Profile.max_fury)
         {
            this.fury_meter2.x = 320 - 64 + 1;
            this.fury_meter2.clip.x = 0;
            this.fury_meter2.clip.width = 61;
            this.fury_meter2.dirty = true;
            this.fury_meter2.frame = blink;
            this.fury_meter.frame = blink;
         }
         else
         {
            this.fury_meter.frame = 0;
            this.fury_meter2.clip.width = int(Global.pedro.subFury * 61);
            this.fury_meter2.clip.x = 61 - this.fury_meter2.clip.width;
            this.fury_meter2.x = 320 - 64 + 1 + int(this.fury_meter2.clip.x + 0.5);
            this.fury_meter2.dirty = true;
            this.fury_meter2.frame = 0;
         }
         this.xpBar.clip.width = int(Profile.xp / Profile.XPNeed() * 68);
         this.xpBar.dirty = true;
         for(i = 0; i < this.fury_box.length; i++)
         {
            if(Global.pedro.fury >= i + 1)
            {
               f = this.fury_box[i] as FlxSprite;
               f.frame = 1 + blink;
            }
            else
            {
               (this.fury_box[i] as FlxSprite).frame = 0;
            }
         }
      }
      
      public function AdjustMaxes() : void
      {
         var i:int = 0;
         for(i = 0; i < 20; i++)
         {
            if(i < Profile.max_life)
            {
               (this.hearts[i] as FlxSprite).visible = true;
            }
         }
         for(i = 0; i < 4; i++)
         {
            if(i < Profile.max_fury - 1)
            {
               (this.fury_box[i] as FlxSprite).visible = true;
            }
         }
      }
   }
}

