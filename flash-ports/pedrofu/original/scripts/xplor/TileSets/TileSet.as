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
      
      public function GetTool(i:int) : TileDef
      {
         if(i < 0 || i >= this.tools.length)
         {
            return null;
         }
         return this.tools[i];
      }
      
      public function SetProperties(map:FlxTilemapExt) : void
      {
         var i:int = 0;
         for(i = 0; i < this.properties.length; i++)
         {
            if(this.properties[i] != null)
            {
               map.setTileProperties(i,this.properties[i]);
            }
         }
      }
   }
}

