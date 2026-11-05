package org.flixel.system
{
   import org.flixel.FlxBasic;
   import org.flixel.FlxGroup;
   import org.flixel.FlxObject;
   import org.flixel.FlxRect;
   
   public class FlxQuadTree extends FlxRect
   {
      
      public static var divisions:uint;
      
      protected static var _min:uint;
      
      protected static var _object:FlxObject;
      
      protected static var _objectLeftEdge:Number;
      
      protected static var _objectTopEdge:Number;
      
      protected static var _objectRightEdge:Number;
      
      protected static var _objectBottomEdge:Number;
      
      protected static var _list:uint;
      
      protected static var _useBothLists:Boolean;
      
      protected static var _processingCallback:Function;
      
      protected static var _notifyCallback:Function;
      
      protected static var _iterator:FlxList;
      
      protected static var _objectHullX:Number;
      
      protected static var _objectHullY:Number;
      
      protected static var _objectHullWidth:Number;
      
      protected static var _objectHullHeight:Number;
      
      protected static var _checkObjectHullX:Number;
      
      protected static var _checkObjectHullY:Number;
      
      protected static var _checkObjectHullWidth:Number;
      
      protected static var _checkObjectHullHeight:Number;
      
      public static const A_LIST:uint = 0;
      
      public static const B_LIST:uint = 1;
      
      protected var _canSubdivide:Boolean;
      
      protected var _headA:FlxList;
      
      protected var _tailA:FlxList;
      
      protected var _headB:FlxList;
      
      protected var _tailB:FlxList;
      
      protected var _northWestTree:FlxQuadTree;
      
      protected var _northEastTree:FlxQuadTree;
      
      protected var _southEastTree:FlxQuadTree;
      
      protected var _southWestTree:FlxQuadTree;
      
      protected var _leftEdge:Number;
      
      protected var _rightEdge:Number;
      
      protected var _topEdge:Number;
      
      protected var _bottomEdge:Number;
      
      protected var _halfWidth:Number;
      
      protected var _halfHeight:Number;
      
      protected var _midpointX:Number;
      
      protected var _midpointY:Number;
      
      public function FlxQuadTree(X:Number, Y:Number, Width:Number, Height:Number, Parent:FlxQuadTree = null)
      {
         var iterator:FlxList = null;
         var ot:FlxList = null;
         super(X,Y,Width,Height);
         this._headA = this._tailA = new FlxList();
         this._headB = this._tailB = new FlxList();
         if(Parent != null)
         {
            if(Parent._headA.object != null)
            {
               iterator = Parent._headA;
               while(iterator != null)
               {
                  if(this._tailA.object != null)
                  {
                     ot = this._tailA;
                     this._tailA = new FlxList();
                     ot.next = this._tailA;
                  }
                  this._tailA.object = iterator.object;
                  iterator = iterator.next;
               }
            }
            if(Parent._headB.object != null)
            {
               iterator = Parent._headB;
               while(iterator != null)
               {
                  if(this._tailB.object != null)
                  {
                     ot = this._tailB;
                     this._tailB = new FlxList();
                     ot.next = this._tailB;
                  }
                  this._tailB.object = iterator.object;
                  iterator = iterator.next;
               }
            }
         }
         else
         {
            _min = (width + height) / (2 * divisions);
         }
         this._canSubdivide = width > _min || height > _min;
         this._northWestTree = null;
         this._northEastTree = null;
         this._southEastTree = null;
         this._southWestTree = null;
         this._leftEdge = x;
         this._rightEdge = x + width;
         this._halfWidth = width / 2;
         this._midpointX = this._leftEdge + this._halfWidth;
         this._topEdge = y;
         this._bottomEdge = y + height;
         this._halfHeight = height / 2;
         this._midpointY = this._topEdge + this._halfHeight;
      }
      
      public function destroy() : void
      {
         this._headA.destroy();
         this._headA = null;
         this._tailA.destroy();
         this._tailA = null;
         this._headB.destroy();
         this._headB = null;
         this._tailB.destroy();
         this._tailB = null;
         if(this._northWestTree != null)
         {
            this._northWestTree.destroy();
         }
         this._northWestTree = null;
         if(this._northEastTree != null)
         {
            this._northEastTree.destroy();
         }
         this._northEastTree = null;
         if(this._southEastTree != null)
         {
            this._southEastTree.destroy();
         }
         this._southEastTree = null;
         if(this._southWestTree != null)
         {
            this._southWestTree.destroy();
         }
         this._southWestTree = null;
         _object = null;
         _processingCallback = null;
         _notifyCallback = null;
      }
      
      public function load(ObjectOrGroup1:FlxBasic, ObjectOrGroup2:FlxBasic = null, NotifyCallback:Function = null, ProcessCallback:Function = null) : void
      {
         this.add(ObjectOrGroup1,A_LIST);
         if(ObjectOrGroup2 != null)
         {
            this.add(ObjectOrGroup2,B_LIST);
            _useBothLists = true;
         }
         else
         {
            _useBothLists = false;
         }
         _notifyCallback = NotifyCallback;
         _processingCallback = ProcessCallback;
      }
      
      public function add(ObjectOrGroup:FlxBasic, List:uint) : void
      {
         var i:uint = 0;
         var basic:FlxBasic = null;
         var members:Array = null;
         var l:uint = 0;
         _list = List;
         if(ObjectOrGroup is FlxGroup)
         {
            i = 0;
            members = (ObjectOrGroup as FlxGroup).members;
            l = (ObjectOrGroup as FlxGroup).length;
            while(i < l)
            {
               basic = members[i++] as FlxBasic;
               if(basic != null && basic.exists)
               {
                  if(basic is FlxGroup)
                  {
                     this.add(basic,List);
                  }
                  else if(basic is FlxObject)
                  {
                     _object = basic as FlxObject;
                     if(_object.exists && Boolean(_object.allowCollisions))
                     {
                        _objectLeftEdge = _object.x;
                        _objectTopEdge = _object.y;
                        _objectRightEdge = _object.x + _object.width;
                        _objectBottomEdge = _object.y + _object.height;
                        this.addObject();
                     }
                  }
               }
            }
         }
         else
         {
            _object = ObjectOrGroup as FlxObject;
            if(_object.exists && Boolean(_object.allowCollisions))
            {
               _objectLeftEdge = _object.x;
               _objectTopEdge = _object.y;
               _objectRightEdge = _object.x + _object.width;
               _objectBottomEdge = _object.y + _object.height;
               this.addObject();
            }
         }
      }
      
      protected function addObject() : void
      {
         if(!this._canSubdivide || this._leftEdge >= _objectLeftEdge && this._rightEdge <= _objectRightEdge && this._topEdge >= _objectTopEdge && this._bottomEdge <= _objectBottomEdge)
         {
            this.addToList();
            return;
         }
         if(_objectLeftEdge > this._leftEdge && _objectRightEdge < this._midpointX)
         {
            if(_objectTopEdge > this._topEdge && _objectBottomEdge < this._midpointY)
            {
               if(this._northWestTree == null)
               {
                  this._northWestTree = new FlxQuadTree(this._leftEdge,this._topEdge,this._halfWidth,this._halfHeight,this);
               }
               this._northWestTree.addObject();
               return;
            }
            if(_objectTopEdge > this._midpointY && _objectBottomEdge < this._bottomEdge)
            {
               if(this._southWestTree == null)
               {
                  this._southWestTree = new FlxQuadTree(this._leftEdge,this._midpointY,this._halfWidth,this._halfHeight,this);
               }
               this._southWestTree.addObject();
               return;
            }
         }
         if(_objectLeftEdge > this._midpointX && _objectRightEdge < this._rightEdge)
         {
            if(_objectTopEdge > this._topEdge && _objectBottomEdge < this._midpointY)
            {
               if(this._northEastTree == null)
               {
                  this._northEastTree = new FlxQuadTree(this._midpointX,this._topEdge,this._halfWidth,this._halfHeight,this);
               }
               this._northEastTree.addObject();
               return;
            }
            if(_objectTopEdge > this._midpointY && _objectBottomEdge < this._bottomEdge)
            {
               if(this._southEastTree == null)
               {
                  this._southEastTree = new FlxQuadTree(this._midpointX,this._midpointY,this._halfWidth,this._halfHeight,this);
               }
               this._southEastTree.addObject();
               return;
            }
         }
         if(_objectRightEdge > this._leftEdge && _objectLeftEdge < this._midpointX && _objectBottomEdge > this._topEdge && _objectTopEdge < this._midpointY)
         {
            if(this._northWestTree == null)
            {
               this._northWestTree = new FlxQuadTree(this._leftEdge,this._topEdge,this._halfWidth,this._halfHeight,this);
            }
            this._northWestTree.addObject();
         }
         if(_objectRightEdge > this._midpointX && _objectLeftEdge < this._rightEdge && _objectBottomEdge > this._topEdge && _objectTopEdge < this._midpointY)
         {
            if(this._northEastTree == null)
            {
               this._northEastTree = new FlxQuadTree(this._midpointX,this._topEdge,this._halfWidth,this._halfHeight,this);
            }
            this._northEastTree.addObject();
         }
         if(_objectRightEdge > this._midpointX && _objectLeftEdge < this._rightEdge && _objectBottomEdge > this._midpointY && _objectTopEdge < this._bottomEdge)
         {
            if(this._southEastTree == null)
            {
               this._southEastTree = new FlxQuadTree(this._midpointX,this._midpointY,this._halfWidth,this._halfHeight,this);
            }
            this._southEastTree.addObject();
         }
         if(_objectRightEdge > this._leftEdge && _objectLeftEdge < this._midpointX && _objectBottomEdge > this._midpointY && _objectTopEdge < this._bottomEdge)
         {
            if(this._southWestTree == null)
            {
               this._southWestTree = new FlxQuadTree(this._leftEdge,this._midpointY,this._halfWidth,this._halfHeight,this);
            }
            this._southWestTree.addObject();
         }
      }
      
      protected function addToList() : void
      {
         var ot:FlxList = null;
         if(_list == A_LIST)
         {
            if(this._tailA.object != null)
            {
               ot = this._tailA;
               this._tailA = new FlxList();
               ot.next = this._tailA;
            }
            this._tailA.object = _object;
         }
         else
         {
            if(this._tailB.object != null)
            {
               ot = this._tailB;
               this._tailB = new FlxList();
               ot.next = this._tailB;
            }
            this._tailB.object = _object;
         }
         if(!this._canSubdivide)
         {
            return;
         }
         if(this._northWestTree != null)
         {
            this._northWestTree.addToList();
         }
         if(this._northEastTree != null)
         {
            this._northEastTree.addToList();
         }
         if(this._southEastTree != null)
         {
            this._southEastTree.addToList();
         }
         if(this._southWestTree != null)
         {
            this._southWestTree.addToList();
         }
      }
      
      public function execute() : Boolean
      {
         var iterator:FlxList = null;
         var overlapProcessed:Boolean = false;
         if(this._headA.object != null)
         {
            iterator = this._headA;
            while(iterator != null)
            {
               _object = iterator.object;
               if(_useBothLists)
               {
                  _iterator = this._headB;
               }
               else
               {
                  _iterator = iterator.next;
               }
               if(_object.exists && _object.allowCollisions > 0 && _iterator != null && _iterator.object != null && _iterator.object.exists && this.overlapNode())
               {
                  overlapProcessed = true;
               }
               iterator = iterator.next;
            }
         }
         if(this._northWestTree != null && this._northWestTree.execute())
         {
            overlapProcessed = true;
         }
         if(this._northEastTree != null && this._northEastTree.execute())
         {
            overlapProcessed = true;
         }
         if(this._southEastTree != null && this._southEastTree.execute())
         {
            overlapProcessed = true;
         }
         if(this._southWestTree != null && this._southWestTree.execute())
         {
            overlapProcessed = true;
         }
         return overlapProcessed;
      }
      
      protected function overlapNode() : Boolean
      {
         var checkObject:FlxObject = null;
         var overlapProcessed:Boolean = false;
         while(_iterator != null)
         {
            if(!_object.exists || _object.allowCollisions <= 0)
            {
               break;
            }
            checkObject = _iterator.object;
            if(_object === checkObject || !checkObject.exists || checkObject.allowCollisions <= 0)
            {
               _iterator = _iterator.next;
            }
            else
            {
               _objectHullX = _object.x < _object.last.x ? _object.x : _object.last.x;
               _objectHullY = _object.y < _object.last.y ? _object.y : _object.last.y;
               _objectHullWidth = _object.x - _object.last.x;
               _objectHullWidth = _object.width + (_objectHullWidth > 0 ? _objectHullWidth : -_objectHullWidth);
               _objectHullHeight = _object.y - _object.last.y;
               _objectHullHeight = _object.height + (_objectHullHeight > 0 ? _objectHullHeight : -_objectHullHeight);
               _checkObjectHullX = checkObject.x < checkObject.last.x ? checkObject.x : checkObject.last.x;
               _checkObjectHullY = checkObject.y < checkObject.last.y ? checkObject.y : checkObject.last.y;
               _checkObjectHullWidth = checkObject.x - checkObject.last.x;
               _checkObjectHullWidth = checkObject.width + (_checkObjectHullWidth > 0 ? _checkObjectHullWidth : -_checkObjectHullWidth);
               _checkObjectHullHeight = checkObject.y - checkObject.last.y;
               _checkObjectHullHeight = checkObject.height + (_checkObjectHullHeight > 0 ? _checkObjectHullHeight : -_checkObjectHullHeight);
               if(_objectHullX + _objectHullWidth > _checkObjectHullX && _objectHullX < _checkObjectHullX + _checkObjectHullWidth && _objectHullY + _objectHullHeight > _checkObjectHullY && _objectHullY < _checkObjectHullY + _checkObjectHullHeight)
               {
                  if(_processingCallback == null || Boolean(_processingCallback(_object,checkObject)))
                  {
                     overlapProcessed = true;
                  }
                  if(overlapProcessed && _notifyCallback != null)
                  {
                     _notifyCallback(_object,checkObject);
                  }
               }
               _iterator = _iterator.next;
            }
         }
         return overlapProcessed;
      }
   }
}

