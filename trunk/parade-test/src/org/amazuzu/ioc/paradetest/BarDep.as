package org.amazuzu.ioc.paradetest
{
	public class BarDep
	{
		
		private var _bar:Bar;
		
		public function BarDep()
		{
		}
		
		[Inject]
		public function set bar(_bar:Bar):void{
			this._bar = _bar;
		}
		
		public function get bar():Bar{
			return _bar;
		}

	}
}