package org.amazuzu.ioc.parade.resolvable
{
	import org.amazuzu.ioc.parade.BeanFactory;
	import org.amazuzu.ioc.parade.parade_ns;
	
	public class BeanReference implements IResolvable
	{
		private var beanFactory:BeanFactory = null;
		private var _reference:String;
		private var named:Boolean;
		
		public function BeanReference(beanFactory:BeanFactory, reference:String, named:Boolean)
		{
			this.beanFactory = beanFactory;
			this._reference = reference;
			this.named = named;
		}

		public function resolved():Boolean
		{
			var obj:Object = beanFactory.parade_ns::getParadeBean(_reference);
			if(obj is ParadeBean){
				return (obj as ParadeBean).resolved();
			}else{
				return true;
			}
		}
		
		public function resolve():void
		{
		}
		
		public function get value():Object
		{
			return beanFactory.getBean(_reference);
		}
		
		public function get reference():String{
			if(named){
				return null;
			}else{
				return _reference;
			}
		}
		
		public function initializeProperties():void{
			
		}
		
	}
}