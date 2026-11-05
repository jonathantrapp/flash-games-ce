package xplor.TileSets
{
   import org.flixel.FlxTilemapExt;
   
   public class TileSet
   {
      
      public var tools:Array;
      
      public var properties:Array;
      
      public function TileSet()
      {
         super();
         this.properties = new Array();
         this.tools = new Array();
         this.tools[0] = new TileDef(99,0,0);
      }
      
      public function Image() : Class
      {
         return null;
      }
      
      public function GetTool(param1:int) : TileDef
      {
         if(param1 < 0 || param1 >= this.tools.length)
         {
            return null;
         }
         return this.tools[param1];
      }
      
      public function SetProperties(param1:FlxTilemapExt) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this.properties.length)
         {
            if(this.properties[_loc2_] != null)
            {
               param1.setTileProperties(_loc2_,this.properties[_loc2_]);
            }
            _loc2_++;
         }
      }
   }
}

