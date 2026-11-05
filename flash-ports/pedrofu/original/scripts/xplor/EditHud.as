package xplor
{
   import org.flixel.*;
   import xplor.TileSets.TileSet;
   import xplor.TileSets.TileSet_Grave;
   
   public class EditHud extends FlxGroup
   {
      
      public static var EditHudImage:Class = EditHud_EditHudImage;
      
      public static var EditBoxesImage:Class = EditHud_EditBoxesImage;
      
      public static const pageLength:int = 24;
      
      public var tileSet:TileSet;
      
      public var back:FlxSprite;
      
      public var tiles:Array;
      
      public var tool:int;
      
      public var saveTxt:FlxText;
      
      public var loadTxt:FlxText;
      
      public var borders:FlxGroup;
      
      public var tilePage:int;
      
      public var toolPix:Array;
      
      public var coords:FlxText;
      
      public function EditHud()
      {
         var s:FlxSprite = null;
         var x:int = 0;
         var y:int = 0;
         var c:Class = null;
         super();
         this.tilePage = 0;
         this.borders = new FlxGroup();
         add(this.borders);
         s = new FlxSprite(-1,-1);
         s.makeGraphic(10 * Global.TILE_WIDTH + 2,1,4278190080);
         this.borders.add(s);
         s = new FlxSprite(-1,0);
         s.makeGraphic(1,10 * Global.TILE_HEIGHT,4278190080);
         this.borders.add(s);
         s = new FlxSprite(10 * Global.TILE_WIDTH,0);
         s.makeGraphic(1,10 * Global.TILE_HEIGHT,4278190080);
         this.borders.add(s);
         s = new FlxSprite(-1,10 * Global.TILE_HEIGHT);
         s.makeGraphic(10 * Global.TILE_WIDTH + 2,1,4278190080);
         this.borders.add(s);
         this.back = new FlxSprite(320 - 80,0);
         this.back.loadGraphic(EditHudImage);
         this.back.scrollFactor.x = 0;
         this.back.scrollFactor.y = 0;
         add(this.back);
         this.tileSet = new TileSet_Grave();
         this.tiles = new Array();
         x = 320 - 80 + 8;
         y = 2;
         for(var i:int = 0; i < 24; i++)
         {
            s = new FlxSprite(x,y);
            s.loadGraphic(EditBoxesImage,true,false,20,20,true);
            s.scrollFactor.x = 0;
            s.scrollFactor.y = 0;
            add(s);
            this.tiles.push(s);
            x += 22;
            if(x >= 320 - 20)
            {
               x -= 22 * 3;
               y += 22;
            }
         }
         x = 320 - 80 + 8 + 2;
         y = 2 + 2;
         this.toolPix = new Array();
         for(i = 0; i < pageLength; i++)
         {
            s = new FlxSprite(x,y);
            if(i >= this.tileSet.tools.length)
            {
               s.loadGraphic(this.tileSet.Image(),true,false,16,16,true);
               s.frame = 0;
            }
            else
            {
               if(this.tileSet.GetTool(i).layer == Level.LAYER_GOODIE)
               {
                  s.loadGraphic(Level.GoodieTilesImage,true,false,16,16,true);
               }
               else
               {
                  s.loadGraphic(this.tileSet.Image(),true,false,16,16,true);
               }
               s.frame = this.tileSet.GetTool(i).tiles[0];
            }
            s.scrollFactor.x = 0;
            s.scrollFactor.y = 0;
            add(s);
            this.toolPix.push(s);
            x += 22;
            if(x >= 320 - 20)
            {
               x -= 22 * 3;
               y += 22;
            }
         }
         this.coords = new FlxText(320 - 80,180,80,"0,0");
         this.coords.setFormat("",8,16777215,"center",1);
         this.coords.scrollFactor.x = 0;
         this.coords.scrollFactor.y = 0;
         add(this.coords);
         this.loadTxt = new FlxText(320 - 80,200,80,"LOAD");
         this.loadTxt.setFormat("",8,16777215,"center",1);
         this.loadTxt.scrollFactor.x = 0;
         this.loadTxt.scrollFactor.y = 0;
         add(this.loadTxt);
         this.saveTxt = new FlxText(320 - 80,220,80,"SAVE");
         this.saveTxt.setFormat("",8,16777215,"center",1);
         this.saveTxt.scrollFactor.x = 0;
         this.saveTxt.scrollFactor.y = 0;
         add(this.saveTxt);
         this.tool = 0;
      }
      
      public function SetToolPage(pg:int) : void
      {
         var t:int = 0;
         var s:FlxSprite = null;
         this.tilePage = pg;
         for(var i:int = 0; i < pageLength; i++)
         {
            t = i + this.tilePage * pageLength;
            s = this.toolPix[i];
            if(t >= this.tileSet.tools.length)
            {
               s.loadGraphic(this.tileSet.Image(),true,false,16,16,true);
               s.frame = 0;
            }
            else
            {
               if(this.tileSet.GetTool(t).layer == Level.LAYER_GOODIE)
               {
                  s.loadGraphic(Level.GoodieTilesImage,true,false,16,16,true);
               }
               else
               {
                  s.loadGraphic(this.tileSet.Image(),true,false,16,16,true);
               }
               s.frame = this.tileSet.GetTool(t).tiles[0];
            }
         }
      }
      
      public function SetBorderSize() : void
      {
         this.borders.members[0] = new FlxSprite(-1,-1);
         (this.borders.members[0] as FlxSprite).makeGraphic(Global.level.width * Global.TILE_WIDTH + 2,1,4278190080);
         this.borders.members[1] = new FlxSprite(-1,0);
         (this.borders.members[1] as FlxSprite).makeGraphic(1,Global.level.height * Global.TILE_HEIGHT,4278190080);
         this.borders.members[2] = new FlxSprite(Global.level.width * Global.TILE_WIDTH,0);
         (this.borders.members[2] as FlxSprite).makeGraphic(1,Global.level.height * Global.TILE_HEIGHT,4278190080);
         this.borders.members[3] = new FlxSprite(-1,Global.level.height * Global.TILE_HEIGHT);
         (this.borders.members[3] as FlxSprite).makeGraphic(Global.level.width * Global.TILE_WIDTH + 2,1,4278190080);
      }
      
      override public function update() : void
      {
         var i:int = 0;
         var s:FlxSprite = null;
         this.coords.text = EditState(FlxG.state).tileX.toString() + "," + EditState(FlxG.state).tileY.toString();
         super.update();
         i = 0;
         for each(s in this.tiles)
         {
            if(this.tool == i + this.tilePage * pageLength)
            {
               s.frame = 1;
            }
            else
            {
               s.frame = 0;
            }
            if(s.overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               s.frame = s.frame % 2 + 2;
            }
            else
            {
               s.frame = s.frame % 2 + 0;
            }
            i++;
         }
      }
      
      public function ClickCheck() : Boolean
      {
         var i:int = 0;
         var s:FlxSprite = null;
         if(FlxG.mouse.screenX < this.back.x)
         {
            return false;
         }
         i = 0;
         for each(s in this.tiles)
         {
            if(s.overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               this.tool = i + this.tilePage * pageLength;
            }
            i++;
         }
         return true;
      }
   }
}

