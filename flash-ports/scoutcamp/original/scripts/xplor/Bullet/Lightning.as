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
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.startx = param1;
         this.starty = param2;
         damage = param4;
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
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         if(alpha == 0)
         {
            return;
         }
         if(!exists)
         {
            return;
         }
         var _loc12_:Shape = new Shape();
         var _loc13_:Shape = new Shape();
         _loc7_ = Math.sqrt((this.endx - this.startx) * (this.endx - this.startx) + (this.endy - this.starty) * (this.endy - this.starty));
         _loc1_ = 2;
         _loc12_.graphics.lineStyle(_loc1_,16768833,alpha / 2);
         _loc12_.graphics.moveTo(this.startx - FlxG.camera.scroll.x,this.starty - FlxG.camera.scroll.y);
         _loc1_ = 1;
         _loc13_.graphics.lineStyle(_loc1_,16777215,alpha);
         _loc13_.graphics.moveTo(this.startx - FlxG.camera.scroll.x,this.starty - FlxG.camera.scroll.y);
         _loc1_ = this.startx - FlxG.camera.scroll.x;
         _loc2_ = this.starty - FlxG.camera.scroll.y;
         _loc6_ = int(_loc7_ / 8);
         _loc3_ = (this.endx - this.startx) / _loc6_;
         _loc4_ = (this.endy - this.starty) / _loc6_;
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            _loc1_ += _loc3_;
            _loc2_ += _loc4_;
            _loc8_ = Global.randRange(-8,8) + (_loc1_ - _loc3_ / 2);
            _loc9_ = Global.randRange(-8,8) + (_loc2_ - _loc4_ / 2);
            _loc10_ = _loc1_ + Global.randRange(-2,2);
            _loc11_ = _loc2_ + Global.randRange(-2,2);
            _loc12_.graphics.curveTo(_loc8_,_loc9_,_loc10_,_loc11_);
            _loc13_.graphics.curveTo(_loc8_,_loc9_,_loc10_,_loc11_);
            _loc5_++;
         }
         _loc12_.graphics.lineTo(this.endx - FlxG.camera.scroll.x,this.endy - FlxG.camera.scroll.y);
         _loc13_.graphics.lineTo(this.endx - FlxG.camera.scroll.x,this.endy - FlxG.camera.scroll.y);
         FlxG.camera.buffer.draw(_loc12_);
         FlxG.camera.buffer.draw(_loc13_);
         _loc1_ = 1;
         this.beamStart.scale.x = Global.randRange(0.5,_loc1_);
         this.beamStart.scale.y = this.beamStart.scale.x;
         this.beamStart.alpha = Global.randRange(0.1,0.5) * alpha;
         this.beamStart.draw();
      }
   }
}

