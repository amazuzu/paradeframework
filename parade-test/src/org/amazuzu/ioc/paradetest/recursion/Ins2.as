package org.amazuzu.ioc.paradetest.recursion
{
	public class Ins2
	{
		public function Ins2(ins3:Ins3)
		{
			trace("ins2 created");
		}

	}
}