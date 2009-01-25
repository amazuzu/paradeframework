package org.amazuzu.ioc.paradetest.mixtestcase
{
	import org.amazuzu.ioc.parade.error.IOCInternalError;
	
	public class C
	{
		private static var count:int = 0;
		
		
		public function C(a:A, b:B)
		{
				if(count!=0){
				throw new IOCInternalError();
			}
			count++;
		}

	}
}