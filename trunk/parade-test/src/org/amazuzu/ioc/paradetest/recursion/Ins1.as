package org.amazuzu.ioc.paradetest.recursion
{
	public class Ins1
	{
		public function Ins1(ins2:Ins2)
		{
			trace("ins1 created");
		}

	}
}