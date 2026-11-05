package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxGroup;
   import org.flixel.FlxText;
   
   public class Notice extends FlxGroup
   {
      
      public static const MAX_NOTICE:uint = 20;
      
      public var lastNotice:FlxText;
      
      public function Notice()
      {
         var n:FlxText = null;
         super();
         for(var i:int = 0; i < MAX_NOTICE; i++)
         {
            n = new FlxText(0,0,320,"");
            n.setFormat("volks",8,16777215,"center",1);
            n.visible = false;
            add(n);
         }
         this.lastNotice = null;
      }
      
      public function NoRepeatSay(s:String, color:int, x:Number, y:Number) : void
      {
         if(this.lastNotice == null || this.lastNotice.text != s || this.lastNotice.visible == false)
         {
            this.Say(s,color,x,y);
         }
      }
      
      public function Say(s:String, color:int, x:Number, y:Number) : void
      {
         var n:FlxText = null;
         var palest:FlxText = null;
         for each(n in members)
         {
            if(n.visible == false)
            {
               n.color = color;
               n.x = x - 160;
               n.y = y;
               n.text = s;
               n.visible = true;
               n.alpha = 1;
               this.lastNotice = n;
               return;
            }
            if(palest == null || n.alpha < palest.alpha)
            {
               palest = n;
            }
         }
         palest.color = color;
         palest.x = x - 160;
         palest.y = y;
         palest.text = s;
         palest.visible = true;
         palest.alpha = 1;
         this.lastNotice = palest;
      }
      
      override public function update() : void
      {
         var t:FlxText = null;
         for each(t in members)
         {
            if(t.visible)
            {
               t.y -= FlxG.elapsed * 30;
               t.alpha -= FlxG.elapsed / 3;
               if(t.alpha <= 0 || t.y < -20)
               {
                  t.visible = false;
               }
            }
         }
      }
   }
}

