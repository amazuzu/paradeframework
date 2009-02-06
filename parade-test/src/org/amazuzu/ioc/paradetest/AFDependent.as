package org.amazuzu.ioc.paradetest
{
	public class AFDependent
	{
		public var af:AnnoFoo = null;
		
		public function AFDependent(annoFoo:AnnoFoo)
		{
			this.af = annoFoo;
		}

	}
}