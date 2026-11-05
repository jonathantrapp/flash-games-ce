package xplor.Menus
{
   import org.flixel.*;
   import xplor.*;
   
   public class LevelTip extends FlxSprite
   {
      
      public static const NONE:int = 0;
      
      public static const BEWARE:int = 1;
      
      public static const SPECIAL:int = 2;
      
      protected var BorderImage:Class = LevelTip_BorderImage;
      
      protected var ButtonImage:Class = LevelTip_ButtonImage;
      
      protected var SpecialImage:Class = LevelTip_SpecialImage;
      
      public var proTip:Array = new Array("You can scroll the view with WASD, arrow keys, or the numeric keypad!","Hold CTRL to ensure you click aliens instead of towers.","Hold SHIFT to ensure you click towers instead of aliens.","Press ESC to exit or restart the battle.","Tap SPACE to freeze time.  Tap again to return to your last speed.","Mouse over the alien icons at the top of the screen to see what\'s coming up!","Click the speaker icon in the upper right to toggle sound & music.","Key shortcut: Press IOKL or 7913 to build the four tower types!","Key shortcut: Press U or numpad-0 to upgrade a tower!","Key shortcut: Press CTRL-Z to sell a tower!","Key shortcut: Press + and - to change the game speed!","Drag the slider in the top right to adjust game speed.","Losing levels still earns you skill points, so upgrade your skills!","Selling towers gives you back half the money you put into them.","Wormies can be Crippled, or they can be shot in mid-air by fast towers!","Click on an enemy to make your towers focus their fire on it."
      ,"Slowing is less useful near jumps - all enemies jump at the same speed.","Replay levels to rack up more XP for skill points!","Enemies in higher levels are worth more XP.","If your skills aren\'t working out, click Reset Skills for a full refund!","You can\'t build towers on slopes.  They\'re not zoned for it.","If there are less aliens left than food items... you\'re about to win!","The yellow bar in the top right shows your XP. Fill it up for a skill point!","Destroy aliens to get XP, which in turn gets you skill points!","Think ahead and build the towers you need for upcoming waves.","Build towers in places aliens will cross back and forth for extra hits.","Make sure you build towers in areas where they have a clear line of sight.","Click on the alien boxes at the top of the screen to send waves early!");
      
      public var levelTip:Array = new Array(new Array(SPECIAL,0,"Desert Gulch","Scouts! To battlestations! Aliens are " + "coming to steal our precious food!\n\n" + "Use the arrow keys to scroll your view. " + "Click on open ground to open the Build " + "Menu, then click the Rock Tower icon to " + "build one! Spend all the money you get " + "to make sure no filthy aliens grab our " + "grub!\n\n\n" + "Now click DEFEND and get going!"),new Array(SPECIAL,1,"Burns Butte","The aliens just keep coming!\n\n" + "On the map screen, click on Skills to spend your hard-earned skill points and " + "get more powerful towers. You\'re going to need them!\n\n" + "During battle, click on an existing tower to see the Upgrade Menu. " + "An upgraded tower is often better than two un-upgraded ones!\n\n" + "You can upgrade a tower five times, and they become incredibly powerful when you do."),new Array(BEWARE,5,"Quail Hollow","If you get stuck here, go back to the Skills screen and try " + "a new set of skills. There\'s no penalty for trying again.  In fact, " + "you\'ll earn XP even if you lose, so the more you play, the more skills you get!\n\n" + "Press ESC while playing to get the option to exit to the map or restart the battle.\n\n" + "You\'ll meet a Beasty here... they\'re huge and nearly indestructible. Good luck with that!")
      ,new Array(SPECIAL,2,"Dusty Road","We\'re out in the flatlands now.  You can see the aliens coming for miles!\n\n" + "Some towers (like Roly Poly and Shocker) are better for large groups of weak enemies, " + "while others (like Rock Tower and Slingshot) are better for tough individuals.\n\n" + "Plan accordingly and watch the monster display up top to know what\'s coming next! " + "If you get tired of waiting, you can click on a box to send monsters early..." + "It\'s a very risky move, though!"),new Array(BEWARE,3,"Wormy Peak","Oh no! The aliens have followed us up into the mountains, and they brought Wormies!" + "\n\nWormies burrow through the ground, so you can\'t hit them. " + "But there is hope! You can briefly hit them when they jump, if your towers shoot quickly. " + "A better option is a Crippler tower. It will force the Wormies out into the light of day! " + "Snow Forts with the Brain Freeze skill can work too.\n\nRemember, you can " + "exit the battle and change skills!"),new Array(NONE
      ,9,"Frosty Fjord","Will we ever get to just picnic in peace?\n\nIt seems like the further we go, the tougher " + "these aliens get. Sometimes just a slightly different set of starting towers makes the " + "difference, so try everything!  And if you fail, update your skills and do it again!"),new Array(NONE,9,"Reprieve Ravine","It looks like we\'ve managed to escape the Wormies for the moment.  But here come " + "a ton of other aliens!"),new Array(NONE,9,"Cave Entrance","We\'ve reached the entrance of Great Big Caverns, but aliens are just pouring out of it! " + "If we want to go inside, we\'ll have to get past them.\n\n" + "What?  Why do we want to go inside?  Um... well, it\'s educational, you know!  Stalagmites and " + "whatnot.\n\nDon\'t forget you can speed up or slow down the game by moving the slider in the upper right " + "of the screen.\n\nNow let\'s get moving!"),new Array(BEWARE,4,"Dark Descent","It\'s kind of spooky in here... What was that zipping by!?\n\n" + "Uh oh, it\'s a Speedy.  They\'re fast like Squirmies, but they also accelerate everyone around them! " + "You should focus your fire on Speedies, or you\'ll have Beefies stomping at you at fifty miles an hour. " + "It\'s not a pretty sight.\n\n" + "Remember, you can click on an alien to tell your towers to focus on it, and you can tap SPACE to " + "freeze time if you\'re having trouble keeping up!  Tap it again to resume.")
      ,new Array(BEWARE,6,"Groovy Grotto","Oh no, the most dangerous aliens yet... Blinkies. You *must* focus your fire on these beasts, " + "or they will heal everyone around them so fast you won\'t be able to do any damage.  Watch out for them!" + "\n\nWatch for cave crystals too.  They don\'t do anything, but they\'re pretty."),new Array(NONE,9,"Twisty Passages","You find yourself in a maze of twisty passages, all alike."),new Array(BEWARE,6,"Blinky Barrow","This place is chock-full of Blinkies.  When you have multiple Blinkies together, focused fire " + "might not be enough.\n\nA Crippler can help a lot by disabling their healing powers.\n\nUpgraded Slingshots are " + "also very effective - they hit so hard that they may be able to vaporize aliens before they can even be " + "healed!"),new Array(BEWARE,8,"Spooky Forest","Yikes... it\'s not just the woods that are scary here. Here come some Scaries! " + "These things are so immensely terrifying that scouts can\'t even fire when they see one.\n\n" + "But don\'t fear!  Their scariness isn\'t real, it\'s an alien illusion. You can disable it. " + "Of course, how will you do that if they scare your Crippler?\n\nJust remember, their fear only " + "reaches a certain distance, so longer-range towers can beat them!")
      ,new Array(NONE,9,"Under The Pines","Surely we\'ll be safe camping up here on this floating rock!\n\nWhat could go wrong?"),new Array(NONE,9,"Jack & Jill","Up high didn\'t work, let\'s camp out at the bottom of this hill.\n\nAUGH, HERE THEY COME!"),new Array(NONE,9,"Last Stand","You know... I\'m not sure why we traveled all around the park, but now that we\'re right near the " + "Great Big Hole, it sure seems like the aliens are trying hard to keep us out of it.  Hmm!\n\n" + "Let\'s blast our way through these guys and find out what they\'re hiding in there!"),new Array(BEWARE,7,"It\'s Hungry","Oh my.  This could be bad."));
      
      public var words:Array;
      
      public var bonus:FlxSprite;
      
      public var defend:FlxSprite;
      
      public var title:FlxText;
      
      public function LevelTip(param1:int)
      {
         var _loc2_:int = 0;
         var _loc3_:FlxText = null;
         super();
         scrollFactor.x = 0;
         scrollFactor.y = 0;
         this.words = new Array();
         loadGraphic(this.BorderImage,false,false,208,192,true);
         x = 16;
         y = (240 - 192) / 2;
         this.bonus = new FlxSprite();
         this.bonus.scrollFactor.x = 0;
         this.bonus.scrollFactor.y = 0;
         switch(this.levelTip[param1][0])
         {
            case SPECIAL:
               this.bonus.loadGraphic(this.SpecialImage,true,false,84,129,true);
               this.bonus.frame = this.levelTip[param1][1];
               this.bonus.x = x + 208 + 3;
               this.bonus.y = y + 3;
               break;
            case BEWARE:
               this.bonus.loadGraphic(Hud.BewareImage,true,false,76,144,true);
               this.bonus.frame = this.levelTip[param1][1];
               this.bonus.x = x + 208 + 8;
               this.bonus.y = y + 3;
               break;
            case NONE:
               this.bonus = null;
         }
         this.title = new FlxText(x,y - 20,208,"- " + this.levelTip[param1][2] + " -");
         this.title.setFormat("",16,16777215,"center",1);
         this.title.scrollFactor.x = 0;
         this.title.scrollFactor.y = 0;
         _loc2_ = 0;
         while(_loc2_ < 1)
         {
            _loc3_ = new FlxText(x + 4,y + 2 + _loc2_ * 11,200,this.levelTip[param1][3 + _loc2_]);
            _loc3_.setFormat("",8,16777215,"left",1);
            _loc3_.scrollFactor.x = 0;
            _loc3_.scrollFactor.y = 0;
            this.words.push(_loc3_);
            _loc2_++;
         }
         var _loc4_:int = Global.randRange(0,this.proTip.length);
         _loc3_ = new FlxText(x + 4,y + 166,200,this.proTip[_loc4_]);
         _loc3_.setFormat("",8,16777215,"left",1);
         _loc3_.scrollFactor.x = 0;
         _loc3_.scrollFactor.y = 0;
         this.words.push(_loc3_);
         this.defend = new FlxSprite(x + 208 + 3,y + 163);
         this.defend.loadGraphic(this.ButtonImage,true,false,76,29,true);
         this.defend.scrollFactor.x = 0;
         this.defend.scrollFactor.y = 0;
      }
      
      override public function draw() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         super.draw();
         if(this.bonus != null)
         {
            this.bonus.draw();
         }
         _loc1_ = 0;
         while(_loc1_ < this.words.length)
         {
            this.words[_loc1_].draw();
            _loc1_++;
         }
         this.title.draw();
         this.defend.draw();
      }
      
      public function Clear() : void
      {
      }
      
      override public function update() : void
      {
         if(this.defend.overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            this.defend.frame = 1;
            if(FlxG.mouse.justPressed())
            {
               PlayState(FlxG.state).situation = 10;
            }
         }
         else
         {
            this.defend.frame = 0;
         }
      }
   }
}

