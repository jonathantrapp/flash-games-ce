package xplor.Bullet
{
   import flash.display.Shape;
   import org.flixel.FlxG;
   import org.flixel.FlxSprite;
   import xplor.Global;
   
   public class Lightning extends BaseBullet
   {
      
      public static var LaserEndImage:Class = Lightning_LaserEndImage;
      
      public var startx:Number;
      
      public var starty:Number;
      
      public var endx:Number;
      
      public var endy:Number;
      
      public var beamStart:FlxSprite;
      
      public var on:Boolean;
      
      public var zap:Number;
      
      public function Lightning()
      {
         super();
         this.beamStart = new FlxSprite(0,0,LaserEndImage);
         this.beamStart.antialiasing = true;
         this.beamStart.blend = "add";
         this.on = false;
         alpha = 0;
      }
      
      override public function shoot(x:int, y:int, a:Number, dmg:Number) : void
      {
         this.startx = x;
         this.starty = y;
         damage = dmg;
         exists = true;
         visible = true;
         solid = false;
         alpha = 0;
         this.zap = 0.25;
      }
      
      override public function update() : void
      {
         if(this.zap > 0)
         {
            this.zap -= FlxG.elapsed;
            alpha += FlxG.elapsed * 5;
            if(alpha > 1)
            {
               alpha = 1;
            }
         }
         else if(alpha > 0)
         {
            alpha -= FlxG.elapsed * 5;
         }
         else
         {
            exists = false;
         }
         if(target != null && target.exists)
         {
            this.endx = target.x + Global.randRange(target.width / 4,target.width * 3 / 4);
            this.endy = target.y + Global.randRange(target.height / 4,target.height * 3 / 4);
         }
         this.beamStart.x = this.startx - 4;
         this.beamStart.y = this.starty - 4;
      }
      
      override public function draw() : void
      {
         var cx:Number = NaN;
         var cy:Number = NaN;
         var dx:Number = NaN;
         var dy:Number = NaN;
         var i:int = 0;
         var steps:int = 0;
         var length:Number = NaN;
         var ax:Number = NaN;
         var ay:Number = NaN;
         var bx:Number = NaN;
         var by:Number = NaN;
         if(alpha == 0)
         {
            return;
         }
         if(!exists)
         {
            return;
         }
         var shape:Shape = new Shape();
         var shape2:Shape = new Shape();
         length = Math.sqrt((this.endx - this.startx) * (this.endx - this.startx) + (this.endy - this.starty) * (this.endy - this.starty));
         cx = 3;
         shape.graphics.lineStyle(cx,65535,alpha / 2);
         shape.graphics.moveTo(this.startx - FlxG.camera.scroll.x,this.starty - FlxG.camera.scroll.y);
         cx = 2;
         shape2.graphics.lineStyle(cx,16777215,alpha);
         shape2.graphics.moveTo(this.startx - FlxG.camera.scroll.x,this.starty - FlxG.camera.scroll.y);
         cx = this.startx - FlxG.camera.scroll.x;
         cy = this.starty - FlxG.camera.scroll.y;
         steps = int(length / 8);
         dx = (this.endx - this.startx) / steps;
         dy = (this.endy - this.starty) / steps;
         for(i = 0; i < steps; i++)
         {
            cx += dx;
            cy += dy;
            ax = Global.randRange(-8,8) + (cx - dx / 2);
            ay = Global.randRange(-8,8) + (cy - dy / 2);
            bx = cx + Global.randRange(-2,2);
            by = cy + Global.randRange(-2,2);
            shape.graphics.curveTo(ax,ay,bx,by);
            shape2.graphics.curveTo(ax,ay,bx,by);
         }
         shape.graphics.lineTo(this.endx - FlxG.camera.scroll.x,this.endy - FlxG.camera.scroll.y);
         shape2.graphics.lineTo(this.endx - FlxG.camera.scroll.x,this.endy - FlxG.camera.scroll.y);
         FlxG.camera.buffer.draw(shape);
         FlxG.camera.buffer.draw(shape2);
         cx = 1;
         this.beamStart.scale.x = Global.randRange(0.5,cx);
         this.beamStart.scale.y = this.beamStart.scale.x;
         this.beamStart.alpha = Global.randRange(0.1,0.5) * alpha;
         this.beamStart.draw();
      }
   }
}

