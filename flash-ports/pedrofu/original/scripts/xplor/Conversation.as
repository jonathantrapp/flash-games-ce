package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxGroup;
   import org.flixel.FlxObject;
   import org.flixel.FlxPoint;
   import org.flixel.FlxSprite;
   import org.flixel.FlxText;
   import xplor.Monster.BaseMonster;
   import xplor.Monster.Robot;
   import xplor.Monster.Yak_Master;
   
   public class Conversation extends FlxGroup
   {
      
      public static var BubbleImage:Class = Conversation_BubbleImage;
      
      public static var TutorialImage:Class = Conversation_TutorialImage;
      
      public var bubble:FlxSprite;
      
      public var words:FlxText;
      
      public var status:int;
      
      public var event:int;
      
      public var otherGuy:FlxSprite;
      
      public var camPt:FlxPoint;
      
      public var hint:FlxText;
      
      public var hintDelay:Number;
      
      public var hintFlicker:Number;
      
      public var tutorial:FlxSprite;
      
      public function Conversation()
      {
         super();
         this.bubble = new FlxSprite();
         this.bubble.loadGraphic(BubbleImage,false,true,213,106,true);
         this.bubble.visible = false;
         add(this.bubble);
         this.words = new FlxText(0,0,202,"");
         this.words.setFormat("volks",14,0,"center",0);
         this.words.visible = false;
         add(this.words);
         this.camPt = new FlxPoint();
         this.hint = new FlxText(0,5,320,"Press X, C, or SPACE to continue");
         this.hint.setFormat("volks",12,16776960,"center",1);
         this.hint.visible = false;
         this.hint.scrollFactor.x = 0;
         this.hint.scrollFactor.y = 0;
         add(this.hint);
         this.tutorial = null;
      }
      
      public function SetBubble(who:FlxSprite, x:int, y:int, facing:int, text:String) : void
      {
         this.words.text = text;
         this.words.alpha = 0;
         this.bubble.facing = facing;
         if(who != null)
         {
            this.bubble.x = who.x;
            this.bubble.y = who.y - 106;
            if(this.bubble.facing == FlxObject.RIGHT)
            {
               this.bubble.x -= 22;
            }
            else
            {
               this.bubble.x -= 181;
            }
         }
         else
         {
            this.bubble.x = x;
            this.bubble.y = y;
         }
         this.words.x = this.bubble.x + 4;
         this.words.y = this.bubble.y + 4 + 40 - this.words.frameHeight / 2;
      }
      
      public function Setup(event:int, badguy:FlxSprite) : void
      {
         var f:int = 0;
         Global.conversation = true;
         this.status = 0;
         this.event = event;
         this.bubble.visible = true;
         this.words.visible = true;
         this.hintDelay = 0;
         this.hintFlicker = 0;
         switch(event)
         {
            case 0:
               Global.pedro.play("idle");
               badguy.play("talk");
               this.otherGuy = badguy;
               this.SetBubble(badguy,0,0,FlxObject.LEFT,"You have trespassed on the ancient lands of the Yak Clan!  You shall be destroyed!");
               break;
            case 1:
               this.hintDelay = 6;
               Global.pedro.play("talk");
               this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"Brrrr... I knew it was a mistake to fly the blimp in my pajamas! Crashing it wasn\'t great either.");
               break;
            case 2:
               Global.pedro.play("idle");
               badguy.play("talk");
               this.otherGuy = badguy;
               this.SetBubble(badguy,0,0,FlxObject.LEFT,"I have carefully ensconced this artifact from the sky in my Precious Things vault! You may not have it!");
               break;
            case 3:
               Global.pedro.play("talk");
               this.otherGuy = null;
               this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"Wow... I guess she\'s not flying again. On the plus side, the wreckage is arranged in nice neat platforms!");
               break;
            case 4:
               badguy.play("talk");
               this.otherGuy = badguy;
               f = int(FlxObject.LEFT);
               if(badguy.x < Global.pedro.x)
               {
                  f = int(FlxObject.RIGHT);
               }
               this.SetBubble(badguy,0,0,f,"We are the Ninja Brothers! We are visiting from Japan! Let us engage in the local custom of pummeling you!");
               break;
            case 5:
               badguy.play("talk");
               Global.pedro.play("idle");
               this.otherGuy = badguy;
               this.SetBubble(badguy,0,0,FlxObject.LEFT,"You have shown great power, strange burro. But your journey ends here. No stranger may enter the Ancient Temple of the Yak Clan!");
               break;
            case 6:
               badguy.play("talk");
               Global.pedro.play("idle");
               this.otherGuy = badguy;
               this.SetBubble(badguy,0,0,FlxObject.LEFT,"Puny burro! You cannot scale the mighty walls of the Yak Clan Temple! I shall use you for target practice!");
               break;
            case 7:
               badguy.play("talk");
               Global.pedro.play("idle");
               this.otherGuy = badguy;
               this.SetBubble(badguy,0,0,FlxObject.RIGHT,"Gulp.");
               break;
            case 8:
               badguy.play("talk");
               Global.pedro.play("idle");
               this.otherGuy = badguy;
               this.SetBubble(badguy,0,0,FlxObject.LEFT,"Alright, donkey! You think you\'re so tough? Face my Gauntlet of Death!");
               break;
            case 9:
               Global.pedro.acceleration.y = 400;
               badguy.play("talk");
               Global.pedro.play("idle");
               this.otherGuy = badguy;
               this.SetBubble(badguy,0,0,FlxObject.LEFT,"Your skills are most impressive. But now I have built a Mighty Robot to destroy you! I\'m quite good with my hands.");
               break;
            case 10:
               Global.pedro.acceleration.y = 400;
               badguy.play("talk");
               Global.pedro.play("idle");
               this.otherGuy = badguy;
               this.SetBubble(badguy,0,0,FlxObject.LEFT,"You know, this is getting ridiculous. I\'m half-tempted to not even offer bonus rewards in this Gauntlet of Death!");
               break;
            case 11:
               badguy.play("idle");
               Global.pedro.play("talk");
               this.otherGuy = badguy;
               this.SetBubble(Global.pedro,0,0,FlxObject.LEFT,"Alright, that\'s IT!  Hand over the mail so I can go home!");
         }
         FlxG.camera.follow(null);
      }
      
      public function End() : void
      {
         Global.conversation = false;
         FlxG.camera.follow(Global.pedro);
         this.bubble.visible = false;
         this.words.visible = false;
      }
      
      public function ButtonHit() : void
      {
         var f:int = 0;
         var g:BaseMonster = null;
         ++this.status;
         this.hintDelay = 0;
         switch(this.event)
         {
            case 0:
               if(this.status == 1)
               {
                  this.otherGuy.play("idle");
                  Global.pedro.play("talk");
                  this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"Ooh... would you mind if I just passed through? I\'ve lost a bunch of mail, and I just need to pick it up.");
               }
               else if(this.status == 2)
               {
                  Global.pedro.play("idle");
                  this.otherGuy.play("talk");
                  this.SetBubble(this.otherGuy,0,0,FlxObject.LEFT,"NEVER!!!!!!");
               }
               else
               {
                  this.End();
               }
               break;
            case 1:
               if(this.status == 1)
               {
                  this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"Boy, the boss is gonna kill me... I better make my way to the wreck and find all the fan mail!");
               }
               else if(this.status == 2)
               {
                  this.tutorial = new FlxSprite(0,0,TutorialImage);
                  this.tutorial.scrollFactor.x = 0;
                  this.tutorial.scrollFactor.y = 0;
                  add(this.tutorial);
                  this.bubble.visible = false;
                  this.words.visible = false;
                  Global.pedro.play("idle");
               }
               else
               {
                  PlayState(FlxG.state).AddHelpers();
                  this.tutorial.visible = false;
                  this.End();
               }
               break;
            case 2:
               if(this.status == 1)
               {
                  this.otherGuy.play("talkidle");
                  Global.pedro.play("talk");
                  this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"But that\'s a fan letter to Boys\' Life!  Look at it!  It\'s not addressed to you!");
               }
               else if(this.status == 2)
               {
                  Global.pedro.play("idle");
                  this.otherGuy.play("talk");
                  this.SetBubble(this.otherGuy,0,0,FlxObject.LEFT,"Your symbols mean nothing to me, even though I clearly speak English!  Begone!");
               }
               else
               {
                  this.End();
               }
               break;
            case 3:
               this.End();
               break;
            case 4:
               if(this.status == 1)
               {
                  if(this.otherGuy.x < Global.pedro.x)
                  {
                     f = int(FlxObject.LEFT);
                  }
                  else
                  {
                     f = int(FlxObject.RIGHT);
                  }
                  Global.pedro.play("talk");
                  this.otherGuy.play("idle");
                  this.SetBubble(Global.pedro,0,0,f,"Really?  This is what we\'re doing now?");
               }
               else
               {
                  this.End();
               }
               break;
            case 5:
               if(this.status == 1)
               {
                  this.otherGuy.play("idle");
                  Global.pedro.play("talk");
                  this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"As much as I\'d like to take a break, I have a sworn duty to deliver the Boys\' Life fan mail!");
               }
               else if(this.status == 2)
               {
                  Global.pedro.play("idle");
                  this.otherGuy.play("talk");
                  this.SetBubble(this.otherGuy,0,0,FlxObject.LEFT,"And as much as I admire your tenacity, I\'m afraid the letters are far too interesting. We shall keep them.");
               }
               else if(this.status == 3)
               {
                  this.otherGuy.play("idle");
                  Global.pedro.play("talk");
                  this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"What?  Oh come on!  Those are our letters! Hand them over!");
               }
               else if(this.status == 4)
               {
                  Global.pedro.play("idle");
                  this.otherGuy.play("talk");
                  this.SetBubble(this.otherGuy,0,0,FlxObject.LEFT,"I think I will go read some right now. You can discuss the matter further with Torgo. Good day!");
               }
               else if(this.status == 5)
               {
                  this.End();
                  (this.otherGuy as Yak_Master).SummonTorgo();
               }
               break;
            case 6:
               if(this.status == 1)
               {
                  this.otherGuy.play("idle");
                  Global.pedro.play("talk");
                  this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"Hmm... that is quite a wall. I better find another way in!");
               }
               else
               {
                  this.End();
               }
               break;
            case 7:
               this.End();
               break;
            case 8:
               (this.otherGuy as Yak_Master).PoofAway();
               this.End();
               break;
            case 9:
               if(this.status == 1)
               {
                  this.otherGuy.play("idle");
                  Global.pedro.play("talk");
                  this.SetBubble(Global.pedro,0,0,FlxObject.RIGHT,"Wait, did you just stick a trashcan on Torgo\'s head?");
               }
               else if(this.status == 2)
               {
                  Global.pedro.play("idle");
                  this.otherGuy.play("idle");
                  this.SetBubble(this.otherGuy,0,0,FlxObject.LEFT,". . . .");
               }
               else if(this.status == 3)
               {
                  this.otherGuy.play("idle");
                  for each(g in Global.badguys.GetGroup(Badguys.DEADLY).members)
                  {
                     if(g is Robot)
                     {
                        this.SetBubble(g,0,0,FlxObject.LEFT,"BEEP BOOP");
                        return;
                     }
                  }
               }
               else if(this.status == 4)
               {
                  this.otherGuy.play("talk");
                  this.SetBubble(this.otherGuy,0,0,FlxObject.LEFT,"Yes.");
               }
               else
               {
                  (this.otherGuy as Yak_Master).PoofAway();
                  this.End();
               }
               break;
            case 10:
               (this.otherGuy as Yak_Master).PoofAway();
               this.End();
               break;
            case 11:
               if(this.status == 1)
               {
                  Global.pedro.play("idle");
                  this.otherGuy.play("talk");
                  this.SetBubble(this.otherGuy,0,0,FlxObject.RIGHT,"Boy, with you around, I\'m glad I have these Barrier Orbs making me invincible!");
               }
               else
               {
                  this.End();
               }
         }
      }
      
      override public function update() : void
      {
         if(!Global.conversation)
         {
            return;
         }
         this.camPt.x = ((FlxG.camera.scroll.x + 160) * 20 + this.bubble.x + this.bubble.width / 2) / 21;
         this.camPt.y = ((FlxG.camera.scroll.y + 120) * 20 + this.bubble.y + this.bubble.height / 2) / 21;
         FlxG.camera.focusOn(this.camPt);
         if(this.words.alpha < 1)
         {
            this.words.alpha += FlxG.elapsed * 2;
         }
         if(Keebie.TapDir(Keebie.B2) || Keebie.TapDir(Keebie.B3) || FlxG.keys.justPressed("ESCAPE"))
         {
            this.ButtonHit();
         }
         if(this.hintDelay >= 7)
         {
            if(this.hintFlicker > 0.1)
            {
               this.hint.visible = true;
            }
            else
            {
               this.hint.visible = false;
            }
            this.hintFlicker += FlxG.elapsed;
            if(this.hintFlicker >= 0.4)
            {
               this.hintFlicker -= 0.4;
            }
         }
         else
         {
            this.hintDelay += FlxG.elapsed;
            this.hint.visible = false;
         }
      }
   }
}

