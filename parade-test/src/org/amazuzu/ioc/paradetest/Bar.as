package org.amazuzu.ioc.paradetest
{
	import mx.utils.StringUtil;
	
	public class Bar
	{
		public function Bar()
		{
		}
		public var groo:Groo;
		
		public function toString():String{
			return StringUtil.substitute("bar()[{0}]", groo);
		}
		
	}
}