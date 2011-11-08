package org.amazuzu.ioc.paradetest
{
	public class PrimitiveHolder
	{
		public var pInt:int;
		
		public var pNumber:Number;
		
		public var pString:String;
		
		public var pUint:uint;
		
		public var pTrue:Boolean;
		
		public var pFalse:Boolean;
		
		public var pStringFalse:String;
		
		public var list:Array;
		
		public var numVector:Vector.<Number>;
		
		public function PrimitiveHolder(foo:int)
		{
			trace(""+foo+" "+(foo as int));
		}

	}
}