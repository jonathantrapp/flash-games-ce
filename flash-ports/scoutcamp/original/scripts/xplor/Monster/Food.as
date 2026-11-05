package xplor.Monster
{
   import xplor.Badguys;
   import xplor.Global;
   
   public class Food extends BaseGuy
   {
      
      public static var FoodImage:Class = Food_FoodImage;
      
      public static const TAKEN:int = 2;
      
      public var holder:BaseGuy;
      
      public function Food(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(FoodImage,true,true,16,16,true);
         height = 6;
         offset.y = 8;
         this.Init(param1,param2);
      }
      
      override public function Init(param1:int, param2:int) : void
      {
         solid = true;
         super.Init(param1,param2);
      }
      
      override public function Reset() : void
      {
         super.Reset();
         acceleration.y = 200;
         this.holder = null;
         angle = 0;
         color = 16777215;
         if(Global.randRange(0,1) < 0.5)
         {
            facing = LEFT;
         }
         else
         {
            facing = RIGHT;
         }
      }
      
      public function Taken(param1:BaseGuy) : Boolean
      {
         if(this.holder != null)
         {
            return false;
         }
         if(param1.action != JUMP)
         {
            this.holder = param1;
            action = TAKEN;
            return true;
         }
         return false;
      }
      
      override public function update() : void
      {
         var _loc1_:BaseMonster = null;
         super.update();
         if(action == TAKEN)
         {
            solid = false;
            if(this.holder == null || this.holder.health <= 0 || this.holder.exists == false)
            {
               action = IDLE;
               this.holder = null;
               return;
            }
            velocity.y = 0;
            velocity.x = 0;
            acceleration.y = 0;
            x = this.holder.x + this.holder.width / 2 - width / 2;
            y = this.holder.y - height / 2;
            if(this.holder is Beefy)
            {
               y -= 5;
            }
         }
         else
         {
            acceleration.y = 200;
            solid = true;
            for each(_loc1_ in Global.badguys.GetGroup(Badguys.DEADLY).members)
            {
               if(_loc1_ != null && _loc1_.exists && !_loc1_.escaping && _loc1_.DistanceToGuy(this) < 16)
               {
                  Global.badguys.GrabFood(_loc1_,this);
                  if(this.holder != null)
                  {
                     break;
                  }
               }
            }
         }
      }
      
      override public function draw() : void
      {
         if(this.holder != null && this.holder.exists)
         {
            x = this.holder.x + this.holder.width / 2 - width / 2;
            y = this.holder.y - height / 2;
            if(this.holder is Beefy)
            {
               y -= 5;
            }
         }
         super.draw();
      }
   }
}

