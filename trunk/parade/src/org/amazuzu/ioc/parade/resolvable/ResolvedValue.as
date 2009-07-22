package org.amazuzu.ioc.parade.resolvable
{
	import org.amazuzu.ioc.parade.error.IOCInternalError;
	
	
	public class ResolvedValue implements IResolvable
	{
		private var _value:Object = null;
		
		public function ResolvedValue(_value:Object)
		{
			this._value = _value;
			if(_value is String && _value=="false"){
				this._value = false;
			}
		}

		public function resolved():Boolean
		{
			return true;
		}
		
		public function resolve():void
		{
			//already resolved
			throw new IOCInternalError();
		}
		
		public function get value():Object
		{
			return _value;
		}
		
		public function initializeProperties():void{
			
		}
		
	}
}