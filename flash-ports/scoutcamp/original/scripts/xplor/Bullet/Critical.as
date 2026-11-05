package xplor.Bullet
{
   import org.flixel.FlxG;
   import xplor.Global;
   
   public class Critical extends BaseBullet
   {
      
      public static var BoomImage:Class = Critical_BoomImage;
      
      public var size:Number;
      
      public function Critical()
      {
         super();
         loadGraphic(BoomImage,true,false,23,24,true);
      }
      
      override public function shoot(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         this.x = param1 - width / 2;
         this.y = param2 - height / 2;
         exists = true;
         visible = true;
         solid = false;
         alpha = 1;
         scale.x = 0.1;
         scale.y = 0.1;
         this.size = 0.5;
         angle = Global.randRange(0,360);
      }
      
      override public function update() : void
      {
         this.size += FlxG.elapsed * 3;
         scale.x = Global.randRange(this.size / 2,this.size);
         scale.y = Global.randRange(this.size / 2,this.size);
         if(this.size > 1)
         {
            alpha -= FlxG.elapsed * 3;
         }
         if(alpha <= 0)
         {
            exists = false;
         }
      }
   }
}

