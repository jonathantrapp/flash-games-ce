package org.flixel
{
   import flash.display.Graphics;
   import org.flixel.plugin.DebugPathDisplay;
   
   public class FlxPath
   {
      
      public var nodes:Array;
      
      public var debugColor:uint;
      
      public var debugScrollFactor:FlxPoint;
      
      public var ignoreDrawDebug:Boolean;
      
      protected var _point:FlxPoint;
      
      public function FlxPath(Nodes:Array = null)
      {
         super();
         if(Nodes == null)
         {
            this.nodes = new Array();
         }
         else
         {
            this.nodes = Nodes;
         }
         this._point = new FlxPoint();
         this.debugScrollFactor = new FlxPoint(1,1);
         this.debugColor = 16777215;
         this.ignoreDrawDebug = false;
         var debugPathDisplay:DebugPathDisplay = manager;
         if(debugPathDisplay != null)
         {
            debugPathDisplay.add(this);
         }
      }
      
      public static function get manager() : DebugPathDisplay
      {
         return FlxG.getPlugin(DebugPathDisplay) as DebugPathDisplay;
      }
      
      public function destroy() : void
      {
         var debugPathDisplay:DebugPathDisplay = manager;
         if(debugPathDisplay != null)
         {
            debugPathDisplay.remove(this);
         }
         this.debugScrollFactor = null;
         this._point = null;
         this.nodes = null;
      }
      
      public function add(X:Number, Y:Number) : void
      {
         this.nodes.push(new FlxPoint(X,Y));
      }
      
      public function addAt(X:Number, Y:Number, Index:uint) : void
      {
         if(Index > this.nodes.length)
         {
            Index = this.nodes.length;
         }
         this.nodes.splice(Index,0,new FlxPoint(X,Y));
      }
      
      public function addPoint(Node:FlxPoint, AsReference:Boolean = false) : void
      {
         if(AsReference)
         {
            this.nodes.push(Node);
         }
         else
         {
            this.nodes.push(new FlxPoint(Node.x,Node.y));
         }
      }
      
      public function addPointAt(Node:FlxPoint, Index:uint, AsReference:Boolean = false) : void
      {
         if(Index > this.nodes.length)
         {
            Index = this.nodes.length;
         }
         if(AsReference)
         {
            this.nodes.splice(Index,0,Node);
         }
         else
         {
            this.nodes.splice(Index,0,new FlxPoint(Node.x,Node.y));
         }
      }
      
      public function remove(Node:FlxPoint) : FlxPoint
      {
         var index:int = this.nodes.indexOf(Node);
         if(index >= 0)
         {
            return this.nodes.splice(index,1)[0];
         }
         return null;
      }
      
      public function removeAt(Index:uint) : FlxPoint
      {
         if(this.nodes.length <= 0)
         {
            return null;
         }
         if(Index >= this.nodes.length)
         {
            Index = this.nodes.length - 1;
         }
         return this.nodes.splice(Index,1)[0];
      }
      
      public function head() : FlxPoint
      {
         if(this.nodes.length > 0)
         {
            return this.nodes[0];
         }
         return null;
      }
      
      public function tail() : FlxPoint
      {
         if(this.nodes.length > 0)
         {
            return this.nodes[this.nodes.length - 1];
         }
         return null;
      }
      
      public function drawDebug(Camera:FlxCamera = null) : void
      {
         var node:FlxPoint = null;
         var nextNode:FlxPoint = null;
         var nodeSize:uint = 0;
         var nodeColor:uint = 0;
         var linealpha:Number = NaN;
         if(this.nodes.length <= 0)
         {
            return;
         }
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         var gfx:Graphics = FlxG.flashGfx;
         gfx.clear();
         var i:uint = 0;
         var l:uint = this.nodes.length;
         while(i < l)
         {
            node = this.nodes[i] as FlxPoint;
            this._point.x = node.x - int(Camera.scroll.x * this.debugScrollFactor.x);
            this._point.y = node.y - int(Camera.scroll.y * this.debugScrollFactor.y);
            this._point.x = int(this._point.x + (this._point.x > 0 ? 1e-7 : -1e-7));
            this._point.y = int(this._point.y + (this._point.y > 0 ? 1e-7 : -1e-7));
            nodeSize = 2;
            if(i == 0 || i == l - 1)
            {
               nodeSize *= 2;
            }
            nodeColor = this.debugColor;
            if(l > 1)
            {
               if(i == 0)
               {
                  nodeColor = FlxG.GREEN;
               }
               else if(i == l - 1)
               {
                  nodeColor = FlxG.RED;
               }
            }
            gfx.beginFill(nodeColor,0.5);
            gfx.lineStyle();
            gfx.drawRect(this._point.x - nodeSize * 0.5,this._point.y - nodeSize * 0.5,nodeSize,nodeSize);
            gfx.endFill();
            linealpha = 0.3;
            if(i < l - 1)
            {
               nextNode = this.nodes[i + 1];
            }
            else
            {
               nextNode = this.nodes[0];
               linealpha = 0.15;
            }
            gfx.moveTo(this._point.x,this._point.y);
            gfx.lineStyle(1,this.debugColor,linealpha);
            this._point.x = nextNode.x - int(Camera.scroll.x * this.debugScrollFactor.x);
            this._point.y = nextNode.y - int(Camera.scroll.y * this.debugScrollFactor.y);
            this._point.x = int(this._point.x + (this._point.x > 0 ? 1e-7 : -1e-7));
            this._point.y = int(this._point.y + (this._point.y > 0 ? 1e-7 : -1e-7));
            gfx.lineTo(this._point.x,this._point.y);
            i++;
         }
         Camera.buffer.draw(FlxG.flashGfxSprite);
      }
   }
}

