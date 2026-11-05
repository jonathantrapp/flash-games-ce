package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxGroup;
   import org.flixel.FlxText;
   
   public class BigNotice extends FlxGroup
   {
      
      public var small:FlxText;
      
      public var big:FlxText;
      
      public var time:Number;
      
      public function BigNotice()
      {
         super();
         this.small = new FlxText(0,80,320,"");
         this.small.setFormat("volks",12,16777215,"center",1);
         this.small.scrollFactor.x = 0;
         this.small.scrollFactor.y = 0;
         this.small.visible = false;
         add(this.small);
         this.big = new FlxText(0,100,320,"");
         this.big.setFormat("volks",32,16777215,"center",1);
         this.big.scrollFactor.x = 0;
         this.big.scrollFactor.y = 0;
         this.big.visible = false;
         add(this.big);
      }
      
      public function Say(s:String, s2:String) : void
      {
         this.small.text = s;
         this.big.text = s2;
         this.small.visible = true;
         this.small.alpha = 0;
         this.big.visible = true;
         this.big.alpha = 0;
         this.time = 5;
      }
      
      override public function update() : void
      {
         this.time -= FlxG.elapsed;
         if(this.time > 2)
         {
            this.small.alpha += FlxG.elapsed;
            this.big.alpha += FlxG.elapsed;
         }
         else if(this.small.visible)
         {
            this.small.alpha -= FlxG.elapsed / 2;
            this.big.alpha -= FlxG.elapsed / 2;
            if(this.small.alpha == 0)
            {
               this.small.visible = false;
               this.big.visible = false;
            }
         }
      }
   }
}

