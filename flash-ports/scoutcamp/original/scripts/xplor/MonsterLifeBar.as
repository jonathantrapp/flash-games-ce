package xplor
{
   import org.flixel.FlxSprite;
   import org.flixel.FlxText;
   import xplor.Monster.BaseMonster;
   
   public class MonsterLifeBar extends FlxSprite
   {
      
      public var back:FlxSprite;
      
      public var meter:FlxSprite;
      
      public var name:FlxText;
      
      public var who:BaseMonster;
      
      public function MonsterLifeBar()
      {
         super();
         this.back = new FlxSprite();
         this.back.makeGraphic(20,6,4278190080,true);
         this.meter = new FlxSprite();
         this.meter.makeGraphic(18,4,4294910498,true);
         this.meter.origin.x = 0;
         this.name = new FlxText(0,0,200,"");
         this.name.setFormat("volks",8,16777215,"center",1);
         this.who = null;
      }
      
      override public function draw() : void
      {
         if(visible)
         {
            this.back.draw();
            this.meter.draw();
            this.name.draw();
         }
      }
      
      public function On(param1:BaseMonster) : void
      {
         if(param1 == null || param1.health == 0 || !param1.exists)
         {
            this.who = null;
         }
         else
         {
            this.who = param1;
         }
      }
      
      override public function update() : void
      {
         super.update();
         if(this.who == null)
         {
            visible = false;
         }
         else
         {
            visible = true;
            this.back.y = this.who.y + this.who.height + 2;
            this.meter.y = this.who.y + this.who.height + 3;
            this.name.y = this.who.y - 10;
            this.back.x = this.who.x + this.who.width / 2 - 10;
            this.meter.x = this.who.x + this.who.width / 2 - 9;
            this.name.x = this.who.x + this.who.width / 2 - 100;
            this.name.text = this.who.name;
            this.meter.scale.x = this.who.health / this.who.maxHealth;
         }
      }
   }
}

