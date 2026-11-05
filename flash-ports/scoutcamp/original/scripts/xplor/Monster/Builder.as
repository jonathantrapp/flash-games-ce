package xplor.Monster
{
   import org.flixel.FlxG;
   import org.flixel.FlxSprite;
   import xplor.Bullet.SmokePuff;
   import xplor.Bullets;
   import xplor.Global;
   import xplor.Sounds;
   
   public class Builder extends FlxSprite
   {
      
      public static var BuilderImage:Class = Builder_BuilderImage;
      
      public var nextBuild:Number;
      
      public var owner:FlxSprite;
      
      public function Builder()
      {
         super();
         loadGraphic(BuilderImage,true,true,16,16,true);
         addAnimation("build",[0,1],15,true);
         addAnimation("build2",[2,3],15,true);
         this.nextBuild = 0;
      }
      
      public function Reset() : void
      {
         this.nextBuild = Global.randRange(0.05,0.2);
         x = this.owner.x + Global.randRange(-10,this.owner.width + 10 - width);
         y = this.owner.y + Global.randRange(-8,this.owner.height + 4 - height);
         if(x > this.owner.x + this.owner.width / 2 - width / 2)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         angle = Global.randRange(-45,45);
         if(Global.randRange(0,1) < 0.5)
         {
            play("build");
         }
         else
         {
            play("build2");
         }
         Sounds.play(Sounds.HammerSnd);
         Global.bullets.AddBullet(SmokePuff,Bullets.BACKGD,x + width / 2,y + height / 2,-1,0);
      }
      
      override public function update() : void
      {
         super.update();
         super.postUpdate();
         this.nextBuild -= FlxG.elapsed;
         if(this.nextBuild <= 0)
         {
            this.Reset();
         }
      }
   }
}

