package xplor
{
   import org.flixel.*;
   import xplor.Bullet.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.*;
   
   public class Arena
   {
      
      public var locations:Array = new Array(1,7,3,9,5,10,8,11,10,12,22,12,24,11,27,10,29,9,31,7);
      
      public var locations2:Array = new Array(3,10,5,11,2,16,7,15,10,13,11,18,29,10,27,11,30,16,25,15,22,13,21,18,16,12);
      
      public var rounds:Array = new Array(Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,30,Yak_Archer,Yak_Archer,Yak_Archer,Yak_Archer,Yak_Archer,Yak_Archer,Yak_Archer,Yak_Archer,Yak_Archer,Yak_Archer,30,Yak_Archer_Elite,null,null,null,Yak_Armor,Yak_Armor,null,null,null,Yak_Archer_Elite,60,Yakolyte,Yakolyte,Yakolyte,null,Yak_Bruiser,Yak_Bruiser,null,Yakolyte,Yakolyte,Yakolyte,60,Yak_Archer_Elite,Yak_Bruiser,Yak_Bruiser,Yak_Archer_Elite,Yakolyte,Yakolyte,Yak_Archer_Elite,Yak_Bruiser,Yak_Bruiser,Yak_Archer_Elite,80);
      
      public var rounds2:Array = new Array(Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,Yak,40,Yakolyte,null,Yakolyte,null,Yakolyte,null,Yakolyte,null,Yakolyte,null,Yakolyte,null,Yakolyte,60,null,Yak_Ninja,null,Yak_Ninja,null,Yak_Ninja,null,Yak_Ninja,null,Yak_Ninja,null,Yak_Ninja,Yak_Ninja,90,Yak_Armor,Yak_Archer_Elite,Iron_Priest,null,null,null,Yak_Armor,Yak_Archer_Elite,Iron_Priest,null,null,null,Iron_Priest,90,Yak_Bruiser,Yak_Bruiser,Yak_Archer_Elite,Yak_Bruiser,Yak_Archer_Elite,null,Yak_Bruiser,Yak_Bruiser,Yak_Archer_Elite,Yak_Bruiser,Yak_Archer_Elite,null,Iron_Priest,120);
      
      public var powerPos:Array = new Array(15,11,15,12,17,11,17,12,0,0,16,10);
      
      public var powerPos2:Array = new Array(2,10,10,13,22,13,30,10,0,0,16,12);
      
      public var round:int;
      
      public var txt:FlxText;
      
      public var timeLeft:Number;
      
      public var spotsPerRound:int;
      
      public var roundArray:Array;
      
      public var locArray:Array;
      
      public var powerArray:Array;
      
      public var mailX:int;
      
      public var mailY:int;
      
      public function Arena()
      {
         super();
         this.round = 0;
         this.txt = new FlxText(0,25,320,"");
         this.txt.setFormat("volks",16,16777215,"center",1);
         this.txt.scrollFactor.x = 0;
         this.txt.scrollFactor.y = 0;
         PlayState(FlxG.state).add(this.txt);
         if(Global.levelNum == 13)
         {
            this.spotsPerRound = 13;
            this.roundArray = this.rounds2;
            this.locArray = this.locations2;
            this.powerArray = this.powerPos2;
         }
         else
         {
            this.spotsPerRound = 10;
            this.roundArray = this.rounds;
            this.locArray = this.locations;
            this.powerArray = this.powerPos;
         }
         this.SetupRound();
      }
      
      public function SetupRound() : void
      {
         var g:BaseMonster = null;
         if(this.round * (this.spotsPerRound + 1) >= this.roundArray.length)
         {
            return;
         }
         for(var i:int = 0; i < this.spotsPerRound; i++)
         {
            if(this.roundArray[this.round * (this.spotsPerRound + 1) + i] != null)
            {
               g = Global.badguys.AddGuy(this.roundArray[this.round * (this.spotsPerRound + 1) + i],Badguys.DEADLY,this.locArray[i * 2 + 0],this.locArray[i * 2 + 1]) as BaseMonster;
               g.tag = 1;
               if(g is Yak_Armor)
               {
                  (g as Yak_Armor).WakeUp();
               }
               if(g is Yak_Ninja)
               {
                  (g as Yak_Ninja).Poof();
               }
               Global.bullets.AddBullet(SmokePuff,Bullets.NEUTRAL,g.x + g.width / 2,g.y + g.height / 2,0,0);
            }
         }
         this.timeLeft = this.roundArray[this.round * (this.spotsPerRound + 1) + this.spotsPerRound];
      }
      
      public function PowerPresent(n:int) : Boolean
      {
         var g:BaseGuy = null;
         for each(g in Global.badguys.GetGroup(Badguys.NEUTRAL).members)
         {
            if(g is PowerUp && (g as PowerUp).which == n)
            {
               return true;
            }
         }
         return false;
      }
      
      public function AddPowerUp(w:int) : void
      {
         var g:PowerUp = null;
         g = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,this.powerArray[w * 2],this.powerArray[w * 2 + 1]) as PowerUp;
         g.which = w;
      }
      
      public function BonusReward() : void
      {
         if(!Profile.LevelGotHeart(Global.levelNum) && !this.PowerPresent(0))
         {
            this.AddPowerUp(0);
            return;
         }
         if(Profile.skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 0] == 0 && !this.PowerPresent(1))
         {
            this.AddPowerUp(1);
            return;
         }
         if(Profile.skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 1] == 0 && !this.PowerPresent(2))
         {
            this.AddPowerUp(2);
            return;
         }
         if(Profile.skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 2] == 0 && !this.PowerPresent(3))
         {
            this.AddPowerUp(3);
            return;
         }
         var xp:int = (this.round + 1) * 50;
         PlayState(FlxG.state).notice.Say(xp.toString() + "xp Bonus!",16776960,Global.pedro.x + Global.pedro.width / 2,Global.pedro.y - 20);
         Profile.GetXP(xp);
      }
      
      public function Update() : void
      {
         var g:PowerUp = null;
         if(Global.conversation)
         {
            return;
         }
         this.timeLeft -= FlxG.elapsed;
         if(this.round < 5)
         {
            if(this.timeLeft < 0)
            {
               this.timeLeft = 0;
               this.txt.text = "Round " + (this.round + 1) + " - No bonus for you!";
            }
            else
            {
               this.txt.text = "Round " + (this.round + 1) + " - " + int(this.timeLeft) + " seconds for a bonus!";
            }
         }
         else
         {
            this.txt.text = "";
         }
         if(Global.badguys.TagCheck(1))
         {
            if(this.round < 5)
            {
               this.AddPowerUp(5);
               if(this.timeLeft > 0)
               {
                  this.BonusReward();
               }
               ++this.round;
               this.SetupRound();
            }
         }
      }
   }
}

