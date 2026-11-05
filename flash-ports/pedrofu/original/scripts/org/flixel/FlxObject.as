package org.flixel
{
   import flash.display.Graphics;
   
   public class FlxObject extends FlxBasic
   {
      
      public static const LEFT:uint = 1;
      
      public static const RIGHT:uint = 16;
      
      public static const UP:uint = 256;
      
      public static const DOWN:uint = 4096;
      
      public static const NONE:uint = 0;
      
      public static const CEILING:uint = UP;
      
      public static const FLOOR:uint = DOWN;
      
      public static const WALL:uint = LEFT | RIGHT;
      
      public static const ANY:uint = LEFT | RIGHT | UP | DOWN;
      
      public static const OVERLAP_BIAS:Number = 4;
      
      public static const PATH_FORWARD:uint = 0;
      
      public static const PATH_BACKWARD:uint = 1;
      
      public static const PATH_LOOP_FORWARD:uint = 16;
      
      public static const PATH_LOOP_BACKWARD:uint = 256;
      
      public static const PATH_YOYO:uint = 4096;
      
      public static const PATH_HORIZONTAL_ONLY:uint = 65536;
      
      public static const PATH_VERTICAL_ONLY:uint = 1048576;
      
      protected static const _pZero:FlxPoint = new FlxPoint();
      
      public var x:Number;
      
      public var y:Number;
      
      public var width:Number;
      
      public var height:Number;
      
      public var immovable:Boolean;
      
      public var velocity:FlxPoint;
      
      public var mass:Number;
      
      public var elasticity:Number;
      
      public var acceleration:FlxPoint;
      
      public var drag:FlxPoint;
      
      public var maxVelocity:FlxPoint;
      
      public var angle:Number;
      
      public var angularVelocity:Number;
      
      public var angularAcceleration:Number;
      
      public var angularDrag:Number;
      
      public var maxAngular:Number;
      
      public var scrollFactor:FlxPoint;
      
      protected var _flicker:Boolean;
      
      protected var _flickerTimer:Number;
      
      public var health:Number;
      
      protected var _point:FlxPoint;
      
      protected var _rect:FlxRect;
      
      public var moves:Boolean;
      
      public var touching:uint;
      
      public var wasTouching:uint;
      
      public var allowCollisions:uint;
      
      public var last:FlxPoint;
      
      public var path:FlxPath;
      
      public var pathSpeed:Number;
      
      public var pathAngle:Number;
      
      protected var _pathNodeIndex:int;
      
      protected var _pathMode:uint;
      
      protected var _pathInc:int;
      
      protected var _pathRotate:Boolean;
      
      public function FlxObject(X:Number = 0, Y:Number = 0, Width:Number = 0, Height:Number = 0)
      {
         super();
         this.x = X;
         this.y = Y;
         this.last = new FlxPoint(this.x,this.y);
         this.width = Width;
         this.height = Height;
         this.mass = 1;
         this.elasticity = 0;
         this.immovable = false;
         this.moves = true;
         this.touching = NONE;
         this.wasTouching = NONE;
         this.allowCollisions = ANY;
         this.velocity = new FlxPoint();
         this.acceleration = new FlxPoint();
         this.drag = new FlxPoint();
         this.maxVelocity = new FlxPoint(10000,10000);
         this.angle = 0;
         this.angularVelocity = 0;
         this.angularAcceleration = 0;
         this.angularDrag = 0;
         this.maxAngular = 10000;
         this.scrollFactor = new FlxPoint(1,1);
         this._flicker = false;
         this._flickerTimer = 0;
         this._point = new FlxPoint();
         this._rect = new FlxRect();
         this.path = null;
         this.pathSpeed = 0;
         this.pathAngle = 0;
      }
      
      public static function separate(Object1:FlxObject, Object2:FlxObject) : Boolean
      {
         var separatedX:Boolean = separateX(Object1,Object2);
         var separatedY:Boolean = separateY(Object1,Object2);
         return separatedX || separatedY;
      }
      
      public static function separateX(Object1:FlxObject, Object2:FlxObject) : Boolean
      {
         var obj1deltaAbs:Number = NaN;
         var obj2deltaAbs:Number = NaN;
         var obj1rect:FlxRect = null;
         var obj2rect:FlxRect = null;
         var maxOverlap:Number = NaN;
         var obj1v:Number = NaN;
         var obj2v:Number = NaN;
         var obj1velocity:Number = NaN;
         var obj2velocity:Number = NaN;
         var average:Number = NaN;
         var obj1immovable:Boolean = Object1.immovable;
         var obj2immovable:Boolean = Object2.immovable;
         if(obj1immovable && obj2immovable)
         {
            return false;
         }
         if(Object1 is FlxTilemap)
         {
            return (Object1 as FlxTilemap).overlapsWithCallback(Object2,separateX);
         }
         if(Object2 is FlxTilemap)
         {
            return (Object2 as FlxTilemap).overlapsWithCallback(Object1,separateX,true);
         }
         var overlap:Number = 0;
         var obj1delta:Number = Object1.x - Object1.last.x;
         var obj2delta:Number = Object2.x - Object2.last.x;
         if(obj1delta != obj2delta)
         {
            obj1deltaAbs = obj1delta > 0 ? obj1delta : -obj1delta;
            obj2deltaAbs = obj2delta > 0 ? obj2delta : -obj2delta;
            obj1rect = new FlxRect(Object1.x - (obj1delta > 0 ? obj1delta : 0),Object1.last.y,Object1.width + (obj1delta > 0 ? obj1delta : -obj1delta),Object1.height);
            obj2rect = new FlxRect(Object2.x - (obj2delta > 0 ? obj2delta : 0),Object2.last.y,Object2.width + (obj2delta > 0 ? obj2delta : -obj2delta),Object2.height);
            if(obj1rect.x + obj1rect.width > obj2rect.x && obj1rect.x < obj2rect.x + obj2rect.width && obj1rect.y + obj1rect.height > obj2rect.y && obj1rect.y < obj2rect.y + obj2rect.height)
            {
               maxOverlap = obj1deltaAbs + obj2deltaAbs + OVERLAP_BIAS;
               if(obj1delta > obj2delta)
               {
                  overlap = Object1.x + Object1.width - Object2.x;
                  if(overlap > maxOverlap || !(Object1.allowCollisions & RIGHT) || !(Object2.allowCollisions & LEFT))
                  {
                     overlap = 0;
                  }
                  else
                  {
                     Object1.touching |= RIGHT;
                     Object2.touching |= LEFT;
                  }
               }
               else if(obj1delta < obj2delta)
               {
                  overlap = Object1.x - Object2.width - Object2.x;
                  if(-overlap > maxOverlap || !(Object1.allowCollisions & LEFT) || !(Object2.allowCollisions & RIGHT))
                  {
                     overlap = 0;
                  }
                  else
                  {
                     Object1.touching |= LEFT;
                     Object2.touching |= RIGHT;
                  }
               }
            }
         }
         if(overlap != 0)
         {
            obj1v = Object1.velocity.x;
            obj2v = Object2.velocity.x;
            if(!obj1immovable && !obj2immovable)
            {
               overlap *= 0.5;
               Object1.x -= overlap;
               Object2.x += overlap;
               obj1velocity = Math.sqrt(obj2v * obj2v * Object2.mass / Object1.mass) * (obj2v > 0 ? 1 : -1);
               obj2velocity = Math.sqrt(obj1v * obj1v * Object1.mass / Object2.mass) * (obj1v > 0 ? 1 : -1);
               average = (obj1velocity + obj2velocity) * 0.5;
               obj1velocity -= average;
               obj2velocity -= average;
               Object1.velocity.x = average + obj1velocity * Object1.elasticity;
               Object2.velocity.x = average + obj2velocity * Object2.elasticity;
            }
            else if(!obj1immovable)
            {
               Object1.x -= overlap;
               Object1.velocity.x = obj2v - obj1v * Object1.elasticity;
            }
            else if(!obj2immovable)
            {
               Object2.x += overlap;
               Object2.velocity.x = obj1v - obj2v * Object2.elasticity;
            }
            return true;
         }
         return false;
      }
      
      public static function separateY(Object1:FlxObject, Object2:FlxObject) : Boolean
      {
         var obj1deltaAbs:Number = NaN;
         var obj2deltaAbs:Number = NaN;
         var obj1rect:FlxRect = null;
         var obj2rect:FlxRect = null;
         var maxOverlap:Number = NaN;
         var obj1v:Number = NaN;
         var obj2v:Number = NaN;
         var obj1velocity:Number = NaN;
         var obj2velocity:Number = NaN;
         var average:Number = NaN;
         var obj1immovable:Boolean = Object1.immovable;
         var obj2immovable:Boolean = Object2.immovable;
         if(obj1immovable && obj2immovable)
         {
            return false;
         }
         if(Object1 is FlxTilemap)
         {
            return (Object1 as FlxTilemap).overlapsWithCallback(Object2,separateY);
         }
         if(Object2 is FlxTilemap)
         {
            return (Object2 as FlxTilemap).overlapsWithCallback(Object1,separateY,true);
         }
         var overlap:Number = 0;
         var obj1delta:Number = Object1.y - Object1.last.y;
         var obj2delta:Number = Object2.y - Object2.last.y;
         if(obj1delta != obj2delta)
         {
            obj1deltaAbs = obj1delta > 0 ? obj1delta : -obj1delta;
            obj2deltaAbs = obj2delta > 0 ? obj2delta : -obj2delta;
            obj1rect = new FlxRect(Object1.x,Object1.y - (obj1delta > 0 ? obj1delta : 0),Object1.width,Object1.height + obj1deltaAbs);
            obj2rect = new FlxRect(Object2.x,Object2.y - (obj2delta > 0 ? obj2delta : 0),Object2.width,Object2.height + obj2deltaAbs);
            if(obj1rect.x + obj1rect.width > obj2rect.x && obj1rect.x < obj2rect.x + obj2rect.width && obj1rect.y + obj1rect.height > obj2rect.y && obj1rect.y < obj2rect.y + obj2rect.height)
            {
               maxOverlap = obj1deltaAbs + obj2deltaAbs + OVERLAP_BIAS;
               if(obj1delta > obj2delta)
               {
                  overlap = Object1.y + Object1.height - Object2.y;
                  if(overlap > maxOverlap || !(Object1.allowCollisions & DOWN) || !(Object2.allowCollisions & UP))
                  {
                     overlap = 0;
                  }
                  else
                  {
                     Object1.touching |= DOWN;
                     Object2.touching |= UP;
                  }
               }
               else if(obj1delta < obj2delta)
               {
                  overlap = Object1.y - Object2.height - Object2.y;
                  if(-overlap > maxOverlap || !(Object1.allowCollisions & UP) || !(Object2.allowCollisions & DOWN))
                  {
                     overlap = 0;
                  }
                  else
                  {
                     Object1.touching |= UP;
                     Object2.touching |= DOWN;
                  }
               }
            }
         }
         if(overlap != 0)
         {
            obj1v = Object1.velocity.y;
            obj2v = Object2.velocity.y;
            if(!obj1immovable && !obj2immovable)
            {
               overlap *= 0.5;
               Object1.y -= overlap;
               Object2.y += overlap;
               obj1velocity = Math.sqrt(obj2v * obj2v * Object2.mass / Object1.mass) * (obj2v > 0 ? 1 : -1);
               obj2velocity = Math.sqrt(obj1v * obj1v * Object1.mass / Object2.mass) * (obj1v > 0 ? 1 : -1);
               average = (obj1velocity + obj2velocity) * 0.5;
               obj1velocity -= average;
               obj2velocity -= average;
               Object1.velocity.y = average + obj1velocity * Object1.elasticity;
               Object2.velocity.y = average + obj2velocity * Object2.elasticity;
            }
            else if(!obj1immovable)
            {
               Object1.y -= overlap;
               Object1.velocity.y = obj2v - obj1v * Object1.elasticity;
               if(Object2.active && Object2.moves && obj1delta > obj2delta)
               {
                  Object1.x += Object2.x - Object2.last.x;
               }
            }
            else if(!obj2immovable)
            {
               Object2.y += overlap;
               Object2.velocity.y = obj1v - obj2v * Object2.elasticity;
               if(Object1.active && Object1.moves && obj1delta < obj2delta)
               {
                  Object2.x += Object1.x - Object1.last.x;
               }
            }
            return true;
         }
         return false;
      }
      
      override public function destroy() : void
      {
         this.velocity = null;
         this.acceleration = null;
         this.drag = null;
         this.maxVelocity = null;
         this.scrollFactor = null;
         this._point = null;
         this._rect = null;
         this.last = null;
         cameras = null;
         if(this.path != null)
         {
            this.path.destroy();
         }
         this.path = null;
      }
      
      override public function preUpdate() : void
      {
         ++_ACTIVECOUNT;
         if(this._flickerTimer != 0)
         {
            if(this._flickerTimer > 0)
            {
               this._flickerTimer -= FlxG.elapsed;
               if(this._flickerTimer <= 0)
               {
                  this._flickerTimer = 0;
                  this._flicker = false;
               }
            }
         }
         this.last.x = this.x;
         this.last.y = this.y;
         if(this.path != null && this.pathSpeed != 0 && this.path.nodes[this._pathNodeIndex] != null)
         {
            this.updatePathMotion();
         }
      }
      
      override public function postUpdate() : void
      {
         if(this.moves)
         {
            this.updateMotion();
         }
         this.wasTouching = this.touching;
         this.touching = NONE;
      }
      
      protected function updateMotion() : void
      {
         var delta:Number = NaN;
         var velocityDelta:Number = NaN;
         velocityDelta = (FlxU.computeVelocity(this.angularVelocity,this.angularAcceleration,this.angularDrag,this.maxAngular) - this.angularVelocity) / 2;
         this.angularVelocity += velocityDelta;
         this.angle += this.angularVelocity * FlxG.elapsed;
         this.angularVelocity += velocityDelta;
         velocityDelta = (FlxU.computeVelocity(this.velocity.x,this.acceleration.x,this.drag.x,this.maxVelocity.x) - this.velocity.x) / 2;
         this.velocity.x += velocityDelta;
         delta = this.velocity.x * FlxG.elapsed;
         this.velocity.x += velocityDelta;
         this.x += delta;
         velocityDelta = (FlxU.computeVelocity(this.velocity.y,this.acceleration.y,this.drag.y,this.maxVelocity.y) - this.velocity.y) / 2;
         this.velocity.y += velocityDelta;
         delta = this.velocity.y * FlxG.elapsed;
         this.velocity.y += velocityDelta;
         this.y += delta;
      }
      
      override public function draw() : void
      {
         var camera:FlxCamera = null;
         if(cameras == null)
         {
            cameras = FlxG.cameras;
         }
         var i:uint = 0;
         var l:uint = cameras.length;
         while(i < l)
         {
            camera = cameras[i++];
            if(this.onScreen(camera))
            {
               ++_VISIBLECOUNT;
               if(FlxG.visualDebug && !ignoreDrawDebug)
               {
                  this.drawDebug(camera);
               }
            }
         }
      }
      
      override public function drawDebug(Camera:FlxCamera = null) : void
      {
         var boundingBoxColor:uint = 0;
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         var boundingBoxX:Number = this.x - int(Camera.scroll.x * this.scrollFactor.x);
         var boundingBoxY:Number = this.y - int(Camera.scroll.y * this.scrollFactor.y);
         boundingBoxX = int(boundingBoxX + (boundingBoxX > 0 ? 1e-7 : -1e-7));
         boundingBoxY = int(boundingBoxY + (boundingBoxY > 0 ? 1e-7 : -1e-7));
         var boundingBoxWidth:int = this.width != int(this.width) ? int(this.width) : int(this.width - 1);
         var boundingBoxHeight:int = this.height != int(this.height) ? int(this.height) : int(this.height - 1);
         var gfx:Graphics = FlxG.flashGfx;
         gfx.clear();
         gfx.moveTo(boundingBoxX,boundingBoxY);
         if(Boolean(this.allowCollisions))
         {
            if(this.allowCollisions != ANY)
            {
               boundingBoxColor = FlxG.PINK;
            }
            if(this.immovable)
            {
               boundingBoxColor = FlxG.GREEN;
            }
            else
            {
               boundingBoxColor = FlxG.RED;
            }
         }
         else
         {
            boundingBoxColor = FlxG.BLUE;
         }
         gfx.lineStyle(1,boundingBoxColor,0.5);
         gfx.lineTo(boundingBoxX + boundingBoxWidth,boundingBoxY);
         gfx.lineTo(boundingBoxX + boundingBoxWidth,boundingBoxY + boundingBoxHeight);
         gfx.lineTo(boundingBoxX,boundingBoxY + boundingBoxHeight);
         gfx.lineTo(boundingBoxX,boundingBoxY);
         Camera.buffer.draw(FlxG.flashGfxSprite);
      }
      
      public function followPath(Path:FlxPath, Speed:Number = 100, Mode:uint = 0, AutoRotate:Boolean = false) : void
      {
         if(Path.nodes.length <= 0)
         {
            FlxG.log("WARNING: Paths need at least one node in them to be followed.");
            return;
         }
         this.path = Path;
         this.pathSpeed = FlxU.abs(Speed);
         this._pathMode = Mode;
         this._pathRotate = AutoRotate;
         if(this._pathMode == PATH_BACKWARD || this._pathMode == PATH_LOOP_BACKWARD)
         {
            this._pathNodeIndex = this.path.nodes.length - 1;
            this._pathInc = -1;
         }
         else
         {
            this._pathNodeIndex = 0;
            this._pathInc = 1;
         }
      }
      
      public function stopFollowingPath(DestroyPath:Boolean = false) : void
      {
         this.pathSpeed = 0;
         if(DestroyPath && this.path != null)
         {
            this.path.destroy();
            this.path = null;
         }
      }
      
      protected function advancePath(Snap:Boolean = true) : FlxPoint
      {
         var oldNode:FlxPoint = null;
         if(Snap)
         {
            oldNode = this.path.nodes[this._pathNodeIndex];
            if(oldNode != null)
            {
               if((this._pathMode & PATH_VERTICAL_ONLY) == 0)
               {
                  this.x = oldNode.x - this.width * 0.5;
               }
               if((this._pathMode & PATH_HORIZONTAL_ONLY) == 0)
               {
                  this.y = oldNode.y - this.height * 0.5;
               }
            }
         }
         this._pathNodeIndex += this._pathInc;
         if((this._pathMode & PATH_BACKWARD) > 0)
         {
            if(this._pathNodeIndex < 0)
            {
               this._pathNodeIndex = 0;
               this.pathSpeed = 0;
            }
         }
         else if((this._pathMode & PATH_LOOP_FORWARD) > 0)
         {
            if(this._pathNodeIndex >= this.path.nodes.length)
            {
               this._pathNodeIndex = 0;
            }
         }
         else if((this._pathMode & PATH_LOOP_BACKWARD) > 0)
         {
            if(this._pathNodeIndex < 0)
            {
               this._pathNodeIndex = this.path.nodes.length - 1;
               if(this._pathNodeIndex < 0)
               {
                  this._pathNodeIndex = 0;
               }
            }
         }
         else if((this._pathMode & PATH_YOYO) > 0)
         {
            if(this._pathInc > 0)
            {
               if(this._pathNodeIndex >= this.path.nodes.length)
               {
                  this._pathNodeIndex = this.path.nodes.length - 2;
                  if(this._pathNodeIndex < 0)
                  {
                     this._pathNodeIndex = 0;
                  }
                  this._pathInc = -this._pathInc;
               }
            }
            else if(this._pathNodeIndex < 0)
            {
               this._pathNodeIndex = 1;
               if(this._pathNodeIndex >= this.path.nodes.length)
               {
                  this._pathNodeIndex = this.path.nodes.length - 1;
               }
               if(this._pathNodeIndex < 0)
               {
                  this._pathNodeIndex = 0;
               }
               this._pathInc = -this._pathInc;
            }
         }
         else if(this._pathNodeIndex >= this.path.nodes.length)
         {
            this._pathNodeIndex = this.path.nodes.length - 1;
            this.pathSpeed = 0;
         }
         return this.path.nodes[this._pathNodeIndex];
      }
      
      protected function updatePathMotion() : void
      {
         this._point.x = this.x + this.width * 0.5;
         this._point.y = this.y + this.height * 0.5;
         var node:FlxPoint = this.path.nodes[this._pathNodeIndex];
         var deltaX:Number = node.x - this._point.x;
         var deltaY:Number = node.y - this._point.y;
         var horizontalOnly:Boolean = (this._pathMode & PATH_HORIZONTAL_ONLY) > 0;
         var verticalOnly:Boolean = (this._pathMode & PATH_VERTICAL_ONLY) > 0;
         if(horizontalOnly)
         {
            if((deltaX > 0 ? deltaX : -deltaX) < this.pathSpeed * FlxG.elapsed)
            {
               node = this.advancePath();
            }
         }
         else if(verticalOnly)
         {
            if((deltaY > 0 ? deltaY : -deltaY) < this.pathSpeed * FlxG.elapsed)
            {
               node = this.advancePath();
            }
         }
         else if(Math.sqrt(deltaX * deltaX + deltaY * deltaY) < this.pathSpeed * FlxG.elapsed)
         {
            node = this.advancePath();
         }
         if(this.pathSpeed != 0)
         {
            this._point.x = this.x + this.width * 0.5;
            this._point.y = this.y + this.height * 0.5;
            if(horizontalOnly || this._point.y == node.y)
            {
               this.velocity.x = this._point.x < node.x ? this.pathSpeed : -this.pathSpeed;
               if(this.velocity.x < 0)
               {
                  this.pathAngle = -90;
               }
               else
               {
                  this.pathAngle = 90;
               }
               if(!horizontalOnly)
               {
                  this.velocity.y = 0;
               }
            }
            else if(verticalOnly || this._point.x == node.x)
            {
               this.velocity.y = this._point.y < node.y ? this.pathSpeed : -this.pathSpeed;
               if(this.velocity.y < 0)
               {
                  this.pathAngle = 0;
               }
               else
               {
                  this.pathAngle = 180;
               }
               if(!verticalOnly)
               {
                  this.velocity.x = 0;
               }
            }
            else
            {
               this.pathAngle = FlxU.getAngle(this._point,node);
               FlxU.rotatePoint(0,this.pathSpeed,0,0,this.pathAngle,this.velocity);
            }
            if(this._pathRotate)
            {
               this.angularVelocity = 0;
               this.angularAcceleration = 0;
               this.angle = this.pathAngle;
            }
         }
      }
      
      public function overlaps(ObjectOrGroup:FlxBasic, InScreenSpace:Boolean = false, Camera:FlxCamera = null) : Boolean
      {
         var results:Boolean = false;
         var i:uint = 0;
         var members:Array = null;
         if(ObjectOrGroup is FlxGroup)
         {
            results = false;
            i = 0;
            members = (ObjectOrGroup as FlxGroup).members;
            while(i < length)
            {
               if(this.overlaps(members[i++],InScreenSpace,Camera))
               {
                  results = true;
               }
            }
            return results;
         }
         if(ObjectOrGroup is FlxTilemap)
         {
            return (ObjectOrGroup as FlxTilemap).overlaps(this,InScreenSpace,Camera);
         }
         var object:FlxObject = ObjectOrGroup as FlxObject;
         if(!InScreenSpace)
         {
            return object.x + object.width > this.x && object.x < this.x + this.width && object.y + object.height > this.y && object.y < this.y + this.height;
         }
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         var objectScreenPos:FlxPoint = object.getScreenXY(null,Camera);
         this.getScreenXY(this._point,Camera);
         return objectScreenPos.x + object.width > this._point.x && objectScreenPos.x < this._point.x + this.width && objectScreenPos.y + object.height > this._point.y && objectScreenPos.y < this._point.y + this.height;
      }
      
      public function overlapsAt(X:Number, Y:Number, ObjectOrGroup:FlxBasic, InScreenSpace:Boolean = false, Camera:FlxCamera = null) : Boolean
      {
         var results:Boolean = false;
         var basic:FlxBasic = null;
         var i:uint = 0;
         var members:Array = null;
         var tilemap:FlxTilemap = null;
         if(ObjectOrGroup is FlxGroup)
         {
            results = false;
            i = 0;
            members = (ObjectOrGroup as FlxGroup).members;
            while(i < length)
            {
               if(this.overlapsAt(X,Y,members[i++],InScreenSpace,Camera))
               {
                  results = true;
               }
            }
            return results;
         }
         if(ObjectOrGroup is FlxTilemap)
         {
            tilemap = ObjectOrGroup as FlxTilemap;
            return tilemap.overlapsAt(tilemap.x - (X - this.x),tilemap.y - (Y - this.y),this,InScreenSpace,Camera);
         }
         var object:FlxObject = ObjectOrGroup as FlxObject;
         if(!InScreenSpace)
         {
            return object.x + object.width > X && object.x < X + this.width && object.y + object.height > Y && object.y < Y + this.height;
         }
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         var objectScreenPos:FlxPoint = object.getScreenXY(null,Camera);
         this._point.x = X - int(Camera.scroll.x * this.scrollFactor.x);
         this._point.y = Y - int(Camera.scroll.y * this.scrollFactor.y);
         this._point.x += this._point.x > 0 ? 1e-7 : -1e-7;
         this._point.y += this._point.y > 0 ? 1e-7 : -1e-7;
         return objectScreenPos.x + object.width > this._point.x && objectScreenPos.x < this._point.x + this.width && objectScreenPos.y + object.height > this._point.y && objectScreenPos.y < this._point.y + this.height;
      }
      
      public function overlapsPoint(Point:FlxPoint, InScreenSpace:Boolean = false, Camera:FlxCamera = null) : Boolean
      {
         if(!InScreenSpace)
         {
            return Point.x > this.x && Point.x < this.x + this.width && Point.y > this.y && Point.y < this.y + this.height;
         }
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         var X:Number = Point.x - Camera.scroll.x;
         var Y:Number = Point.y - Camera.scroll.y;
         this.getScreenXY(this._point,Camera);
         return X > this._point.x && X < this._point.x + this.width && Y > this._point.y && Y < this._point.y + this.height;
      }
      
      public function onScreen(Camera:FlxCamera = null) : Boolean
      {
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         this.getScreenXY(this._point,Camera);
         return this._point.x + this.width > 0 && this._point.x < Camera.width && this._point.y + this.height > 0 && this._point.y < Camera.height;
      }
      
      public function getScreenXY(Point:FlxPoint = null, Camera:FlxCamera = null) : FlxPoint
      {
         if(Point == null)
         {
            Point = new FlxPoint();
         }
         if(Camera == null)
         {
            Camera = FlxG.camera;
         }
         Point.x = this.x - int(Camera.scroll.x * this.scrollFactor.x);
         Point.y = this.y - int(Camera.scroll.y * this.scrollFactor.y);
         Point.x += Point.x > 0 ? 1e-7 : -1e-7;
         Point.y += Point.y > 0 ? 1e-7 : -1e-7;
         return Point;
      }
      
      public function flicker(Duration:Number = 1) : void
      {
         this._flickerTimer = Duration;
         if(this._flickerTimer == 0)
         {
            this._flicker = false;
         }
      }
      
      public function get flickering() : Boolean
      {
         return this._flickerTimer != 0;
      }
      
      public function get solid() : Boolean
      {
         return (this.allowCollisions & ANY) > NONE;
      }
      
      public function set solid(Solid:Boolean) : void
      {
         if(Solid)
         {
            this.allowCollisions = ANY;
         }
         else
         {
            this.allowCollisions = NONE;
         }
      }
      
      public function getMidpoint(Point:FlxPoint = null) : FlxPoint
      {
         if(Point == null)
         {
            Point = new FlxPoint();
         }
         Point.x = this.x + this.width * 0.5;
         Point.y = this.y + this.height * 0.5;
         return Point;
      }
      
      public function reset(X:Number, Y:Number) : void
      {
         revive();
         this.touching = NONE;
         this.wasTouching = NONE;
         this.x = X;
         this.y = Y;
         this.last.x = this.x;
         this.last.y = this.y;
         this.velocity.x = 0;
         this.velocity.y = 0;
      }
      
      public function isTouching(Direction:uint) : Boolean
      {
         return (this.touching & Direction) > NONE;
      }
      
      public function justTouched(Direction:uint) : Boolean
      {
         return (this.touching & Direction) > NONE && (this.wasTouching & Direction) <= NONE;
      }
      
      public function hurt(Damage:Number) : void
      {
         this.health -= Damage;
         if(this.health <= 0)
         {
            kill();
         }
      }
   }
}

