package org.amazuzu.ioc.paradetest
{
	import mx.utils.StringUtil;

	public class Baz
	{
		
		public var parade:String = null;
		
		public function Baz()
		{
		}

		public function toString():String{
			return StringUtil.substitute("baz()[{0}]", parade);
		}
	}
}