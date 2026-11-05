package xplor
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import org.flixel.FlxG;
   import org.flixel.FlxState;
   import org.flixel.FlxTilemapExt;
   
   public class EditState extends FlxState
   {
      
      public static const EDIT:uint = 0;
      
      public static const LOAD:uint = 1;
      
      public static const SAVE:uint = 2;
      
      private static const FILE_TYPES:Array = [new FileFilter("CampLevel","*.camp")];
      
      private static const DEFAULT_FILE_NAME:String = "level01.camp";
      
      public var sky:Sky;
      
      public var mode:uint;
      
      public var tileX:int;
      
      public var tileY:int;
      
      public var hud:EditHud;
      
      public var plopping:Boolean;
      
      public var mapAnim:Number;
      
      public var fileRef:FileReference;
      
      public function EditState()
      {
         super();
      }
      
      override public function create() : void
      {
         this.sky = new Sky(1);
         add(this.sky);
         this.fileRef = null;
         this.hud = new EditHud();
         Global.level = new Level(this.hud.tileSet.Image());
         this.hud.SetBorderSize();
         Global.level.EditInit();
         this.hud.tileSet.SetProperties(Global.level.GetLayer(Level.LAYER_SOLID) as FlxTilemapExt);
         if(Global.mode == Global.TEST)
         {
            Global.level.LoadStore(Global.mapStore);
            Global.level.GoodieMap();
         }
         else
         {
            Global.level.EditClear();
         }
         add(Global.level.GetLayer(Level.LAYER_BACK));
         add(Global.level.GetLayer(Level.LAYER_SOLID));
         add(Global.level.GetLayer(Level.LAYER_DECOR));
         add(Global.level.GetLayer(Level.LAYER_GOODIE));
         Global.mode = Global.EDIT;
         add(this.hud);
         FlxG.mouse.show();
         this.mode = EDIT;
         this.plopping = false;
         this.mapAnim = 0;
         Global.game.stage.addEventListener(MouseEvent.CLICK,this.PotentialSaveClick);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         Global.game.stage.removeEventListener(MouseEvent.CLICK,this.PotentialSaveClick);
      }
      
      public function LoadClick() : void
      {
         this.mode = LOAD;
         this.fileRef = new FileReference();
         this.fileRef.addEventListener(Event.SELECT,this.onFileSelect);
         this.fileRef.addEventListener(Event.CANCEL,this.onCancel);
         this.fileRef.browse(FILE_TYPES);
      }
      
      public function onFileSelect(param1:Event) : void
      {
         this.fileRef.addEventListener(Event.COMPLETE,this.onLoadComplete);
         this.fileRef.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         this.fileRef.load();
      }
      
      public function KillLoader() : void
      {
         this.fileRef.removeEventListener(Event.SELECT,this.onFileSelect);
         this.fileRef.removeEventListener(Event.CANCEL,this.onCancel);
         this.fileRef.removeEventListener(Event.COMPLETE,this.onLoadComplete);
         this.fileRef.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.fileRef.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         this.fileRef = null;
      }
      
      public function onCancel(param1:Event) : void
      {
         this.mode = EDIT;
         this.KillLoader();
      }
      
      public function onLoadComplete(param1:Event) : void
      {
         Global.mapStore.LoadFromArray(this.fileRef.data);
         Global.level.LoadStore(Global.mapStore);
         Global.level.GoodieMap();
         this.KillLoader();
         this.mode = EDIT;
      }
      
      public function onLoadError(param1:IOErrorEvent) : void
      {
         this.mode = EDIT;
         this.KillLoader();
      }
      
      public function SaveClick() : void
      {
         if(this.fileRef != null)
         {
            return;
         }
         Global.mapStore.GetFromMap();
         this.mode = SAVE;
         this.fileRef = new FileReference();
         this.fileRef.addEventListener(Event.COMPLETE,this.onFileSave);
         this.fileRef.addEventListener(Event.CANCEL,this.onSaveCancel);
         this.fileRef.addEventListener(IOErrorEvent.IO_ERROR,this.onSaveError);
         this.fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSaveError);
         this.fileRef.save(Global.mapStore.SaveToArray(),DEFAULT_FILE_NAME);
      }
      
      public function onFileSave(param1:Event) : void
      {
         this.fileRef = null;
         this.mode = EDIT;
      }
      
      public function onSaveCancel(param1:Event) : void
      {
         this.fileRef = null;
         this.mode = EDIT;
      }
      
      public function onSaveError(param1:IOErrorEvent) : void
      {
         this.fileRef = null;
         this.mode = EDIT;
      }
      
      public function PotentialSaveClick(param1:MouseEvent) : void
      {
         if(this.mode != EDIT)
         {
            return;
         }
         if(this.hud.loadTxt.overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            this.LoadClick();
         }
         else if(this.hud.saveTxt.overlapsPoint(FlxG.mouse.getScreenPosition()))
         {
            this.SaveClick();
         }
      }
      
      public function Clean(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         _loc3_ = param1 - 1;
         while(_loc3_ <= param1 + 1)
         {
            _loc4_ = param2 - 1;
            while(_loc4_ <= param2 + 1)
            {
               if(Global.level.OnTheMap(_loc3_,_loc4_))
               {
                  _loc5_ = 1;
                  while(_loc5_ < this.hud.tileSet.tools.length)
                  {
                     if(this.hud.tileSet.GetTool(_loc5_).IsThis(_loc3_,_loc4_))
                     {
                        Global.level.GetLayer(this.hud.tileSet.GetTool(_loc5_).layer).setTile(_loc3_,_loc4_,this.hud.tileSet.GetTool(_loc5_).ChooseTile(_loc3_,_loc4_));
                     }
                     _loc5_++;
                  }
               }
               _loc4_++;
            }
            _loc3_++;
         }
         _loc3_ = param1 - 1;
         while(_loc3_ <= param1 + 1)
         {
            _loc4_ = param2 - 1;
            while(_loc4_ <= param2 + 1)
            {
               if(Global.level.OnTheMap(_loc3_,_loc4_))
               {
                  _loc5_ = int(Global.level.GetLayer(Level.LAYER_BACK).getTile(_loc3_,_loc4_));
                  if(_loc5_ >= 28 && _loc5_ <= 32 && _loc4_ < Global.level.height - 1)
                  {
                     Global.level.GetLayer(Level.LAYER_SOLID).setTile(_loc3_,_loc4_ + 1,33);
                  }
               }
               _loc4_++;
            }
            _loc3_++;
         }
      }
      
      public function Plop() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.hud.tool == 0)
         {
            this.ClearSpot(this.tileX,this.tileY);
         }
         else
         {
            _loc1_ = 0;
            _loc2_ = 0;
            _loc3_ = Global.level.width;
            _loc4_ = Global.level.height;
            if(this.tileX < 0)
            {
               _loc1_ = -this.tileX;
               _loc3_ = Global.level.width - this.tileX;
            }
            else if(this.tileX >= Global.level.width)
            {
               _loc1_ = 0;
               _loc3_ = this.tileX + 1;
            }
            if(this.tileY < 0)
            {
               _loc2_ = -this.tileY;
               _loc4_ = Global.level.height - this.tileY;
            }
            else if(this.tileY >= Global.level.height)
            {
               _loc2_ = 0;
               _loc4_ = this.tileY + 1;
            }
            if(_loc3_ * _loc4_ > 10000)
            {
               return;
            }
            if(_loc1_ != 0 || _loc2_ != 0 || _loc3_ != Global.level.width || _loc4_ != Global.level.height)
            {
               Global.level.Resize(_loc3_,_loc4_,-_loc1_,-_loc2_);
               this.hud.SetBorderSize();
            }
            this.tileX += _loc1_;
            this.tileY += _loc2_;
            Global.level.GetLayer(this.hud.tileSet.GetTool(this.hud.tool).layer).setTile(this.tileX,this.tileY,this.hud.tileSet.GetTool(this.hud.tool).ChooseTile(this.tileX,this.tileY));
            this.Clean(this.tileX,this.tileY);
         }
      }
      
      public function ClearSpot(param1:int, param2:int) : void
      {
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc5_:int = 0;
         if(param1 >= 0 && param2 >= 0 && param1 < Global.level.width && param2 < Global.level.height)
         {
            Global.level.ClearSpot(param1,param2);
            this.Clean(param1,param2);
            if(Global.level.width > 10)
            {
               _loc5_ = -1;
               _loc3_ = 0;
               while(_loc3_ < Global.level.width)
               {
                  _loc4_ = 0;
                  while(_loc4_ < Global.level.height)
                  {
                     if(!Global.level.IsEmpty(_loc3_,_loc4_))
                     {
                        _loc5_ = _loc3_ - 1;
                        _loc4_ = Global.level.height;
                        _loc3_ = Global.level.width;
                     }
                     _loc4_++;
                  }
                  _loc3_++;
               }
               if(_loc5_ > -1)
               {
                  if(Global.level.width - (_loc5_ + 1) < 10)
                  {
                     _loc5_ = Global.level.width - 11;
                  }
                  Global.level.Resize(Global.level.width - (_loc5_ + 1),Global.level.height,_loc5_ + 1,0);
                  this.hud.SetBorderSize();
               }
               _loc5_ = Global.level.width;
               _loc3_ = int(Global.level.width - 1);
               while(_loc3_ >= 0)
               {
                  _loc4_ = 0;
                  while(_loc4_ < Global.level.height)
                  {
                     if(!Global.level.IsEmpty(_loc3_,_loc4_))
                     {
                        _loc5_ = _loc3_ + 1;
                        _loc4_ = Global.level.height;
                        _loc3_ = -1;
                     }
                     _loc4_++;
                  }
                  _loc3_--;
               }
               if(_loc5_ < Global.level.width)
               {
                  if(_loc5_ < 10)
                  {
                     _loc5_ = 10;
                  }
                  Global.level.Resize(_loc5_,Global.level.height,0,0);
                  this.hud.SetBorderSize();
               }
            }
            if(Global.level.height > 10)
            {
               _loc5_ = -1;
               _loc4_ = 0;
               while(_loc4_ < Global.level.height)
               {
                  _loc3_ = 0;
                  while(_loc3_ < Global.level.width)
                  {
                     if(!Global.level.IsEmpty(_loc3_,_loc4_))
                     {
                        _loc5_ = _loc4_ - 1;
                        _loc4_ = Global.level.height;
                        _loc3_ = Global.level.width;
                     }
                     _loc3_++;
                  }
                  _loc4_++;
               }
               if(_loc5_ > -1)
               {
                  if(Global.level.height - (_loc5_ + 1) < 10)
                  {
                     _loc5_ = Global.level.height - 11;
                  }
                  Global.level.Resize(Global.level.width,Global.level.height - (_loc5_ + 1),0,_loc5_ + 1);
                  this.hud.SetBorderSize();
               }
               _loc5_ = Global.level.height;
               _loc4_ = int(Global.level.height - 1);
               while(_loc4_ >= 0)
               {
                  _loc3_ = 0;
                  while(_loc3_ < Global.level.width)
                  {
                     if(!Global.level.IsEmpty(_loc3_,_loc4_))
                     {
                        _loc5_ = _loc4_ + 1;
                        _loc4_ = -1;
                        _loc3_ = Global.level.width;
                     }
                     _loc3_++;
                  }
                  _loc4_--;
               }
               if(_loc5_ < Global.level.height)
               {
                  if(_loc5_ < 10)
                  {
                     _loc5_ = 10;
                  }
                  Global.level.Resize(Global.level.width,_loc5_,0,0);
                  this.hud.SetBorderSize();
               }
            }
         }
      }
      
      public function EditUpdate() : void
      {
         if(this.plopping)
         {
            if(FlxG.mouse.pressed())
            {
               this.Plop();
            }
            else
            {
               this.plopping = false;
            }
         }
         else if(FlxG.mouse.justPressed())
         {
            if(!this.hud.ClickCheck())
            {
               this.plopping = true;
            }
         }
         if(FlxG.keys.justPressed("P"))
         {
            this.hud.tilePage = 1 - this.hud.tilePage;
            this.hud.SetToolPage(this.hud.tilePage);
         }
         if(FlxG.keys.justPressed("T"))
         {
            Global.mode = Global.TEST;
            Global.mapStore.GetFromMap();
            FlxG.switchState(new PlayState());
            return;
         }
         if(FlxG.keys.justPressed("ESCAPE"))
         {
            FlxG.switchState(new TitleState());
            return;
         }
         if(Keebie.Dir(Keebie.LEFT))
         {
            FlxG.camera.scroll.x -= FlxG.elapsed * 250;
         }
         if(Keebie.Dir(Keebie.RIGHT))
         {
            FlxG.camera.scroll.x += FlxG.elapsed * 250;
         }
         if(Keebie.Dir(Keebie.UP))
         {
            FlxG.camera.scroll.y -= FlxG.elapsed * 250;
         }
         if(Keebie.Dir(Keebie.DOWN))
         {
            FlxG.camera.scroll.y += FlxG.elapsed * 250;
         }
      }
      
      override public function update() : void
      {
         this.mapAnim += FlxG.elapsed;
         if(this.mapAnim > 0.1)
         {
            Global.level.Animate();
            this.mapAnim -= 0.1;
         }
         this.tileX = FlxG.mouse.x / 16;
         if(this.tileX == 0 && FlxG.mouse.x < 0)
         {
            this.tileX = -1;
         }
         this.tileY = FlxG.mouse.y / 16;
         if(this.tileY == 0 && FlxG.mouse.y < 0)
         {
            this.tileY = -1;
         }
         if(this.mode == EDIT)
         {
            this.EditUpdate();
         }
         super.update();
      }
   }
}

