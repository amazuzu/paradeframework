package org.amazuzu.ioc.parade
{
	import org.amazuzu.ioc.parade.resolvable.ParadeBean;
	
	public interface IInternalBeanFactory
	{
		function notifyResolution():void;
		
		function notifyHasUnresolved():void;
		
		function get resolvablesFactory():ResolvablesFactory;		
		
		function getParadeBean(beanName:String):ParadeBean;
		
		function getBean(beanName:String):Object;
		
		function containsParadeBean(beanName:String):Boolean;
		
		function containsPredefinedBean(beanName:String):Boolean;
	}
}