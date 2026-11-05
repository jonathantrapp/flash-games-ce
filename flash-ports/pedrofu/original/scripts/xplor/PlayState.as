package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxGroup;
   import org.flixel.FlxSprite;
   import org.flixel.FlxState;
   import org.flixel.FlxText;
   import org.flixel.FlxTilemapExt;
   import xplor.Menus.MapState;
   import xplor.Menus.PauseMenu;
   import xplor.Menus.WinState;
   import xplor.Monster.Blimp;
   import xplor.TileSets.TileSet;
   import xplor.TileSets.TileSet_Grave;
   
   public class PlayState extends FlxState
   {
      
      public var sky:Sky;
      
      public var volSpr:FlxSprite;
      
      public var mapAnim:Number;
      
      public var fade:FlxSprite;
      
      public var situation:int;
      
      public var border:FlxGroup;
      
      public var tileset:TileSet;
      
      public var pause:Boolean;
      
      public var pauseMenu:PauseMenu;
      
      public var notice:Notice;
      
      public var hud:Hud;
      
      public var pauseMsg:int;
      
      public var furyIcons:FuryIcons;
      
      public var conversation:Conversation;
      
      public var bigNotice:BigNotice;
      
      public var arena:Arena;
      
      public function PlayState()
      {
         super();
      }
      
      override public function create() : void
      {
         var s:FlxSprite = null;
         FlxG.timeScale = 1;
         Global.NewGame(0);
         this.arena = null;
         this.sky = new Sky(int(Global.levelNum > 3) + int(Global.levelNum > 7));
         add(this.sky);
         this.tileset = new TileSet_Grave();
         this.pause = false;
         this.pauseMenu = new PauseMenu();
         this.pauseMsg = 0;
         Global.level = new Level(this.tileset.Image());
         if(Global.mode == Global.TEST)
         {
            Global.level.LoadStore(Global.mapStore);
         }
         else
         {
            Global.mapStore.LoadFromArray(Global.levelSet.GetLevelData(Global.levelNum));
            Global.level.LoadStore(Global.mapStore);
         }
         this.tileset.SetProperties(Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt);
         this.border = new FlxGroup();
         s = new FlxSprite(-32,0);
         s.width = 33;
         s.height = Global.level.height * 16;
         s.immovable = true;
         s.solid = true;
         s.visible = false;
         this.border.add(s);
         s = new FlxSprite(Global.level.width * 16 - 2,0);
         s.width = 33;
         s.height = Global.level.height * 16;
         s.immovable = true;
         s.solid = true;
         s.visible = false;
         this.border.add(s);
         s = new FlxSprite(-32,-32);
         s.width = Global.level.width * 16 + 64;
         s.height = 33;
         s.immovable = true;
         s.solid = true;
         s.visible = false;
         this.border.add(s);
         add(this.border);
         Global.bullets = new Bullets(this);
         Global.badguys = new Badguys(this);
         add(Global.level.GetLayer(Level.LAYER_BACK));
         Global.badguys.AddToState(Badguys.BACKGD,this);
         Global.bullets.AddBehindToState(this);
         add(Global.level.GetLayer(Level.LAYER_SOLID));
         Global.badguys.AddToState(Badguys.NEUTRAL,this);
         Global.badguys.AddToState(Badguys.DEADLY,this);
         Global.mapStore.AddGoodies(Global.badguys);
         add(Global.pedro);
         Global.bullets.AddToState(this);
         add(Global.level.GetLayer(Level.LAYER_DECOR));
         this.furyIcons = new FuryIcons();
         add(this.furyIcons);
         var song:int = 1;
         if(Global.levelNum <= 4)
         {
            song = 1;
         }
         else if(Global.levelNum <= 9)
         {
            song = 2;
         }
         else
         {
            song = 3;
         }
         Sounds.playSong(song);
         FlxG.camera.setBounds(0,0,Global.level.width * 16,Global.level.height * 16,false);
         FlxG.worldBounds.x = -16;
         FlxG.worldBounds.y = -16;
         FlxG.worldBounds.width = Global.level.width * 16 + 32;
         FlxG.worldBounds.height = Global.level.height * 16 + 32;
         if(Global.levelNum == 0)
         {
            Global.badguys.AddGuy(Blimp,Badguys.NEUTRAL,-10,3);
            Global.pedro.Deactivate();
         }
         else
         {
            FlxG.camera.follow(Global.pedro);
         }
         if(Global.levelNum == 10 || Global.levelNum == 13)
         {
            this.arena = new Arena();
         }
         this.hud = new Hud();
         add(this.hud);
         this.hud.SetCash();
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         this.volSpr.scrollFactor.x = 0;
         this.volSpr.scrollFactor.y = 0;
         add(this.volSpr);
         this.mapAnim = 0;
         this.situation = 0;
         this.notice = new Notice();
         add(this.notice);
         this.conversation = new Conversation();
         add(this.conversation);
         this.bigNotice = new BigNotice();
         add(this.bigNotice);
         this.fade = new FlxSprite(0,0);
         this.fade.makeGraphic(320,240,4278190080,true);
         this.fade.scrollFactor.x = 0;
         this.fade.scrollFactor.y = 0;
         this.fade.visible = true;
         this.fade.alpha = 0.7;
         add(this.fade);
         add(this.pauseMenu);
         this.pauseMenu.visible = false;
         FlxG.timeScale = 1;
      }
      
      public function AddHelpers() : void
      {
         var t:FlxText = new FlxText(20,330,200,"Use the arrow keys to move.");
         t.setFormat("volks",10,16777215,"left",1);
         add(t);
         t = new FlxText(365,343,150,"Tap up or Z to jump!");
         t.setFormat("volks",10,16777215,"left",1);
         add(t);
         t = new FlxText(790,280,150,"I\'m sure this is a nice friendly campsite, but just in case, you can press X to attack.");
         t.setFormat("volks",10,16777215,"left",1);
         add(t);
         t = new FlxText(1340,343,150,"As usual, Pedro needs to collect the lost mail to move on!");
         t.setFormat("volks",10,16777215,"left",1);
         add(t);
         t = new FlxText(74 * 16 - 75,16 * 16 - 60,150,"You\'ll need to put points into Ancient Techniques to use them. You can do that on the Skills screen between levels.");
         t.setFormat("volks",10,16777215,"left",1);
         add(t);
         t = new FlxText(100 * 16 - 55,16 * 16,150,"Press ESC to pause when you want to restart or exit the level.");
         t.setFormat("volks",10,16777215,"left",1);
         add(t);
      }
      
      override public function destroy() : void
      {
         Global.bullets = null;
         Global.badguys = null;
      }
      
      public function PlayUpdate() : void
      {
         if(this.situation == 0)
         {
            Global.time += FlxG.elapsed * 3;
            this.fade.visible = true;
            this.fade.alpha -= FlxG.elapsed;
            if(this.fade.alpha == 0)
            {
               this.fade.visible = false;
               this.situation = 1;
            }
         }
         else if(this.situation == 2)
         {
            Global.time += FlxG.elapsed * 3;
            this.fade.visible = true;
            this.fade.alpha += FlxG.elapsed;
            if(this.fade.alpha == 1)
            {
               Profile.SaveGame();
               if(!Global.won)
               {
                  FlxG.switchState(new PlayState());
               }
               else if(Global.mode == Global.TEST)
               {
                  FlxG.switchState(new EditState());
               }
               else if(Global.levelNum == 14)
               {
                  FlxG.switchState(new WinState());
               }
               else
               {
                  FlxG.switchState(new MapState());
               }
               return;
            }
         }
         Global.time += FlxG.elapsed;
         if(FlxG.mouse.justPressed() && FlxG.mouse.screenX >= 320 - 8 && FlxG.mouse.screenY <= 12)
         {
            FlxG.mute = !FlxG.mute;
         }
         if(Global.pedro.health == 0 && this.situation != 2)
         {
            this.situation = 2;
            this.fade.alpha = 0;
            this.fade.visible = true;
         }
         if(this.situation != 2 && Global.won)
         {
            this.situation = 2;
            this.fade.alpha = 0;
            this.fade.visible = true;
         }
         if(!Global.won)
         {
            if(this.arena != null)
            {
               this.arena.Update();
            }
            super.update();
            FlxG.collide(Global.pedro,Global.level.GetLayer(Level.LAYER_SOLID));
            FlxG.collide(Global.pedro,this.border);
            Global.badguys.Collide();
            Global.bullets.Collide();
            this.mapAnim += FlxG.elapsed;
            if(this.mapAnim > 0.1)
            {
               Global.level.Animate();
               this.mapAnim -= 0.1;
            }
            if(Global.mailLeft == 0)
            {
               Global.won = true;
            }
         }
         this.hud.Update();
      }
      
      public function PauseUpdate() : void
      {
         this.pauseMenu.update();
         this.sky.draw();
      }
      
      override public function update() : void
      {
         if(FlxG.mute)
         {
            this.volSpr.alpha = 0.5;
         }
         else
         {
            this.volSpr.alpha = 1;
         }
         if(FlxG.timeScale < 1)
         {
            FlxG.timeScale += FlxG.elapsed * 2;
            if(FlxG.timeScale > 1)
            {
               FlxG.timeScale = 1;
            }
         }
         if(this.pauseMsg == 1)
         {
            Profile.SaveGame();
            FlxG.switchState(new PlayState());
            return;
         }
         if(this.pauseMsg == 2)
         {
            Profile.SaveGame();
            if(Global.mode == Global.TEST)
            {
               FlxG.switchState(new EditState());
               return;
            }
            FlxG.switchState(new MapState());
            return;
         }
         if(!this.pause)
         {
            this.PlayUpdate();
         }
         else
         {
            this.PauseUpdate();
         }
         if(FlxG.keys.justPressed("ESCAPE"))
         {
            this.pause = !this.pause;
            this.pauseMenu.Toggle();
         }
      }
   }
}

