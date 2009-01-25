package org.amazuzu.ioc.parade.error
{
	import mx.utils.StringUtil;
	
	public class IOCError extends Error
	{
		public function IOCError(message:String ,... args)
		{
			super(StringUtil.substitute(message, args));
		}
	 
		
	}
}