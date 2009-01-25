package org.amazuzu.ioc.paradetest
{
	public class AnnoFoo
	{
		
		[Inject("groo")]
		public var foobarbaz:Groo;
		
		[Inject]
		public var bar:Bar;
		
		private var _foo:Foo;
		
		[Inject]
		public function set foo(_foo:Foo):void{
			this._foo = _foo;
		}
		
		public function get foo():Foo{
			return _foo;
		}
		
		
		public function AnnoFoo()
		{
		}

	}
}