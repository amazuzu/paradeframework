package org.amazuzu.ioc.paradetest
{
	import mx.utils.StringUtil;
	
	public class Groo
	{
		public var singleCheck:Number;
		
		public function Groo()
		{
			singleCheck = Math.random();
		}
		
		public var bar:Bar;
		
		public var theMap:Object;
		
		public function toString():String{
			return StringUtil.substitute("groo()[{0}]", bar);
		}
		
		public var list:Array;

	}
}