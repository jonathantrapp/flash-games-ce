package xplor
{
   import flash.utils.ByteArray;
   import org.flixel.*;
   import xplor.Menus.SkillDef;
   import xplor.Menus.SkillState;
   
   public class Profile
   {
      
      public static var sndVol:Number;
      
      public static var musVol:Number;
      
      public static var levelStatus:Array;
      
      public static var skills:Array;
      
      public static var skillHave:Array;
      
      public static var skillPts:int;
      
      public static var xp:int;
      
      public static var level:int;
      
      public static var levelsPassed:int;
      
      public static var max_life:int;
      
      public static var max_fury:int;
      
      public static var fs:FlxSave = null;
      
      public function Profile()
      {
         super();
      }
      
      public static function Init() : void
      {
         var o:Object = null;
         var i:int = 0;
         var b:ByteArray = null;
         if(fs == null)
         {
            fs = new FlxSave();
            fs.bind("PedroFu-Hamumu");
            if(fs.data.sndVol == null)
            {
               sndVol = 100;
            }
            else
            {
               sndVol = fs.data.sndVol;
            }
            if(fs.data.musVol == null)
            {
               musVol = 75;
            }
            else
            {
               musVol = fs.data.musVol;
            }
            if(fs.data.skills == null)
            {
               skills = new Array();
               for(i = 0; i < 50; i++)
               {
                  skills[i] = 0;
               }
               fs.data.skills = skills;
            }
            else
            {
               skills = fs.data.skills;
            }
            if(fs.data.skillHave == null)
            {
               skillHave = new Array();
               for(i = 0; i < 50; i++)
               {
                  skillHave[i] = 0;
               }
               fs.data.skillHave = skillHave;
            }
            else
            {
               skillHave = fs.data.skillHave;
            }
            if(fs.data.skillPts == null)
            {
               skillPts = 0;
            }
            else
            {
               skillPts = fs.data.skillPts;
            }
            if(fs.data.skillPts == null)
            {
               skillPts = 0;
            }
            else
            {
               skillPts = fs.data.skillPts;
            }
            if(fs.data.level == null)
            {
               level = 0;
            }
            else
            {
               level = fs.data.level;
            }
            if(fs.data.xp == null)
            {
               xp = 0;
            }
            else
            {
               xp = fs.data.xp;
            }
            if(fs.data.levelsPassed == null)
            {
               levelsPassed = 0;
            }
            else
            {
               levelsPassed = fs.data.levelsPassed;
            }
            if(fs.data.levelStatus == null)
            {
               levelStatus = new Array();
               fs.data.levelStatus = levelStatus;
            }
            else
            {
               levelStatus = fs.data.levelStatus;
            }
            max_life = 5;
            max_fury = 1;
            for each(o in levelStatus)
            {
               if(o != null)
               {
                  if(Boolean(o.gotHeart) && max_life < 20)
                  {
                     ++max_life;
                  }
                  if(Boolean(o.gotFury) && max_fury < 5)
                  {
                     ++max_fury;
                  }
               }
            }
         }
      }
      
      public static function ResetProgress() : void
      {
         skills = new Array();
         for(var i:int = 0; i < 50; i++)
         {
            skills[i] = 0;
            skillHave[i] = 0;
         }
         max_life = 5;
         max_fury = 1;
         skillPts = 0;
         level = 0;
         xp = 0;
         fs.data.level = 0;
         fs.data.xp = 0;
         fs.data.skillPts = 0;
         fs.data.skills = skills;
         levelsPassed = 0;
         levelStatus = new Array();
         fs.data.levelStatus = levelStatus;
      }
      
      public static function LevelGotHeart(n:int) : Boolean
      {
         if(levelStatus[n] != null)
         {
            return levelStatus[n].gotHeart;
         }
         return false;
      }
      
      public static function LevelGotFury(n:int) : Boolean
      {
         if(levelStatus[n] != null)
         {
            return levelStatus[n].gotFury;
         }
         return false;
      }
      
      public static function LevelPassed(n:int) : Boolean
      {
         if(levelStatus[n] != null)
         {
            return levelStatus[n].passed;
         }
         return false;
      }
      
      public static function LevelsPassed() : int
      {
         var count:int = 0;
         for(var i:int = 0; i < levelStatus.length; i++)
         {
            if(levelStatus[i] != null && Boolean(levelStatus[i].passed))
            {
               count++;
            }
         }
         return count;
      }
      
      public static function WinLevel() : void
      {
         var l:LevelStatus = null;
         var o:Object = null;
         if(Global.mode == Global.TEST)
         {
            return;
         }
         if(levelStatus[Global.levelNum] == null)
         {
            l = new LevelStatus();
            l.passed = true;
            l.bestTime = Global.time;
            levelStatus[Global.levelNum] = l;
         }
         else
         {
            if(levelStatus[Global.levelNum].bestTime > Global.time)
            {
               levelStatus[Global.levelNum].bestTime = Global.time;
            }
            levelStatus[Global.levelNum].passed = true;
         }
         levelsPassed = 0;
         for each(o in levelStatus)
         {
            if(o != null && Boolean(o.passed))
            {
               ++levelsPassed;
            }
         }
      }
      
      public static function SaveOverall() : void
      {
         fs.data.skills = skills;
         fs.data.skillHave = skillHave;
         fs.data.skillPts = skillPts;
         fs.data.level = level;
         fs.data.xp = xp;
         fs.data.levelsPassed = levelsPassed;
         fs.data.levelStatus = levelStatus;
         fs.data.sndVol = sndVol;
         fs.data.musVol = musVol;
      }
      
      public static function SaveGame() : void
      {
         SaveOverall();
      }
      
      public static function XPNeed() : int
      {
         if(level == 99)
         {
            return 1;
         }
         return level * 10 + 50;
      }
      
      public static function GetXP(amt:int) : void
      {
         amt *= 1 + skills[SkillDef.FANCYFOOTWORK] * 0.06;
         if(level == 99)
         {
            xp = 1;
            return;
         }
         xp += amt;
         if(xp >= XPNeed())
         {
            xp -= XPNeed();
            ++level;
            ++skillPts;
            if(level == 99)
            {
               xp = 1;
            }
            PlayState(FlxG.state).hud.levelText.text = "Level " + (level + 1);
            PlayState(FlxG.state).hud.levelText.scale.x = 2;
            PlayState(FlxG.state).hud.levelText.scale.y = 2;
            Sounds.play(Sounds.LevelUpSnd);
            Global.bullets.MakeFlash(0);
         }
      }
      
      public static function GetPowerUp(which:int) : void
      {
         switch(which)
         {
            case 0:
               if(LevelGotHeart(Global.levelNum))
               {
                  return;
               }
               if(levelStatus[Global.levelNum] == null)
               {
                  levelStatus[Global.levelNum] = new LevelStatus();
               }
               levelStatus[Global.levelNum].gotHeart = true;
               if(max_life < 20)
               {
                  ++max_life;
               }
               if(Global.pedro.health < max_life)
               {
                  ++Global.pedro.health;
               }
               Sounds.play(Sounds.PowerUpSnd);
               PlayState(FlxG.state).hud.AdjustMaxes();
               PlayState(FlxG.state).bigNotice.Say("Increased Maximum Life","Omega Heart");
               break;
            case 1:
               if(Boolean(skillHave[Global.levelNum]))
               {
                  return;
               }
               Sounds.play(Sounds.PowerUpSnd);
               skillHave[Global.levelNum] = 1;
               PlayState(FlxG.state).bigNotice.Say("Discovered Ancient Technique",SkillState.skills[Global.levelNum].name);
               break;
            case 2:
               if(Boolean(skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 1]))
               {
                  return;
               }
               Sounds.play(Sounds.PowerUpSnd);
               skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 1] = 1;
               PlayState(FlxG.state).bigNotice.Say("Discovered Ancient Technique",SkillState.skills[Global.levelNum + SkillDef.SKILLS_PER_SET * 1].name);
               break;
            case 3:
               if(Boolean(skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 2]))
               {
                  return;
               }
               Sounds.play(Sounds.PowerUpSnd);
               skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 2] = 1;
               PlayState(FlxG.state).bigNotice.Say("Discovered Ancient Technique",SkillState.skills[Global.levelNum + SkillDef.SKILLS_PER_SET * 2].name);
               break;
            case 4:
               if(levelStatus[Global.levelNum] == null)
               {
                  levelStatus[Global.levelNum] = new LevelStatus();
               }
               else if(Boolean(levelStatus[Global.levelNum].gotFury))
               {
                  return;
               }
               levelStatus[Global.levelNum].gotFury = true;
               if(max_fury < 5)
               {
                  ++max_fury;
               }
               Sounds.play(Sounds.PowerUpSnd);
               PlayState(FlxG.state).hud.AdjustMaxes();
               PlayState(FlxG.state).bigNotice.Say("Increased Maximum Fury","Fury Soul");
               break;
            case 5:
               Sounds.play(Sounds.MailGetSnd);
               --Global.mailLeft;
               if(Global.mailLeft == 0)
               {
                  WinLevel();
               }
               break;
            case 6:
               Sounds.play(Sounds.PotionSnd);
               Global.pedro.health = max_life;
               PlayState(FlxG.state).notice.Say("Mmm, healed!",16711680,Global.pedro.x + Global.pedro.width / 2,Global.pedro.y);
               break;
            case 7:
               if(Global.pedro.health < max_life)
               {
                  Global.pedro.health += 3;
                  if(Global.pedro.health > max_life)
                  {
                     Global.pedro.health = max_life;
                  }
                  Sounds.play(Sounds.HeartSnd);
               }
         }
         SaveGame();
      }
   }
}

