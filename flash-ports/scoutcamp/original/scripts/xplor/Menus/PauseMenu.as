package xplor.Menus
{
   import org.flixel.FlxG;
   import org.flixel.FlxGroup;
   import org.flixel.FlxText;
   import xplor.Box;
   import xplor.Global;
   import xplor.PlayState;
   
   public class PauseMenu extends FlxGroup
   {
      
      public var btns:Array;
      
      public var toolTip:ToolTip;
      
      public var page:int;
      
      public function PauseMenu()
      {
         super();
         this.btns = new Array();
         this.AddButton(110,50,100,"Continue");
         this.AddButton(110,90,100,"Restart");
         this.AddButton(110,130,100,"Exit");
      }
      
      public function AddButton(param1:int, param2:int, param3:int, param4:String) : void
      {
         var _loc6_:FlxText = null;
         var _loc5_:Box = new Box(this,param1,param2,param3,20);
         this.btns.push(_loc5_);
         _loc6_ = new FlxText(param1 - 1,param2,param3,param4);
         _loc6_.setFormat("volks",16,16777215,"center",1);
         _loc6_.scrollFactor.x = 0;
         _loc6_.scrollFactor.y = 0;
         add(_loc6_);
      }
      
      override public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Box = null;
         if(!visible)
         {
            return;
         }
         _loc1_ = 0;
         for each(_loc2_ in this.btns)
         {
            if(_loc2_.OnMe(FlxG.mouse.screenX,FlxG.mouse.screenY))
            {
               _loc2_.Bright(true);
               if(FlxG.mouse.justPressed())
               {
                  if(_loc1_ == 0)
                  {
                     PlayState(FlxG.state).pause = false;
                     Global.player.Pause();
                     this.Toggle();
                  }
                  else if(_loc1_ == 1)
                  {
                     PlayState(FlxG.state).pauseMsg = 1;
                  }
                  else if(_loc1_ == 2)
                  {
                     PlayState(FlxG.state).pauseMsg = 2;
                  }
               }
            }
            else
            {
               _loc2_.Bright(false);
            }
            _loc1_++;
         }
      }
      
      public function Toggle() : void
      {
         visible = !visible;
      }
   }
}

