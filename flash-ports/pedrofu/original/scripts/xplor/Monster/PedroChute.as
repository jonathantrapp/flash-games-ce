package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Global;
   import xplor.PlayState;
   
   public class PedroChute extends BaseMonster
   {
      
      public static var PedroImage:Class = PedroChute_PedroImage;
      
      public var solidWait:Number;
      
      public function PedroChute(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(PedroImage,true,true,31,39,true);
         addAnimation("fly",[0],10,true);
         addAnimation("collapse",[1,2,3,4],10,false);
         width = 11;
         offset.x = 10;
         height = 38;
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         this.solidWait = 1;
         angle = 15;
         super.Init(tx,ty);
      }
      
      override public function Reset() : void
      {
         super.Reset();
         acceleration.y = 0;
         velocity.y = 60;
         velocity.x = -60;
         action = 0;
         FlxG.camera.follow(this);
         facing = RIGHT;
      }
      
      override public function BasicUpdate() : void
      {
         if(angle > 0)
         {
            angularAcceleration = -40;
         }
         else if(angle < 0)
         {
            angularAcceleration = 40;
         }
         this.solidWait -= FlxG.elapsed;
         if(this.solidWait <= 0)
         {
            solid = true;
         }
         if(action == 0 && isTouching(FLOOR))
         {
            action = 1;
            play("collapse");
            velocity.x = 0;
            velocity.y = 0;
         }
         else if(action == 1)
         {
            angularAcceleration = 0;
            angle *= 0.8;
            if(finished)
            {
               exists = false;
               Global.pedro.x = x;
               Global.pedro.y = y + 23;
               Global.pedro.visible = true;
               Global.pedro.action = IDLE;
               FlxG.camera.follow(Global.pedro);
               PlayState(FlxG.state).conversation.Setup(1,null);
            }
         }
      }
   }
}

