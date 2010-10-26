package org.amazuzu.ioc.paradetest
{
	public class ConstructMap
	{
		private var map:Object;
		
		public function ConstructMap(map:Object)
		{
			this.map = map;
		}
		
			
		public function getMap():Object{
			return map;
		}
	}
}