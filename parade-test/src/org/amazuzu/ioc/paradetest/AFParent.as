package org.amazuzu.ioc.paradetest
{
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class AFParent extends AnnoFoo
	{
		private static var log:ILogger = Log.getLogger("AFParent");
		
		public function AFParent()
		{
			
		}
		
		[ParadeInitialize]
		override public function initialize():void{
			super.initialize();
			log.debug("AFParent initialize");
		}
	}
}