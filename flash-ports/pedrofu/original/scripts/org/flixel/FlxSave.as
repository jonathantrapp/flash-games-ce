package org.flixel
{
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   import flash.net.SharedObjectFlushStatus;
   
   public class FlxSave
   {
      
      protected static var SUCCESS:uint = 0;
      
      protected static var PENDING:uint = 1;
      
      protected static var ERROR:uint = 2;
      
      public var data:Object;
      
      public var name:String;
      
      protected var _sharedObject:SharedObject;
      
      protected var _onComplete:Function;
      
      protected var _closeRequested:Boolean;
      
      public function FlxSave()
      {
         super();
         this.destroy();
      }
      
      public function destroy() : void
      {
         this._sharedObject = null;
         this.name = null;
         this.data = null;
         this._onComplete = null;
         this._closeRequested = false;
      }
      
      public function bind(Name:String) : Boolean
      {
         this.destroy();
         this.name = Name;
         try
         {
            this._sharedObject = SharedObject.getLocal(this.name);
         }
         catch(e:Error)
         {
            FlxG.log("ERROR: There was a problem binding to\nthe shared object data from FlxSave.");
            destroy();
            return false;
         }
         this.data = this._sharedObject.data;
         return true;
      }
      
      public function close(MinFileSize:uint = 0, OnComplete:Function = null) : Boolean
      {
         this._closeRequested = true;
         return this.flush(MinFileSize,OnComplete);
      }
      
      public function flush(MinFileSize:uint = 0, OnComplete:Function = null) : Boolean
      {
         var result:String;
         if(!this.checkBinding())
         {
            return false;
         }
         this._onComplete = OnComplete;
         result = null;
         try
         {
            result = this._sharedObject.flush(MinFileSize);
         }
         catch(e:Error)
         {
            return onDone(ERROR);
         }
         if(result == SharedObjectFlushStatus.PENDING)
         {
            this._sharedObject.addEventListener(NetStatusEvent.NET_STATUS,this.onFlushStatus);
         }
         return this.onDone(result == SharedObjectFlushStatus.FLUSHED ? SUCCESS : PENDING);
      }
      
      public function erase() : Boolean
      {
         if(!this.checkBinding())
         {
            return false;
         }
         this._sharedObject.clear();
         return true;
      }
      
      protected function onFlushStatus(E:NetStatusEvent) : void
      {
         this._sharedObject.removeEventListener(NetStatusEvent.NET_STATUS,this.onFlushStatus);
         this.onDone(E.info.code == "SharedObject.Flush.Success" ? SUCCESS : ERROR);
      }
      
      protected function onDone(Result:uint) : Boolean
      {
         switch(Result)
         {
            case PENDING:
               FlxG.log("FLIXEL: FlxSave is requesting extra storage space.");
               break;
            case ERROR:
               FlxG.log("ERROR: There was a problem flushing\nthe shared object data from FlxSave.");
         }
         if(this._onComplete != null)
         {
            this._onComplete(Result == SUCCESS);
         }
         if(this._closeRequested)
         {
            this.destroy();
         }
         return Result == SUCCESS;
      }
      
      protected function checkBinding() : Boolean
      {
         if(this._sharedObject == null)
         {
            FlxG.log("FLIXEL: You must call FlxSave.bind()\nbefore you can read or write data.");
            return false;
         }
         return true;
      }
   }
}

