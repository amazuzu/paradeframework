package org.amazuzu.ioc.paradetest.mixtestcase
{
	import org.amazuzu.ioc.parade.error.IOCInternalError;
	
	public class D
	{
		private static var count:int = 0;
		
		public function D(a:A, b:B, c:C)
		{
				if(count!=0){
				throw new IOCInternalError();
			}
			count++;
		}

	}
}