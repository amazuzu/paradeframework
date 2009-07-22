package org.amazuzu.ioc.parade.resolvable
{
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import org.amazuzu.ioc.parade.IInternalBeanFactory;
	import org.amazuzu.ioc.parade.error.IOCInternalError;
	
	public class ParadeBean implements IResolvable
	{
		
		private var beanFactory:IInternalBeanFactory = null;
		
		private var constrList:IResolvable;
		
		private var propList:ParadeValueList;		
		
		private var _beanName:String = null;
		
		private var _class:Class = null;
			
		private var _singleton:Boolean;
		
		private var _value:Object = null;
		
		private var instantiated:Boolean = false;
		
		private var inherit:String = null;
		
		
		public function ParadeBean(beanFactory:IInternalBeanFactory, beanXml:XML)
		{
			this.beanFactory = beanFactory;
			
			_beanName = beanXml.@name.toXMLString();
			
			if(beanXml.attribute("class").toXMLString() != ""){
				_class = getDefinitionByName(beanXml.attribute("class").toXMLString()) as Class;
			}else{
			}
			
			if(beanXml.@singleton.toXMLString() == "false"){
				_singleton = false;
			}else{
				_singleton = true;
			}
			
			if(beanXml.attribute("inherit").toXMLString() != ""){
				inherit = beanXml.attribute("inherit").toXMLString();
			}else{
			}

			var annotations:Array /* of Objects {property:..., reference:...}*/ = [];

			collectAnnotatedReferences(annotations);

			constrList = new ParadeValueList(beanFactory, beanXml.constructor.children(), false);  
		
			propList = new ParadeValueList(beanFactory, beanXml.children(), true, annotations);
		
		
		}
		
		private function collectAnnotatedReferences(annotations:Array):void{
			
			var desc:XML = describeType(_class).factory[0];

			var variables:XMLList = desc.variable;
			var accessors:XMLList = desc.accessor;
			
			for each(var variable:XML in variables){
				metadataProcessor(annotations, variable);
			}
			
			for each(var accessor:XML in accessors){
				metadataProcessor(annotations, accessor);
			}
		}
	
		
		private function metadataProcessor(annotations:Array, decl:XML):void{
			for each(var meta:XML in decl.metadata){
				if(meta.@name.toXMLString() == "Inject"){
					var propertyName:String = decl.@name.toXMLString();
					var retrieveBean:String;
						
					if(meta.arg.toXMLString() != ""){
						retrieveBean = meta.arg.@value.toXMLString();
					}else{
						retrieveBean = propertyName;
					}
					annotations.push({property:propertyName, reference:retrieveBean});
				}		
			}			
		}
		
		
		public function resolved():Boolean{
			return constrList.resolved() && (_singleton && instantiated || !_singleton);
		}
		
		public function resolve():void{
			if(constrList.resolved()){
				if(_singleton && !instantiated){
					instantiate();
					beanFactory.notifyResolution();
				}
			}else{
				beanFactory.notifyHasUnresolved();
				constrList.resolve();
			}
		}
	
		private function instantiate():void{
			var a:Array = constrList.value as Array;
				
			switch(a.length){
				case 0:
					_value = new _class();
				break;
				case 1:
					_value = new _class(a[0]);
				break;
				case 2:
					_value = new _class(a[0], a[1]);
				break;
				case 3:
					_value = new _class(a[0], a[1], a[2]);
				break;
				case 4:
					_value = new _class(a[0], a[1], a[2], a[3]);
				break;
				case 5:
					_value = new _class(a[0], a[1], a[2], a[3], a[4]);
				break;
			}
			if(_singleton && instantiated){
				//could be instantiated twicely
				throw new IOCInternalError();
			}
	
			instantiated = true;
	
		} 
		
		
		public function initializeProperties():void{
			if(!instantiated){
			
				if(_singleton){
					//should be instantiated 
					throw new IOCInternalError();
				}else{
					instantiate();
					initializeProperties();
				}
			}
			
			constrList.initializeProperties();
		
			
			
			
			if(inherit != null){
				var father:ParadeBean = beanFactory.getParadeBean(inherit);
				father.propertiesList.performInheritance(propList);
				
			}
			
			propList.initializeProperties();
			
			var values:Object = propList.value;
			for (var propertyName:String in values){
				_value[propertyName] = values[propertyName];
			} 
		}
		
		public function get value():Object{
			if(_singleton){
				return _value;
			}else{
				instantiate();
				initializeProperties();
				return _value;	 
			}
			
			
		}
		
		public function get propertiesList():ParadeValueList{
			return propList as ParadeValueList;
		}
		
		public function initializeInstance(instance:Object):void{
			var values:Object = propList.value;
			for (var propertyName:String in values){
				instance[propertyName] = values[propertyName];
			} 
			
		}
		
	}
}