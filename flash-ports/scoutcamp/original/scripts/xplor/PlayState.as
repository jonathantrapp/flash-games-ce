package xplor
{
   import flash.net.*;
   import org.flixel.*;
   import xplor.Bullet.Boom;
   import xplor.Menus.*;
   import xplor.Monster.*;
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
      
      public var levelTip:LevelTip;
      
      public function PlayState()
      {
         super();
      }
      
      override public function create() : void
      {
         var _loc1_:FlxSprite = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         FlxG.timeScale = 1;
         Global.NewGame(0);
         Global.portals = new Portals();
         Global.campfire = new Campfire(0,0);
         Global.tent = new Tent(0,0);
         Global.tent2 = new Tent(0,0);
         Global.waveManager = new WaveManager();
         Global.waveManager.StartLevel(Global.levelNum);
         this.hud = new Hud();
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
         _loc1_ = new FlxSprite(-32,0);
         _loc1_.width = 33;
         _loc1_.height = Global.level.height * 16;
         _loc1_.immovable = true;
         _loc1_.solid = true;
         _loc1_.visible = false;
         this.border.add(_loc1_);
         _loc1_ = new FlxSprite(Global.level.width * 16 - 2,0);
         _loc1_.width = 33;
         _loc1_.height = Global.level.height * 16;
         _loc1_.immovable = true;
         _loc1_.solid = true;
         _loc1_.visible = false;
         this.border.add(_loc1_);
         _loc1_ = new FlxSprite(-32,-32);
         _loc1_.width = Global.level.width * 16 + 64;
         _loc1_.height = 33;
         _loc1_.immovable = true;
         _loc1_.solid = true;
         _loc1_.visible = false;
         this.border.add(_loc1_);
         _loc1_ = new FlxSprite(-32,Global.level.height * 16 - 1);
         _loc1_.width = Global.level.width * 16 + 64;
         _loc1_.height = 33;
         _loc1_.immovable = true;
         _loc1_.solid = true;
         _loc1_.visible = false;
         this.border.add(_loc1_);
         add(this.border);
         Global.bullets = new Bullets(this);
         Global.badguys = new Badguys(this);
         add(Global.level.GetLayer(Level.LAYER_BACK));
         Global.bullets.AddBehindToState(this);
         add(Global.campfire);
         add(Global.tent);
         add(Global.tent2);
         add(Global.level.GetLayer(Level.LAYER_SOLID));
         add(Global.level.GetLayer(Level.LAYER_DECOR));
         Global.badguys.AddToState(Badguys.DEADLY,this);
         Global.badguys.AddToState(Badguys.TOWERS,this);
         Global.badguys.AddToState(Badguys.FOOD,this);
         Global.bullets.AddToState(this);
         Global.mapStore.AddGoodies(Global.badguys);
         var _loc2_:int = 1;
         if(Global.levelNum == 16)
         {
            _loc2_ = 5;
         }
         else if(Global.levelNum > 11)
         {
            _loc2_ = 4;
         }
         else if(Global.levelNum > 7)
         {
            _loc2_ = 3;
         }
         else if(Global.levelNum > 3)
         {
            _loc2_ = 2;
         }
         else
         {
            _loc2_ = 1;
         }
         Sounds.playSong(_loc2_);
         FlxG.camera.setBounds(0,0,Global.level.width * 16,Global.level.height * 16,false);
         FlxG.worldBounds.x = -16;
         FlxG.worldBounds.y = -16;
         FlxG.worldBounds.width = Global.level.width * 16 + 32;
         FlxG.worldBounds.height = Global.level.height * 16 + 32;
         Global.player.AddBox();
         add(this.hud);
         this.hud.SetCash();
         this.volSpr = new FlxSprite(320 - 8,1,Global.VolumeImage);
         this.volSpr.scrollFactor.x = 0;
         this.volSpr.scrollFactor.y = 0;
         add(this.volSpr);
         this.mapAnim = 0;
         FlxG.mouse.show();
         this.situation = 0;
         this.notice = new Notice();
         add(this.notice);
         this.fade = new FlxSprite(0,0);
         this.fade.makeGraphic(320,240,4278190080,true);
         this.fade.scrollFactor.x = 0;
         this.fade.scrollFactor.y = 0;
         this.fade.visible = true;
         this.fade.alpha = 0.7;
         add(this.fade);
         add(this.pauseMenu);
         this.pauseMenu.visible = false;
         this.levelTip = new LevelTip(Global.levelNum);
         add(this.levelTip);
         Global.player.Pause();
         FlxG.timeScale = 0;
         Global.player.AddCursor();
         _loc3_ = Global.portals.list[0] * 16 + 8;
         _loc4_ = Global.portals.list[1] * 16 + 8;
         FlxG.camera.focusOn(new FlxPoint(_loc3_,_loc4_));
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
               else if(Global.levelNum == 16)
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
         if(this.situation == 2 && !Global.won && Global.randRange(0,1) < 0.5)
         {
            FlxG.shake(0.01,0.1,null,false,FlxCamera.SHAKE_HORIZONTAL_ONLY);
            Global.bullets.AddBullet(Boom,Bullets.NEUTRAL,FlxG.camera.scroll.x + Global.randRange(0,320),FlxG.camera.scroll.y + Global.randRange(0,240),0,0);
         }
         if(this.situation != 2 && Global.won)
         {
            this.situation = 2;
            this.fade.alpha = 0;
            this.fade.visible = true;
         }
         if(!Global.won)
         {
            Global.player.Update();
            super.update();
            Global.badguys.Collide();
            Global.bullets.Collide();
            this.mapAnim += FlxG.elapsed;
            if(this.mapAnim > 0.1)
            {
               Global.level.Animate();
               this.mapAnim -= 0.1;
            }
         }
         if(Keebie.Dir(Keebie.LEFT))
         {
            FlxG.camera.scroll.x -= 0.02 * 250;
         }
         if(Keebie.Dir(Keebie.RIGHT))
         {
            FlxG.camera.scroll.x += 0.02 * 250;
         }
         if(Keebie.Dir(Keebie.UP))
         {
            FlxG.camera.scroll.y -= 0.02 * 250;
         }
         if(Keebie.Dir(Keebie.DOWN))
         {
            FlxG.camera.scroll.y += 0.02 * 250;
         }
         Global.waveManager.Update();
         if(Global.waveManager.allDone && Global.badguys.BadguysLeft() == 0)
         {
            if(Profile.levelsPassed <= Global.levelNum)
            {
               Profile.levelsPassed = Global.levelNum + 1;
            }
            Global.won = true;
         }
         if(Global.foodLeft == 0 && this.situation != 2)
         {
            this.situation = 2;
            this.fade.alpha = 0;
            this.fade.visible = true;
         }
         Global.portals.Update();
         this.hud.Update();
      }
      
      public function PauseUpdate() : void
      {
         this.pauseMenu.update();
         Global.player.Update();
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
         if(this.situation == 10)
         {
            this.situation = 0;
            FlxG.timeScale = 1;
            remove(this.levelTip);
            this.levelTip = null;
            Global.player.Pause();
            return;
         }
         if(this.levelTip != null)
         {
            Global.waveManager.Update();
            Global.player.Update();
            super.update();
            if(FlxG.keys.justPressed("ESCAPE"))
            {
               this.situation = 10;
            }
            return;
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
            if(Global.player.ESCHit())
            {
               this.pause = !this.pause;
               this.pauseMenu.Toggle();
            }
         }
      }
   }
}

