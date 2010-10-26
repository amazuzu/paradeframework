package org.amazuzu.ioc.paradetest
{
	public class ConstructList
	{
		private var list:Array;
		
		public function ConstructList(list:Array)
		{
			this.list = list;
		}
		
		public function getList():Array{
			return list;
		}
	}
}