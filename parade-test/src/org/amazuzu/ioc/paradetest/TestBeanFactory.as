package org.amazuzu.ioc.paradetest
{
	import org.amazuzu.ioc.parade.BeanFactory;

	public class TestBeanFactory extends BeanFactory
	{
		private var contextResource:Class;
		
		public function TestBeanFactory(contextResource:Class)
		{
			super();
			Foo;
			Bar;
			Baz;
			Groo;
			BarSimilar;
			this.contextResource = contextResource;
		}
		
		override protected function getContextResourceClasses():Array /* of Class*/{
			return [contextResource];
		} 
	}
}