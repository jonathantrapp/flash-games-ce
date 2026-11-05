package xplor.Monster
{
   import org.flixel.*;
   import xplor.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   
   public class Wormy extends BaseMonster
   {
      
      public static var SkellyImage:Class = Wormy_SkellyImage;
      
      public var airTime:Number;
      
      public function Wormy(param1:int, param2:int)
      {
         super(param1,param2);
         loadGraphic(SkellyImage,true,true,18,16,true);
         addAnimation("walk",[4,5],10,true);
         addAnimation("jump",[3],10,true);
         addAnimation("disabledwalk",[0,1,2,1],10,true);
         addAnimation("disabledjump",[3],10,true);
         width = 5;
         offset.x = 6.5;
         speed = 20;
         height = 14;
         name = "Wormy";
         this.Init(param1,param2);
      }
      
      public static function Life(param1:int) : int
      {
         return 3 + param1 * 1.8;
      }
      
      public static function Money(param1:int) : int
      {
         return 5 + param1 * 1.1;
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
         immune = true;
      }
      
      override public function BasicUpdate() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(action == IDLE)
         {
            if(WillBumpWall() || isTouching(LEFT) || isTouching(RIGHT))
            {
               facing = LEFT + RIGHT - facing;
            }
            if(facing == LEFT)
            {
               velocity.x = -speed;
            }
            else
            {
               velocity.x = speed;
            }
            if(speedUp > 0)
            {
               if(facing == LEFT)
               {
                  velocity.x = -40;
               }
               else
               {
                  velocity.x = 40;
               }
            }
            if(slowed > 0)
            {
               velocity.x *= slowRate;
            }
            if(escaping)
            {
               velocity.x *= 1 - Profile.skills[SkillDef.REFRIGERATION] * 0.05;
            }
            if(isTouching(FLOOR))
            {
               if(disabled > 0)
               {
                  immune = false;
                  play("disabledwalk");
               }
               else
               {
                  immune = true;
                  play("walk");
               }
               this.airTime = 0;
               _loc1_ = (x + width / 2) / 16;
               _loc3_ = x + width / 2;
               _loc1_ *= 16;
               if(GoalIsUp() && (Boolean(_loc4_ = CanJump())))
               {
                  if(facing == LEFT && _loc3_ <= _loc1_ + 8 || facing == RIGHT && _loc3_ >= _loc1_ + 8)
                  {
                     x = _loc1_ + 8 - width / 2;
                     if(facing == LEFT && x + width / 2 > _loc1_ + 8)
                     {
                        velocity.x = -35;
                     }
                     else
                     {
                        velocity.x = 35;
                     }
                     velocity.y = -90 - 30 * (_loc4_ - 1);
                     action = JUMP;
                     immune = false;
                     play("jump");
                  }
               }
            }
            else if(!OnSlope())
            {
               this.airTime -= FlxG.elapsed;
               _loc1_ = (x + width / 2) / 16;
               _loc2_ = (y + height - 1) / 16;
               if(Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,_loc2_) == 0 && Global.level.GetLayer(Level.LAYER_SOLID).getTile(_loc1_,_loc2_ + 1) == 0)
               {
                  immune = false;
                  play("jump");
               }
            }
            else
            {
               this.airTime = 0.5;
               if(disabled > 0)
               {
                  immune = false;
                  play("disabledwalk");
               }
               else
               {
                  immune = true;
                  play("walk");
               }
            }
         }
         else if(action == JUMP)
         {
            immune = false;
            if(facing == LEFT)
            {
               velocity.x = -35;
            }
            else
            {
               velocity.x = 35;
            }
            if(isTouching(FLOOR))
            {
               action = IDLE;
               if(disabled > 0)
               {
                  immune = false;
                  play("disabledwalk");
               }
               else
               {
                  immune = true;
                  play("walk");
               }
            }
         }
      }
   }
}

