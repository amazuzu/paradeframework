package org.amazuzu.ioc.paradetest.mixtestcase
{
	import org.amazuzu.ioc.parade.error.IOCInternalError;
	
	public class B
	{
		private static var count:int = 0;
		
		public function B(a:A)
		{
				if(count!=0){
				throw new IOCInternalError();
			}
			count++;
		}

	}
}