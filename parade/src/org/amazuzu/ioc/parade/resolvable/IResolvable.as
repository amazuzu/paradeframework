package org.amazuzu.ioc.parade.resolvable
{
	public interface IResolvable
	{
		function resolved():Boolean;
		
		function resolve():void;
		
		function get value():Object;
		
		function initializeProperties():void;
	}
}