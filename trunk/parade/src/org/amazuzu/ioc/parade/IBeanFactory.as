package org.amazuzu.ioc.parade
{
	public interface IBeanFactory
	{
		function containsBean(beanName:String):Boolean;
		
		function getBean(beanName:String):Object;
	}
}