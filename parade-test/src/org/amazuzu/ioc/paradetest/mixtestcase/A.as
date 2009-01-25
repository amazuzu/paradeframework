package org.amazuzu.ioc.paradetest.mixtestcase
{
	import org.amazuzu.ioc.parade.error.IOCInternalError;
	
	
	public class A
	{
		private static var count:int = 0;
		
		public function A()
		{
			if(count !=0 ){
				throw new IOCInternalError();
			}
			count++;
		}

	}
}