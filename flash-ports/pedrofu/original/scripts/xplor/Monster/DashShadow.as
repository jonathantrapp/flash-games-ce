package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Global;
   import xplor.Pedro;
   
   public class DashShadow extends BaseGuy
   {
      
      public function DashShadow(tx:int, ty:int)
      {
         super(tx,ty);
         loadGraphic(Pedro.PedroImage,true,true,20,19,true);
         addAnimation("dash",[30],10,true);
         addAnimation("grab",[9],10,true);
         addAnimation("jumpkick_dn",[7],10,true);
         addAnimation("jumpkick_up",[8],10,true);
         addAnimation("jumpkick",[6],10,true);
         addAnimation("pedroken",[34],10,true);
         this.offset.x = 6;
         this.offset.y = 3;
         this.width = 8;
         this.height = 15;
         this.Init(tx,ty);
      }
      
      override public function Init(tx:int, ty:int) : void
      {
         solid = false;
         super.Init(tx,ty);
      }
      
      override public function Reset() : void
      {
         super.Reset();
         solid = false;
         var t:Pedro = Global.pedro;
         if(t.facing == LEFT)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
         if(t.berserk > 0)
         {
            color = 16733695;
         }
         else
         {
            color = 16777215;
         }
         alpha = 0.8;
      }
      
      override public function hurt(n:Number) : void
      {
      }
      
      override public function update() : void
      {
         super.update();
         alpha -= FlxG.elapsed * 2;
         if(alpha <= 0)
         {
            exists = false;
         }
      }
   }
}

