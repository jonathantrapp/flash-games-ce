package xplor
{
   import org.flixel.FlxG;
   import org.flixel.FlxGroup;
   import org.flixel.FlxText;
   
   public class Notice extends FlxGroup
   {
      
      public static const MAX_NOTICE:uint = 20;
      
      public var lastNotice:FlxText;
      
      public function Notice()
      {
         var _loc1_:FlxText = null;
         super();
         var _loc2_:int = 0;
         while(_loc2_ < MAX_NOTICE)
         {
            _loc1_ = new FlxText(0,0,320,"");
            _loc1_.setFormat("volks",8,16777215,"center",1);
            _loc1_.visible = false;
            add(_loc1_);
            _loc2_++;
         }
         this.lastNotice = null;
      }
      
      public function NoRepeatSay(param1:String, param2:int, param3:Number, param4:Number) : void
      {
         if(this.lastNotice == null || this.lastNotice.text != param1 || this.lastNotice.visible == false)
         {
            this.Say(param1,param2,param3,param4);
         }
      }
      
      public function Say(param1:String, param2:int, param3:Number, param4:Number) : void
      {
         var _loc5_:FlxText = null;
         var _loc6_:FlxText = null;
         for each(_loc5_ in members)
         {
            if(_loc5_.visible == false)
            {
               _loc5_.color = param2;
               _loc5_.x = param3 - 160;
               _loc5_.y = param4;
               _loc5_.text = param1;
               _loc5_.visible = true;
               _loc5_.alpha = 1;
               this.lastNotice = _loc5_;
               return;
            }
            if(_loc6_ == null || _loc5_.alpha < _loc6_.alpha)
            {
               _loc6_ = _loc5_;
            }
         }
         _loc6_.color = param2;
         _loc6_.x = param3 - 160;
         _loc6_.y = param4;
         _loc6_.text = param1;
         _loc6_.visible = true;
         _loc6_.alpha = 1;
         this.lastNotice = _loc6_;
      }
      
      override public function update() : void
      {
         var _loc1_:FlxText = null;
         for each(_loc1_ in members)
         {
            if(_loc1_.visible)
            {
               _loc1_.y -= FlxG.elapsed * 30;
               _loc1_.alpha -= FlxG.elapsed / 3;
               if(_loc1_.alpha <= 0 || _loc1_.y < -20)
               {
                  _loc1_.visible = false;
               }
            }
         }
      }
   }
}

