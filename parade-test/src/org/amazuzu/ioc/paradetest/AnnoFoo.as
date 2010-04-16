package org.amazuzu.ioc.paradetest
{
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class AnnoFoo
	{
		private static var log:ILogger = Log.getLogger("AnnoFoo");
		
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
		
		[ParadeInitialize]
		public function initialize():void{
			log.debug("YOYO");
		}


	}
}