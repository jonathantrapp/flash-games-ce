package xplor.Menus
{
   import org.flixel.FlxG;
   import org.flixel.FlxGroup;
   import org.flixel.FlxText;
   import xplor.Box;
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
      
      public function AddButton(x:int, y:int, width:int, txt:String) : void
      {
         var t:FlxText = null;
         var b:Box = new Box(this,x,y,width,20);
         this.btns.push(b);
         t = new FlxText(x - 1,y,width,txt);
         t.setFormat("volks",16,16777215,"center",1);
         t.scrollFactor.x = 0;
         t.scrollFactor.y = 0;
         add(t);
      }
      
      override public function update() : void
      {
         var i:int = 0;
         var b:Box = null;
         if(!visible)
         {
            return;
         }
         i = 0;
         for each(b in this.btns)
         {
            if(b.OnMe(FlxG.mouse.screenX,FlxG.mouse.screenY))
            {
               b.Bright(true);
               if(FlxG.mouse.justPressed())
               {
                  if(i == 0)
                  {
                     PlayState(FlxG.state).pause = false;
                     this.Toggle();
                  }
                  else if(i == 1)
                  {
                     PlayState(FlxG.state).pauseMsg = 1;
                  }
                  else if(i == 2)
                  {
                     PlayState(FlxG.state).pauseMsg = 2;
                  }
               }
            }
            else
            {
               b.Bright(false);
            }
            i++;
         }
      }
      
      public function Toggle() : void
      {
         visible = !visible;
      }
   }
}

