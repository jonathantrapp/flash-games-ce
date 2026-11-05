package org.flixel.system.debug
{
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import org.flixel.FlxU;
   
   public class WatchEntry
   {
      
      public var object:Object;
      
      public var field:String;
      
      public var custom:String;
      
      public var nameDisplay:TextField;
      
      public var valueDisplay:TextField;
      
      public var editing:Boolean;
      
      public var oldValue:Object;
      
      protected var _whiteText:TextFormat;
      
      protected var _blackText:TextFormat;
      
      public function WatchEntry(Y:Number, NameWidth:Number, ValueWidth:Number, Obj:Object, Field:String, Custom:String = null)
      {
         super();
         this.editing = false;
         this.object = Obj;
         this.field = Field;
         this.custom = Custom;
         this._whiteText = new TextFormat("Courier",12,16777215);
         this._blackText = new TextFormat("Courier",12,0);
         this.nameDisplay = new TextField();
         this.nameDisplay.y = Y;
         this.nameDisplay.multiline = false;
         this.nameDisplay.selectable = true;
         this.nameDisplay.defaultTextFormat = this._whiteText;
         this.valueDisplay = new TextField();
         this.valueDisplay.y = Y;
         this.valueDisplay.height = 15;
         this.valueDisplay.multiline = false;
         this.valueDisplay.selectable = true;
         this.valueDisplay.doubleClickEnabled = true;
         this.valueDisplay.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         this.valueDisplay.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this.valueDisplay.background = false;
         this.valueDisplay.backgroundColor = 16777215;
         this.valueDisplay.defaultTextFormat = this._whiteText;
         this.updateWidth(NameWidth,ValueWidth);
      }
      
      public function destroy() : void
      {
         this.object = null;
         this.oldValue = null;
         this.nameDisplay = null;
         this.field = null;
         this.custom = null;
         this.valueDisplay.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this.valueDisplay.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         this.valueDisplay = null;
      }
      
      public function setY(Y:Number) : void
      {
         this.nameDisplay.y = Y;
         this.valueDisplay.y = Y;
      }
      
      public function updateWidth(NameWidth:Number, ValueWidth:Number) : void
      {
         this.nameDisplay.width = NameWidth;
         this.valueDisplay.width = ValueWidth;
         if(this.custom != null)
         {
            this.nameDisplay.text = this.custom;
         }
         else
         {
            this.nameDisplay.text = "";
            if(NameWidth > 120)
            {
               this.nameDisplay.appendText(FlxU.getClassName(this.object,NameWidth < 240) + ".");
            }
            this.nameDisplay.appendText(this.field);
         }
      }
      
      public function updateValue() : Boolean
      {
         if(this.editing)
         {
            return false;
         }
         this.valueDisplay.text = this.object[this.field].toString();
         return true;
      }
      
      public function onMouseUp(FlashEvent:MouseEvent) : void
      {
         this.editing = true;
         this.oldValue = this.object[this.field];
         this.valueDisplay.type = TextFieldType.INPUT;
         this.valueDisplay.setTextFormat(this._blackText);
         this.valueDisplay.background = true;
      }
      
      public function onKeyUp(FlashEvent:KeyboardEvent) : void
      {
         if(FlashEvent.keyCode == 13 || FlashEvent.keyCode == 9 || FlashEvent.keyCode == 27)
         {
            if(FlashEvent.keyCode == 27)
            {
               this.cancel();
            }
            else
            {
               this.submit();
            }
         }
      }
      
      public function cancel() : void
      {
         this.valueDisplay.text = this.oldValue.toString();
         this.doneEditing();
      }
      
      public function submit() : void
      {
         this.object[this.field] = this.valueDisplay.text;
         this.doneEditing();
      }
      
      protected function doneEditing() : void
      {
         this.valueDisplay.type = TextFieldType.DYNAMIC;
         this.valueDisplay.setTextFormat(this._whiteText);
         this.valueDisplay.defaultTextFormat = this._whiteText;
         this.valueDisplay.background = false;
         this.editing = false;
      }
   }
}

