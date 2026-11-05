package xplor.TileSets
{
   import org.flixel.FlxTilemap;
   import xplor.Global;
   
   public class TileDef
   {
      
      public static const MIDDLE:uint = 0;
      
      public static const TOP:uint = 1;
      
      public static const BOTTOM:uint = 2;
      
      public static const LEFT:uint = 3;
      
      public static const RIGHT:uint = 4;
      
      public static const TOPLEFT:uint = 5;
      
      public static const TOPRIGHT:uint = 6;
      
      public static const BOTTOMLEFT:uint = 7;
      
      public static const BOTTOMRIGHT:uint = 8;
      
      public static const LEFTANDRIGHT:uint = 9;
      
      public static const LEFTRIGHTTOP:uint = 10;
      
      public static const LEFTRIGHTBOTTOM:uint = 11;
      
      public static const SOLO:uint = 12;
      
      public static const INSIDETOPLEFT:uint = 13;
      
      public static const INSIDETOPRIGHT:uint = 14;
      
      public static const INSIDEBOTTOMLEFT:uint = 15;
      
      public static const INSIDEBOTTOMRIGHT:uint = 16;
      
      public static const INSIDETOPBOTH:uint = 17;
      
      public static const INSIDEBOTTOMBOTH:uint = 18;
      
      public static const INSIDELEFTBOTH:uint = 19;
      
      public static const INSIDERIGHTBOTH:uint = 20;
      
      public static const INSIDETOPLEFT_BOTTOMRIGHT:uint = 21;
      
      public static const INSIDETOPRIGHT_BOTTOMLEFT:uint = 22;
      
      public static const INSIDEALLBUT_TOPLEFT:uint = 23;
      
      public static const INSIDEALLBUT_TOPRIGHT:uint = 24;
      
      public static const INSIDEALLBUT_BOTTOMLEFT:uint = 25;
      
      public static const INSIDEALLBUT_BOTTOMRIGHT:uint = 26;
      
      public static const INSIDEALL:uint = 27;
      
      public static const TOPANDBOTTOM:uint = 28;
      
      public static const TOPBOTTOMLEFT:uint = 29;
      
      public static const TOPBOTTOMRIGHT:uint = 30;
      
      public static const EXTRA:uint = 31;
      
      public static const TOTAL_DEFS:uint = 32;
      
      public static const ALL_LEFTS:uint = 0;
      
      public static const ALL_RIGHTS:uint = 1;
      
      public static const ALL_TOPS:uint = 2;
      
      public static const ALL_BOTTOMS:uint = 3;
      
      public var tiles:Array;
      
      public var layer:uint;
      
      public var connectsToAny:Boolean;
      
      public function TileDef(param1:uint, param2:int, param3:int)
      {
         var _loc4_:int = 0;
         super();
         this.layer = param1;
         this.tiles = new Array();
         _loc4_ = 0;
         while(_loc4_ < TOTAL_DEFS)
         {
            this.tiles[_loc4_ * 2] = param2;
            this.tiles[_loc4_ * 2 + 1] = param3;
            _loc4_++;
         }
         this.connectsToAny = false;
      }
      
      public function Set(param1:uint, param2:int, param3:int) : void
      {
         this.tiles[param1 * 2] = param2;
         this.tiles[param1 * 2 + 1] = param3;
      }
      
      public function SetAll(param1:uint, param2:int, param3:int) : void
      {
         var _loc8_:int = 0;
         var _loc4_:Array = new Array(LEFT,TOPLEFT,BOTTOMLEFT,TOPBOTTOMLEFT);
         var _loc5_:Array = new Array(RIGHT,TOPRIGHT,BOTTOMRIGHT,TOPBOTTOMRIGHT);
         var _loc6_:Array = new Array(TOP,TOPLEFT,TOPRIGHT,TOPBOTTOMLEFT,TOPBOTTOMRIGHT,TOPANDBOTTOM);
         var _loc7_:Array = new Array(BOTTOM,BOTTOMLEFT,BOTTOMRIGHT,TOPBOTTOMLEFT,TOPBOTTOMRIGHT,TOPANDBOTTOM);
         switch(param1)
         {
            case ALL_TOPS:
               for each(_loc8_ in _loc6_)
               {
                  this.Set(_loc8_,param2,param3);
               }
               break;
            case ALL_BOTTOMS:
               for each(_loc8_ in _loc7_)
               {
                  this.Set(_loc8_,param2,param3);
               }
               break;
            case ALL_LEFTS:
               for each(_loc8_ in _loc4_)
               {
                  this.Set(_loc8_,param2,param3);
               }
               break;
            case ALL_RIGHTS:
               for each(_loc8_ in _loc5_)
               {
                  this.Set(_loc8_,param2,param3);
               }
         }
      }
      
      public function IsThis(param1:int, param2:int, param3:Boolean = false) : Boolean
      {
         if(param1 < 0 || param2 < 0 || param1 >= Global.level.width || param2 >= Global.level.height)
         {
            return true;
         }
         return this.IsThis2((Global.level.layers[this.layer] as FlxTilemap).getTile(param1,param2),param3);
      }
      
      public function IsThis2(param1:int, param2:Boolean = false) : Boolean
      {
         var _loc3_:int = 0;
         if(param2 && this.connectsToAny && param1 != 0)
         {
            return true;
         }
         _loc3_ = 0;
         while(_loc3_ < TOTAL_DEFS)
         {
            if(param1 >= this.tiles[_loc3_ * 2] && param1 < this.tiles[_loc3_ * 2] + this.tiles[_loc3_ * 2 + 1])
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function GetIt(param1:int) : int
      {
         return this.tiles[param1 * 2] + int(Global.randRange(0,this.tiles[param1 * 2 + 1]));
      }
      
      public function ChooseTile(param1:int, param2:int) : int
      {
         var _loc3_:int = 0;
         var _loc4_:Array = new Array();
         _loc4_[0] = this.IsThis(param1 + 1,param2,true);
         _loc4_[1] = this.IsThis(param1 + 1,param2 + 1,true);
         _loc4_[2] = this.IsThis(param1,param2 + 1,true);
         _loc4_[3] = this.IsThis(param1 - 1,param2 + 1,true);
         _loc4_[4] = this.IsThis(param1 - 1,param2,true);
         _loc4_[5] = this.IsThis(param1 - 1,param2 - 1,true);
         _loc4_[6] = this.IsThis(param1,param2 - 1,true);
         _loc4_[7] = this.IsThis(param1 + 1,param2 - 1,true);
         if(Boolean(_loc4_[0]) && Boolean(_loc4_[2]) && Boolean(_loc4_[4]) && Boolean(_loc4_[6]))
         {
            if(Boolean(_loc4_[1]) && Boolean(_loc4_[3]) && Boolean(_loc4_[5]) && Boolean(_loc4_[7]))
            {
               return this.GetIt(MIDDLE);
            }
            if(Boolean(_loc4_[1]) && Boolean(_loc4_[3]) && Boolean(_loc4_[5]))
            {
               return this.GetIt(INSIDETOPRIGHT);
            }
            if(Boolean(_loc4_[1]) && Boolean(_loc4_[3]) && Boolean(_loc4_[7]))
            {
               return this.GetIt(INSIDETOPLEFT);
            }
            if(Boolean(_loc4_[1]) && Boolean(_loc4_[5]) && Boolean(_loc4_[7]))
            {
               return this.GetIt(INSIDEBOTTOMLEFT);
            }
            if(Boolean(_loc4_[3]) && Boolean(_loc4_[5]) && Boolean(_loc4_[7]))
            {
               return this.GetIt(INSIDEBOTTOMRIGHT);
            }
            if(Boolean(_loc4_[1]) && Boolean(_loc4_[3]))
            {
               return this.GetIt(INSIDETOPBOTH);
            }
            if(Boolean(_loc4_[3]) && Boolean(_loc4_[5]))
            {
               return this.GetIt(INSIDERIGHTBOTH);
            }
            if(Boolean(_loc4_[5]) && Boolean(_loc4_[7]))
            {
               return this.GetIt(INSIDEBOTTOMBOTH);
            }
            if(Boolean(_loc4_[1]) && Boolean(_loc4_[7]))
            {
               return this.GetIt(INSIDELEFTBOTH);
            }
            if(Boolean(_loc4_[1]) && Boolean(_loc4_[5]))
            {
               return this.GetIt(INSIDETOPRIGHT_BOTTOMLEFT);
            }
            if(Boolean(_loc4_[3]) && Boolean(_loc4_[7]))
            {
               return this.GetIt(INSIDETOPLEFT_BOTTOMRIGHT);
            }
            if(_loc4_[1])
            {
               return this.GetIt(INSIDEALLBUT_BOTTOMRIGHT);
            }
            if(_loc4_[3])
            {
               return this.GetIt(INSIDEALLBUT_BOTTOMLEFT);
            }
            if(_loc4_[5])
            {
               return this.GetIt(INSIDEALLBUT_TOPLEFT);
            }
            if(_loc4_[7])
            {
               return this.GetIt(INSIDEALLBUT_TOPRIGHT);
            }
            return this.GetIt(INSIDEALL);
         }
         if(Boolean(_loc4_[0]) && Boolean(_loc4_[2]) && Boolean(_loc4_[4]))
         {
            return this.GetIt(TOP);
         }
         if(Boolean(_loc4_[0]) && Boolean(_loc4_[4]) && Boolean(_loc4_[6]))
         {
            return this.GetIt(BOTTOM);
         }
         if(Boolean(_loc4_[0]) && Boolean(_loc4_[2]) && Boolean(_loc4_[6]))
         {
            return this.GetIt(LEFT);
         }
         if(Boolean(_loc4_[2]) && Boolean(_loc4_[4]) && Boolean(_loc4_[6]))
         {
            return this.GetIt(RIGHT);
         }
         if(Boolean(_loc4_[0]) && Boolean(_loc4_[2]))
         {
            return this.GetIt(TOPLEFT);
         }
         if(Boolean(_loc4_[0]) && Boolean(_loc4_[4]))
         {
            return this.GetIt(TOPANDBOTTOM);
         }
         if(Boolean(_loc4_[0]) && Boolean(_loc4_[6]))
         {
            return this.GetIt(BOTTOMLEFT);
         }
         if(Boolean(_loc4_[2]) && Boolean(_loc4_[4]))
         {
            return this.GetIt(TOPRIGHT);
         }
         if(Boolean(_loc4_[2]) && Boolean(_loc4_[6]))
         {
            return this.GetIt(LEFTANDRIGHT);
         }
         if(Boolean(_loc4_[4]) && Boolean(_loc4_[6]))
         {
            return this.GetIt(BOTTOMRIGHT);
         }
         if(_loc4_[0])
         {
            return this.GetIt(TOPBOTTOMLEFT);
         }
         if(_loc4_[2])
         {
            return this.GetIt(LEFTRIGHTTOP);
         }
         if(_loc4_[4])
         {
            return this.GetIt(TOPBOTTOMRIGHT);
         }
         if(_loc4_[6])
         {
            return this.GetIt(LEFTRIGHTBOTTOM);
         }
         return this.GetIt(SOLO);
      }
   }
}

