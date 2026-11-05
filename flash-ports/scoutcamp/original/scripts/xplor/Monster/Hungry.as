package xplor.Monster
{
   import org.flixel.FlxG;
   import xplor.Badguys;
   import xplor.Global;
   import xplor.Sounds;
   
   public class Hungry extends BaseMonster
   {
      
      public static var SkellyImage:Class = Hungry_SkellyImage;
      
      public var baseScale:Number;
      
      public var dScale:Number;
      
      public var walkScale:Number;
      
      public var babyLife:Number;
      
      public var babyLevel:Number;
      
      public var babyWait:Number;
      
      public function Hungry(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SkellyImage,true,true,64,48,true);
         addAnimation("walk",[0],10,true);
         addAnimation("jump",[0],10,true);
         width = 5;
         offset.x = 29.5;
         speed = 2;
         height = 14;
         offset.y = 31;
         name = "Hungry";
         this.Init(param1,param2);
      }
      
      public static function Life(param1:int) : int
      {
         return 250 + param1 * 90;
      }
      
      public static function Money(param1:int) : int
      {
         return 100 + param1 * 20;
      }
      
      override public function Init(param1:int, param2:int) : void
      {
         solid = true;
         super.Init(param1,param2);
      }
      
      override public function Reset() : void
      {
         level = Badguys.levelToMake;
         maxHealth = Life(level);
         moneyValue = Money(level);
         xpValue = level;
         super.Reset();
         this.baseScale = 1;
         this.dScale = -1;
         this.walkScale = 1;
         this.babyLife = maxHealth * 0.99;
         this.babyLevel = 1;
         this.babyWait = 0;
      }
      
      override public function GotFood() : void
      {
      }
      
      public function NewBaby(param1:Number) : void
      {
         var _loc2_:HungryBaby = null;
         Badguys.levelToMake = this.babyLevel;
         _loc2_ = Global.badguys.AddGuy(HungryBaby,Badguys.DEADLY,0,0) as HungryBaby;
         _loc2_.x = x + width / 2 - _loc2_.width / 2;
         _loc2_.y = y + height - _loc2_.height;
         if(advancing)
         {
            _loc2_.facing = facing;
         }
         else
         {
            _loc2_.facing = LEFT + RIGHT - facing;
         }
         _loc2_.bornSpeed = param1;
         _loc2_.traveled = traveled;
         _loc2_.speed = 35 / 2 * param1;
         _loc2_.startx = startx;
         _loc2_.starty = starty;
      }
      
      override public function BasicUpdate() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Food = null;
         super.BasicUpdate();
         this.walkScale += this.dScale * (FlxG.elapsed / 2);
         if(this.walkScale < 0.75)
         {
            this.dScale = 0.6;
         }
         else if(this.walkScale >= 1)
         {
            this.walkScale = 1;
            this.dScale = -1;
         }
         _loc1_ = 0.5 + (1 - this.walkScale * 0.5);
         scale.x = this.baseScale * this.walkScale;
         scale.y = this.baseScale * _loc1_;
         if(this.babyWait > 0)
         {
            this.babyWait -= FlxG.elapsed;
         }
         else if(health <= this.babyLife && action == IDLE)
         {
            Sounds.play(Sounds.HungryBreedSnd);
            this.babyLife -= maxHealth * 0.01;
            this.baseScale *= 0.99;
            this.NewBaby(2);
            this.NewBaby(1);
            this.NewBaby(0.5);
            ++this.babyLevel;
            this.babyWait = 1;
         }
         for each(_loc2_ in Global.badguys.GetGroup(Badguys.FOOD).members)
         {
            if(_loc2_ != null && _loc2_.exists && _loc2_.holder != null && _loc2_.holder.DistanceToGuy(this) < 10)
            {
               Sounds.play(Sounds.EatFoodSnd);
               --Global.foodLeft;
               _loc2_.exists = false;
               (_loc2_.holder as BaseMonster).escaping = false;
               (_loc2_.holder as BaseMonster).facing = LEFT + RIGHT - (_loc2_.holder as BaseMonster).facing;
               (_loc2_.holder as BaseMonster).advancing = !(_loc2_.holder as BaseMonster).advancing;
               _loc2_.holder = null;
            }
         }
      }
   }
}

