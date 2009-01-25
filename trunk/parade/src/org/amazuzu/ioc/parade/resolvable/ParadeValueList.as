package org.amazuzu.ioc.parade.resolvable
{
	import org.amazuzu.ioc.parade.IInternalBeanFactory;
	import org.amazuzu.ioc.parade.error.IOCError;
	
	public class ParadeValueList implements IResolvable
	{
		private var beanFactory:IInternalBeanFactory = null;
	
		private var values:Array /* of PropertyMeta */;
		
		private var _propertiesResolved:Boolean;
		
		private var _value:Object = null;
		
		private var associative:Boolean;
		
		public function ParadeValueList(beanFactory:IInternalBeanFactory, listXml:XMLList, associative:Boolean)
		{
			this.beanFactory = beanFactory;
			
			this.associative = associative;
			
			values = [];
			
			_propertiesResolved = true;
			for each(var property:XML in listXml){
				if(property.localName() == "constructor"){
					continue;
				}
				//property should contain name
				var propName:String = property.@name.toXMLString();
				if(associative){
					var resolvable:IResolvable =  beanFactory.resolvablesFactory.createResolvable(property);
					if(resolvable is BeanReference && (resolvable as BeanReference).reference != null){
						propName = (resolvable as BeanReference).reference;
					}
					values[propName] = resolvable; 
				}else {
					var resolvable:IResolvable = beanFactory.resolvablesFactory.createResolvable(property); 
					values.push(resolvable);
				}
			}
			
	
		}
		
		public function resolve():void{
			for each(var property:IResolvable in values){
				if(!property.resolved()){
					property.resolve();
				}
			}	
		}
		
		public function resolved():Boolean{
			for each(var property:IResolvable in values){
				if(!property.resolved()){
					return false;
				}
			}	
			return true;
		}
		
		public function get value():Object{
			if(_value == null){
				if(associative){
					var argso:Object = {};
					for (var argName:String in values){
						argso[argName] = (values[argName] as IResolvable).value;
					}	
					_value = argso;
				}else{
					var argsa:Array = [];
					for each(var resolvedArg:IResolvable in values){
						argsa.push(resolvedArg.value);
					}
					_value = argsa;	
				}
				
				
			}
			return _value;
			
		}
		
		public function initializeProperties():void{
			for each(var property:IResolvable in values){
				if(!property.resolved()){
					property.resolve();
				}
				if(!property.resolved()){
					throw new IOCError("value {0} couldnt be resolved.", property);
				}
				property.initializeProperties();
			}	
		}
	}
}