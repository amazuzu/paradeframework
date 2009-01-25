package org.amazuzu.ioc.paradetest
{
	import mx.utils.StringUtil;
	
	
	public class Foo
	{
		public var bar:Bar;
		public var baz:Baz;
		
		public var someprop:Baz = null;
		
		public function Foo(bar:Bar, baz:Baz)
		{
			this.bar = bar;
			this.baz = baz;
		}

		public function toString():String{
			return StringUtil.substitute("foo({0},{1})[{2}]", bar, baz, someprop);
		}
	}
}