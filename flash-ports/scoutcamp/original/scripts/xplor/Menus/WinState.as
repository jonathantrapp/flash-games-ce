package xplor.Menus
{
   import org.flixel.FlxG;
   import org.flixel.FlxSprite;
   import org.flixel.FlxState;
   import org.flixel.FlxText;
   import xplor.Global;
   import xplor.Monster.Food;
   import xplor.Monster.Tower_Soapbox;
   import xplor.Sky;
   import xplor.Sounds;
   import xplor.TitleState;
   
   public class WinState extends FlxState
   {
      
      public static const btnY:int = 210;
      
      protected var sky:Sky;
      
      public var button:FlxSprite;
      
      public var buttonText:FlxText;
      
      public var info:FlxText;
      
      public var volSpr:FlxSprite;
      
      public var dAlpha:Number;
      
      public var food:Array;
      
      public function WinState()
      {
         super();
      }
      
      override public function create() : void
      {
         var _loc3_:FlxSprite = null;
         var _loc4_:FlxText = null;
         FlxG.timeScale = 1;
         Global.Init();
         Global.levelNum = 5;
         this.sky = new Sky();
         add(this.sky);
         this.food = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < 20)
         {
            _loc3_ = new FlxSprite(-40 + _loc1_ * 30,180 + Global.randRange(-20,20));
            _loc3_.loadGraphic(Food.FoodImage,true,true,16,16,true);
            _loc3_.frame = Global.randRange(0,5);
            _loc3_.velocity.x = -40;
            _loc3_.velocity.y = Global.randRange(-30,30);
            add(_loc3_);
            this.food.push(_loc3_);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < 2)
         {
            _loc3_ = new FlxSprite(10 + (320 - 20 - 13) * _loc1_,238 - 22);
            _loc3_.loadGraphic(Tower_Soapbox.TowerImage,true,true,13,22,true);
            _loc3_.addAnimation("fire",[0,1,0,2,3,4,5,6,7,6,5,4,3,2],18,true);
            _loc3_.play("fire");
            add(_loc3_);
            _loc1_++;
         }
         Sounds.playSong(0);
         var _loc2_:FlxText = new FlxText(0,2,320,"YOU WIN!");
         _loc2_.setFormat("volks",20,16777215,"center",1);
         add(_loc2_);
         _loc4_ = new FlxText(0,60,320,"The evil alien emperor... or commander... or... Hmm.\n\nWell anyway, that big green blob is defeated! " + "That\'s bound to be good for us!  Congratulations on a job well done.\n\nNow let\'s eat this chicken, french fries, " + "carrot, cheese, and hamburger!  It\'s picnic time!  I\'m sure they\'re still mostly clean.");
         _loc4_.setFormat("volks",12,16777215,"center",1);
         add(_loc4_);
         this.button = new FlxSprite((320 - 142) / 2,btnY);
         this.button.loadGraphic(TitleState.BtnImage,true,false,142,29,true);
         add(this.button);
         _loc4_ = new FlxText(0,btnY + 2,320,"Yay!");
         _loc4_.setFormat("volks",16,16777215,"center",1);
         this.buttonText = _loc4_;
         add(_loc4_);
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         add(this.volSpr);
         FlxG.mouse.show();
      }
      
      override public function update() : void
      {
         var _loc1_:FlxSprite = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for each(_loc1_ in this.food)
         {
            if(_loc1_.x < -20)
            {
               _loc1_.x += 20 * 30;
               _loc1_.y = 180 + Global.randRange(-20,20);
               _loc1_.velocity.y = Global.randRange(-30,30);
            }
            else if(_loc1_.y < 160)
            {
               _loc1_.velocity.y += FlxG.elapsed * 20;
            }
            else if(_loc1_.y > 200)
            {
               _loc1_.velocity.y -= FlxG.elapsed * 20;
            }
         }
         if(FlxG.mute)
         {
            this.volSpr.alpha = 0.5;
         }
         else
         {
            this.volSpr.alpha = 1;
         }
         _loc3_ = -1;
         if(this.button.overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            _loc3_ = 1;
            this.button.frame = 1;
            this.buttonText.x = 2;
            this.buttonText.y = btnY + 2 + 2;
         }
         else
         {
            this.button.frame = 0;
            this.buttonText.x = 0;
            this.buttonText.y = btnY + 2 + 0;
         }
         if(FlxG.mouse.x >= 320 - 8 && FlxG.mouse.y <= 12)
         {
            _loc3_ = 5;
         }
         if(FlxG.mouse.justPressed())
         {
            switch(_loc3_)
            {
               case 1:
                  FlxG.switchState(new TitleState());
                  break;
               case 5:
                  FlxG.mute = !FlxG.mute;
            }
         }
         if(FlxG.keys.justPressed("ESCAPE"))
         {
            FlxG.switchState(new TitleState());
         }
         super.update();
      }
   }
}

