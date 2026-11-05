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
      
      public function EditHud()
      {
         var _loc1_:FlxSprite = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:Class = null;
         super();
         this.tilePage = 0;
         this.borders = new FlxGroup();
         add(this.borders);
         _loc1_ = new FlxSprite(-1,-1);
         _loc1_.makeGraphic(10 * Global.TILE_WIDTH + 2,1,4278190080);
         this.borders.add(_loc1_);
         _loc1_ = new FlxSprite(-1,0);
         _loc1_.makeGraphic(1,10 * Global.TILE_HEIGHT,4278190080);
         this.borders.add(_loc1_);
         _loc1_ = new FlxSprite(10 * Global.TILE_WIDTH,0);
         _loc1_.makeGraphic(1,10 * Global.TILE_HEIGHT,4278190080);
         this.borders.add(_loc1_);
         _loc1_ = new FlxSprite(-1,10 * Global.TILE_HEIGHT);
         _loc1_.makeGraphic(10 * Global.TILE_WIDTH + 2,1,4278190080);
         this.borders.add(_loc1_);
         this.back = new FlxSprite(320 - 80,0);
         this.back.loadGraphic(EditHudImage);
         this.back.scrollFactor.x = 0;
         this.back.scrollFactor.y = 0;
         add(this.back);
         this.tileSet = new TileSet_Grave();
         this.tiles = new Array();
         _loc2_ = 320 - 80 + 8;
         _loc3_ = 2;
         var _loc4_:int = 0;
         while(_loc4_ < 24)
         {
            _loc1_ = new FlxSprite(_loc2_,_loc3_);
            _loc1_.loadGraphic(EditBoxesImage,true,false,20,20,true);
            _loc1_.scrollFactor.x = 0;
            _loc1_.scrollFactor.y = 0;
            add(_loc1_);
            this.tiles.push(_loc1_);
            _loc2_ += 22;
            if(_loc2_ >= 320 - 20)
            {
               _loc2_ -= 22 * 3;
               _loc3_ += 22;
            }
            _loc4_++;
         }
         _loc2_ = 320 - 80 + 8 + 2;
         _loc3_ = 2 + 2;
         this.toolPix = new Array();
         _loc4_ = 0;
         while(_loc4_ < pageLength)
         {
            _loc1_ = new FlxSprite(_loc2_,_loc3_);
            if(_loc4_ >= this.tileSet.tools.length)
            {
               _loc1_.loadGraphic(this.tileSet.Image(),true,false,16,16,true);
               _loc1_.frame = 0;
            }
            else
            {
               if(this.tileSet.GetTool(_loc4_).layer == Level.LAYER_GOODIE)
               {
                  _loc1_.loadGraphic(Level.GoodieTilesImage,true,false,16,16,true);
               }
               else
               {
                  _loc1_.loadGraphic(this.tileSet.Image(),true,false,16,16,true);
               }
               _loc1_.frame = this.tileSet.GetTool(_loc4_).tiles[0];
            }
            _loc1_.scrollFactor.x = 0;
            _loc1_.scrollFactor.y = 0;
            add(_loc1_);
            this.toolPix.push(_loc1_);
            _loc2_ += 22;
            if(_loc2_ >= 320 - 20)
            {
               _loc2_ -= 22 * 3;
               _loc3_ += 22;
            }
            _loc4_++;
         }
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
      
      public function SetToolPage(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:FlxSprite = null;
         this.tilePage = param1;
         var _loc4_:int = 0;
         while(_loc4_ < pageLength)
         {
            _loc2_ = _loc4_ + this.tilePage * pageLength;
            _loc3_ = this.toolPix[_loc4_];
            if(_loc2_ >= this.tileSet.tools.length)
            {
               _loc3_.loadGraphic(this.tileSet.Image(),true,false,16,16,true);
               _loc3_.frame = 0;
            }
            else
            {
               if(this.tileSet.GetTool(_loc2_).layer == Level.LAYER_GOODIE)
               {
                  _loc3_.loadGraphic(Level.GoodieTilesImage,true,false,16,16,true);
               }
               else
               {
                  _loc3_.loadGraphic(this.tileSet.Image(),true,false,16,16,true);
               }
               _loc3_.frame = this.tileSet.GetTool(_loc2_).tiles[0];
            }
            _loc4_++;
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
         var _loc1_:int = 0;
         var _loc2_:FlxSprite = null;
         super.update();
         _loc1_ = 0;
         for each(_loc2_ in this.tiles)
         {
            if(this.tool == _loc1_ + this.tilePage * pageLength)
            {
               _loc2_.frame = 1;
            }
            else
            {
               _loc2_.frame = 0;
            }
            if(_loc2_.overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               _loc2_.frame = _loc2_.frame % 2 + 2;
            }
            else
            {
               _loc2_.frame = _loc2_.frame % 2 + 0;
            }
            _loc1_++;
         }
      }
      
      public function ClickCheck() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:FlxSprite = null;
         if(FlxG.mouse.screenX < this.back.x)
         {
            return false;
         }
         _loc1_ = 0;
         for each(_loc2_ in this.tiles)
         {
            if(_loc2_.overlapsPoint(FlxG.mouse.getScreenPosition()))
            {
               this.tool = _loc1_ + this.tilePage * pageLength;
            }
            _loc1_++;
         }
         return true;
      }
   }
}

