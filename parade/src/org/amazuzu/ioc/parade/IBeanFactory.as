package org.amazuzu.ioc.parade
{
	public interface IBeanFactory
	{
		function containsBean(beanName:String):Boolean;
		
		function getBean(beanName:String):Object;
		
		function loadContext():void;
		
		function passiveInit(object:Object):void;
	}
}