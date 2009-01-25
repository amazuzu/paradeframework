package org.amazuzu.ioc.paradetest
{
	import flexunit.framework.TestSuite;
	
	public class ParadeTestSuite extends TestSuite
	{
		
		public function ParadeTestSuite()
		{
			
			addTestSuite(SomeTest);
		}

	}
}