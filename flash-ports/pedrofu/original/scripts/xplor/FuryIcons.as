package xplor
{
   import org.flixel.*;
   import xplor.Menus.SkillDef;
   
   public class FuryIcons extends FlxGroup
   {
      
      public static var IconImage:Class = FuryIcons_IconImage;
      
      public var show:Boolean;
      
      public var angle:Number;
      
      public var radius:Number;
      
      public var angles:Array = new Array(90,0,270,180);
      
      public var explode:Boolean;
      
      public function FuryIcons()
      {
         var s:FlxSprite = null;
         super();
         for(var i:int = 0; i < 4; i++)
         {
            s = new FlxSprite(160 - 13,120 - 13);
            s.loadGraphic(IconImage,true,false,26,26,true);
            s.visible = false;
            s.scrollFactor.x = 0;
            s.scrollFactor.y = 0;
            s.frame = 0;
            add(s);
         }
         if(Boolean(Profile.skills[SkillDef.FURIOUSBLAST]))
         {
            members[0].frame = 1;
         }
         if(Boolean(Profile.skills[SkillDef.FURIOUSFIX]))
         {
            members[2].frame = 3;
         }
         if(Boolean(Profile.skills[SkillDef.FURIOUSFREEZE]))
         {
            members[3].frame = 4;
         }
         if(Boolean(Profile.skills[SkillDef.FURIOUSFRENZY]))
         {
            members[1].frame = 2;
         }
         this.show = false;
      }
      
      public function Show() : void
      {
         var s:FlxSprite = null;
         this.show = true;
         this.angle = 0;
         this.radius = 0;
         for each(s in members)
         {
            s.visible = true;
            s.scale.x = 0;
            s.scale.y = 0;
         }
      }
      
      public function Explode() : void
      {
         this.show = false;
         this.explode = true;
      }
      
      public function Hide() : void
      {
         this.explode = false;
         this.show = false;
      }
      
      override public function update() : void
      {
         var s:FlxSprite = null;
         var px:Number = NaN;
         var py:Number = NaN;
         if(this.show)
         {
            if(this.radius < 26)
            {
               this.angle += FlxG.elapsed * 720;
               if(this.angle >= 360)
               {
                  this.angle -= 360;
               }
               this.radius += FlxG.elapsed * 52;
            }
            else
            {
               this.radius = 26;
               this.angle = 0;
            }
         }
         else if(this.explode)
         {
            this.radius += FlxG.elapsed * 300;
         }
         else if(this.radius > 0)
         {
            this.angle -= FlxG.elapsed * 720;
            if(this.angle < 0)
            {
               this.angle += 360;
            }
            this.radius -= FlxG.elapsed * 52;
         }
         else
         {
            this.radius = 0;
         }
         var i:int = 0;
         px = Global.pedro.x + Global.pedro.width / 2 - FlxG.camera.scroll.x;
         py = Global.pedro.y + Global.pedro.height / 2 - FlxG.camera.scroll.y;
         for each(s in members)
         {
            if(this.show)
            {
               if(s.scale.x < 1)
               {
                  s.scale.x += FlxG.elapsed * 4;
                  if(s.scale.x > 1)
                  {
                     s.scale.x = 1;
                  }
                  s.scale.y = s.scale.x;
               }
            }
            else if(s.scale.x > 0)
            {
               s.scale.x -= FlxG.elapsed * 2;
               if(s.scale.x < 0)
               {
                  s.scale.x = 0;
               }
               s.scale.y = s.scale.x;
            }
            else
            {
               s.visible = false;
            }
            s.x = px + Global.Cosine(this.angle + this.angles[i]) * this.radius - s.width / 2;
            s.y = py + Global.Sine(this.angle + this.angles[i]) * this.radius - s.height / 2;
            i++;
         }
      }
   }
}

