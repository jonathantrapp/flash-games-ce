package xplor
{
   import flash.utils.ByteArray;
   import flash.utils.getDefinitionByName;
   import xplor.Monster.*;
   
   public class LevelSet
   {
      
      public static var Level01:Class = LevelSet_Level01;
      
      public static var Level02:Class = LevelSet_Level02;
      
      public static var Level03:Class = LevelSet_Level03;
      
      public static var Level04:Class = LevelSet_Level04;
      
      public static var Level05:Class = LevelSet_Level05;
      
      public static var Level06:Class = LevelSet_Level06;
      
      public static var Level07:Class = LevelSet_Level07;
      
      public static var Level08:Class = LevelSet_Level08;
      
      public static var Level09:Class = LevelSet_Level09;
      
      public static var Level10:Class = LevelSet_Level10;
      
      public static var Level11:Class = LevelSet_Level11;
      
      public static var Level12:Class = LevelSet_Level12;
      
      public static var Level13:Class = LevelSet_Level13;
      
      public static var Level14:Class = LevelSet_Level14;
      
      public static var Level15:Class = LevelSet_Level15;
      
      public var levelList:Array = new Array(Level01,Level02,Level03,Level04,Level05,Level06,Level07,Level08,Level09,Level10,Level11,Level12,Level13,Level14,Level15);
      
      public var numLevels:int;
      
      public function LevelSet()
      {
         super();
         this.numLevels = this.levelList.length;
      }
      
      public function GetLevelData(n:int) : ByteArray
      {
         return new this.levelList[n]() as ByteArray;
      }
   }
}

