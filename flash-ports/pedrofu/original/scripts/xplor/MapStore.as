package xplor
{
   import flash.utils.ByteArray;
   import org.flixel.*;
   import xplor.Menus.SkillDef;
   import xplor.Monster.*;
   
   public class MapStore
   {
      
      public var layers:Array = null;
      
      public var width:int = 0;
      
      public var height:int = 0;
      
      public function MapStore()
      {
         super();
      }
      
      public function GetLayer(i:int) : Array
      {
         if(this.layers == null || i < 0 || i >= this.layers.length)
         {
            return null;
         }
         return this.layers[i];
      }
      
      public function LoadFromArray(data:ByteArray) : void
      {
         var i:int = 0;
         var j:int = 0;
         data.uncompress();
         data.position = 0;
         this.width = data.readShort();
         this.height = data.readShort();
         this.layers = new Array();
         for(i = 0; i < Level.LAYERS; i++)
         {
            this.layers[i] = new Array();
            for(j = 0; j < this.width * this.height; j++)
            {
               (this.layers[i] as Array).push(data.readUnsignedByte());
            }
         }
      }
      
      public function SaveToArray() : ByteArray
      {
         var i:int = 0;
         var b:ByteArray = null;
         var j:int = 0;
         b = new ByteArray();
         b.writeShort(this.width);
         b.writeShort(this.height);
         for(i = 0; i < Level.LAYERS; i++)
         {
            for(j = 0; j < this.width * this.height; j++)
            {
               b.writeByte(this.layers[i][j]);
            }
         }
         b.compress();
         return b;
      }
      
      public function GetFromMap() : void
      {
         this.height = Global.level.height;
         this.width = Global.level.width;
         this.layers = new Array();
         for(var i:int = 0; i < Level.LAYERS; i++)
         {
            this.layers.push(Global.level.GetLayer(i).getData());
         }
      }
      
      public function TagMe(me:BaseGuy, x:int, y:int) : void
      {
         var t:int = 0;
         if(y > 0)
         {
            t = int(this.layers[3][x + (y - 1) * Global.level.width]);
            if(t >= 26 && t <= 28)
            {
               me.tag = t - 25;
            }
            else
            {
               me.tag = 0;
            }
         }
      }
      
      public function AddGoodies(badguys:Badguys) : void
      {
         var i:int = 0;
         var g:PowerUp = null;
         var b:BaseGuy = null;
         var t:Tree_Wall = null;
         var tree:Tree = null;
         Global.level.jumps = new Array();
         Global.mailLeft = 0;
         if(Global.levelNum == 10 || Global.levelNum == 13)
         {
            Global.mailLeft = 5;
         }
         if(Global.levelNum == 14)
         {
            Global.mailLeft = 1;
         }
         for(i = 0; i < Global.level.width * Global.level.height; i++)
         {
            Global.level.jumps[i] = 0;
            switch(this.layers[3][i])
            {
               case 1:
                  Global.pedro = new Pedro(i % Global.level.width * 16 + 4,i / Global.level.width * 16 - 10);
                  break;
               case 2:
                  b = Global.badguys.AddGuy(Yak,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 3:
               case 4:
               case 5:
                  Global.level.jumps[i] = this.layers[3][i];
                  break;
               case 6:
                  if(!Profile.LevelGotHeart(Global.levelNum))
                  {
                     g = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as PowerUp;
                     g.which = 0;
                  }
                  break;
               case 7:
                  if(Profile.skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 0] == 0)
                  {
                     g = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as PowerUp;
                     g.which = 1;
                  }
                  break;
               case 8:
                  if(Profile.skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 1] == 0)
                  {
                     g = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as PowerUp;
                     g.which = 2;
                  }
                  break;
               case 9:
                  if(Profile.skillHave[Global.levelNum + SkillDef.SKILLS_PER_SET * 2] == 0)
                  {
                     g = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as PowerUp;
                     g.which = 3;
                  }
                  break;
               case 10:
               case 11:
                  Global.level.jumps[i] = this.layers[3][i];
                  break;
               case 12:
                  ++Global.mailLeft;
                  g = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as PowerUp;
                  g.which = 5;
                  break;
               case 13:
                  b = Global.badguys.AddGuy(Tent,Badguys.BACKGD,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 14:
                  b = Global.badguys.AddGuy(Tent,Badguys.BACKGD,i % Global.level.width,i / Global.level.width);
                  b.facing = FlxObject.LEFT;
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 15:
                  Global.badguys.AddGuy(Campfire,Badguys.BACKGD,i % Global.level.width,i / Global.level.width);
                  break;
               case 16:
                  b = Global.badguys.AddGuy(Yak_Armor,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 17:
                  b = Global.badguys.AddGuy(Yak_Archer,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 18:
                  t = Global.badguys.AddGuy(Tree_Wall,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as Tree_Wall;
                  t.x += 44;
                  break;
               case 19:
                  t = Global.badguys.AddGuy(Tree_Wall,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as Tree_Wall;
                  t.facing = FlxObject.LEFT;
                  break;
               case 20:
               case 21:
               case 22:
                  Global.badguys.AddGuy(Tree,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width).frame = this.layers[3][i] - 20;
                  break;
               case 23:
               case 24:
               case 25:
                  tree = Global.badguys.AddGuy(Tree,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as Tree;
                  tree.frame = this.layers[3][i] - 23;
                  tree.facing = FlxObject.LEFT;
                  break;
               case 29:
                  b = Global.badguys.AddGuy(FireMan,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 30:
               case 31:
                  b = Global.badguys.AddGuy(BlimpChunk,Badguys.BACKGD,i % Global.level.width,i / Global.level.width);
                  b.frame = this.layers[3][i] - 30;
                  break;
               case 32:
               case 33:
                  b = Global.badguys.AddGuy(BlimpShred,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width);
                  b.frame = this.layers[3][i] - 32;
                  break;
               case 34:
                  Global.badguys.AddGuy(BlimpEngine,Badguys.BACKGD,i % Global.level.width,i / Global.level.width);
                  break;
               case 35:
                  b = Global.badguys.AddGuy(Yak_Ninja,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 36:
                  if(!Profile.LevelGotFury(Global.levelNum))
                  {
                     g = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as PowerUp;
                     g.which = 4;
                  }
                  break;
               case 37:
                  g = Global.badguys.AddGuy(PowerUp,Badguys.NEUTRAL,i % Global.level.width,i / Global.level.width) as PowerUp;
                  g.which = 6;
                  break;
               case 38:
                  b = Global.badguys.AddGuy(Yak_Bruiser,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 39:
                  b = Global.badguys.AddGuy(Yak_Big,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 40:
                  b = Global.badguys.AddGuy(Yak_Master,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 41:
                  b = Global.badguys.AddGuy(Yak_Archer_Elite,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 42:
                  b = Global.badguys.AddGuy(Barrier_Orb,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 43:
                  b = Global.badguys.AddGuy(Barrier,Badguys.BACKGD,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 44:
                  b = Global.badguys.AddGuy(Tent_Grass,Badguys.BACKGD,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 45:
                  b = Global.badguys.AddGuy(Yakolyte,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 46:
                  b = Global.badguys.AddGuy(Robot,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
                  break;
               case 47:
                  b = Global.badguys.AddGuy(Iron_Priest,Badguys.DEADLY,i % Global.level.width,i / Global.level.width);
                  this.TagMe(b,i % Global.level.width,i / Global.level.width);
            }
         }
      }
   }
}

