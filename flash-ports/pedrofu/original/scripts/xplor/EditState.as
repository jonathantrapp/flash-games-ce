package xplor
{
   import flash.events.*;
   import flash.net.*;
   import org.flixel.*;
   
   public class EditState extends FlxState
   {
      
      public static const EDIT:uint = 0;
      
      public static const LOAD:uint = 1;
      
      public static const SAVE:uint = 2;
      
      private static const FILE_TYPES:Array = [new FileFilter("PedroFuLevel","*.pfu")];
      
      private static const DEFAULT_FILE_NAME:String = "level01.pfu";
      
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
      
      public function onFileSelect(e:Event) : void
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
      
      public function onCancel(e:Event) : void
      {
         this.mode = EDIT;
         this.KillLoader();
      }
      
      public function onLoadComplete(e:Event) : void
      {
         Global.mapStore.LoadFromArray(this.fileRef.data);
         Global.level.LoadStore(Global.mapStore);
         Global.level.GoodieMap();
         this.KillLoader();
         this.mode = EDIT;
      }
      
      public function onLoadError(e:IOErrorEvent) : void
      {
         trace("Error loading file : " + e.text);
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
      
      public function onFileSave(e:Event) : void
      {
         trace("File Saved");
         this.fileRef = null;
         this.mode = EDIT;
      }
      
      public function onSaveCancel(e:Event) : void
      {
         this.fileRef = null;
         this.mode = EDIT;
      }
      
      public function onSaveError(e:IOErrorEvent) : void
      {
         trace("Error Saving File : " + e.text);
         this.fileRef = null;
         this.mode = EDIT;
      }
      
      public function PotentialSaveClick(e:MouseEvent) : void
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
      
      public function Clean(x:int, y:int) : void
      {
         var i:int = 0;
         var j:int = 0;
         var t:int = 0;
         for(i = x - 1; i <= x + 1; i++)
         {
            for(j = y - 1; j <= y + 1; j++)
            {
               if(Global.level.OnTheMap(i,j))
               {
                  for(t = 1; t < this.hud.tileSet.tools.length; t++)
                  {
                     if(this.hud.tileSet.GetTool(t).IsThis(i,j,false,true))
                     {
                        Global.level.GetLayer(this.hud.tileSet.GetTool(t).layer).setTile(i,j,this.hud.tileSet.GetTool(t).ChooseTile(i,j));
                     }
                  }
               }
            }
         }
         for(i = x - 1; i <= x + 1; i++)
         {
            for(j = y - 1; j <= y + 1; j++)
            {
               if(Global.level.OnTheMap(i,j))
               {
                  t = int(Global.level.GetLayer(Level.LAYER_BACK).getTile(i,j));
                  if(t >= 28 && t <= 32 && j < Global.level.height - 1)
                  {
                     Global.level.GetLayer(Level.LAYER_SOLID).setTile(i,j + 1,33);
                  }
               }
            }
         }
      }
      
      public function Plop() : void
      {
         var sx:int = 0;
         var sy:int = 0;
         var newWid:int = 0;
         var newHei:int = 0;
         if(this.hud.tool == 0)
         {
            this.ClearSpot(this.tileX,this.tileY);
         }
         else
         {
            sx = 0;
            sy = 0;
            newWid = Global.level.width;
            newHei = Global.level.height;
            if(this.tileX < 0)
            {
               sx = -this.tileX;
               newWid = Global.level.width - this.tileX;
            }
            else if(this.tileX >= Global.level.width)
            {
               sx = 0;
               newWid = this.tileX + 1;
            }
            if(this.tileY < 0)
            {
               sy = -this.tileY;
               newHei = Global.level.height - this.tileY;
            }
            else if(this.tileY >= Global.level.height)
            {
               sy = 0;
               newHei = this.tileY + 1;
            }
            if(newWid * newHei > 10000)
            {
               return;
            }
            if(sx != 0 || sy != 0 || newWid != Global.level.width || newHei != Global.level.height)
            {
               Global.level.Resize(newWid,newHei,-sx,-sy);
               this.hud.SetBorderSize();
            }
            this.tileX += sx;
            this.tileY += sy;
            Global.level.GetLayer(this.hud.tileSet.GetTool(this.hud.tool).layer).setTile(this.tileX,this.tileY,this.hud.tileSet.GetTool(this.hud.tool).ChooseTile(this.tileX,this.tileY));
            this.Clean(this.tileX,this.tileY);
         }
      }
      
      public function ClearSpot(tx:int, ty:int) : void
      {
         var i:int = 0;
         var j:int = 0;
         var empty:int = 0;
         if(tx >= 0 && ty >= 0 && tx < Global.level.width && ty < Global.level.height)
         {
            Global.level.ClearSpot(tx,ty);
            this.Clean(tx,ty);
            if(Global.level.width > 10)
            {
               empty = -1;
               for(i = 0; i < Global.level.width; i++)
               {
                  for(j = 0; j < Global.level.height; j++)
                  {
                     if(!Global.level.IsEmpty(i,j))
                     {
                        empty = i - 1;
                        j = Global.level.height;
                        i = Global.level.width;
                     }
                  }
               }
               if(empty > -1)
               {
                  if(Global.level.width - (empty + 1) < 10)
                  {
                     empty = Global.level.width - 11;
                  }
                  Global.level.Resize(Global.level.width - (empty + 1),Global.level.height,empty + 1,0);
                  this.hud.SetBorderSize();
               }
               empty = Global.level.width;
               for(i = Global.level.width - 1; i >= 0; i--)
               {
                  for(j = 0; j < Global.level.height; j++)
                  {
                     if(!Global.level.IsEmpty(i,j))
                     {
                        empty = i + 1;
                        j = Global.level.height;
                        i = -1;
                     }
                  }
               }
               if(empty < Global.level.width)
               {
                  if(empty < 10)
                  {
                     empty = 10;
                  }
                  Global.level.Resize(empty,Global.level.height,0,0);
                  this.hud.SetBorderSize();
               }
            }
            if(Global.level.height > 10)
            {
               empty = -1;
               for(j = 0; j < Global.level.height; j++)
               {
                  for(i = 0; i < Global.level.width; i++)
                  {
                     if(!Global.level.IsEmpty(i,j))
                     {
                        empty = j - 1;
                        j = Global.level.height;
                        i = Global.level.width;
                     }
                  }
               }
               if(empty > -1)
               {
                  if(Global.level.height - (empty + 1) < 10)
                  {
                     empty = Global.level.height - 11;
                  }
                  Global.level.Resize(Global.level.width,Global.level.height - (empty + 1),0,empty + 1);
                  this.hud.SetBorderSize();
               }
               empty = Global.level.height;
               for(j = Global.level.height - 1; j >= 0; j--)
               {
                  for(i = 0; i < Global.level.width; i++)
                  {
                     if(!Global.level.IsEmpty(i,j))
                     {
                        empty = j + 1;
                        j = -1;
                        i = Global.level.width;
                     }
                  }
               }
               if(empty < Global.level.height)
               {
                  if(empty < 10)
                  {
                     empty = 10;
                  }
                  Global.level.Resize(Global.level.width,empty,0,0);
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
            ++this.hud.tilePage;
            if(this.hud.tilePage > 3)
            {
               this.hud.tilePage = 0;
            }
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

