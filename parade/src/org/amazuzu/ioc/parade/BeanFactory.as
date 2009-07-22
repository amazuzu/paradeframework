package org.amazuzu.ioc.parade
{
	import flash.utils.describeType;
	
	import mx.rpc.mxml.Concurrency;
	
	import org.amazuzu.ioc.parade.error.IOCError;
	import org.amazuzu.ioc.parade.resolvable.ParadeBean;
	
	public class BeanFactory implements IInternalBeanFactory, IBeanFactory
	{
		private var predefinedBeans:Object /* of Beans */;
		private var metaBeans:Object /* of BeanMeta */;
		
		private var somethingResolved:Boolean;
		private var hasUnresolved:Boolean;
		
		private var _resolvablesFactory:ResolvablesFactory = null;
		
		private var _passives:Array;
		
		protected function getContextResourceClasses():Array /* of Class*/{
			throw new IOCError("Illegal use of IoC", null);
		} 
		
		protected function getSubscribers():Array /* of ISubscriber */{
			return null;
		}
		
		public function BeanFactory()
		{
			metaBeans = {};
			predefinedBeans = {};
			_passives = [];
			hasUnresolved = true;
			_resolvablesFactory = new ResolvablesFactory(this);
		}
		
		public function loadContext():void{
			customBeanRegistration();
			
			var contextResourceClasses:Array  = getContextResourceClasses();
			for each(var ContextResourceClass:Class in contextResourceClasses){
				loadBeansDefinitions(XML(new ContextResourceClass()));
			}

			resolveBeans();
			
			passiveInitialize();
		}
		
		private function loadBeansDefinitions(xmlResorceContext:XML):void{
			for each(var beanDeclaration:XML in xmlResorceContext.children()){
				if(beanDeclaration.name() == ""){
					continue;
				}
				//top level beans should have names
				var beanName:String = beanDeclaration.@name.toXMLString();
				if(beanName == ""){
					throw new IOCError("Context contains unnamed bean: {0}", beanDeclaration);
				}
				metaBeans[beanName] = new ParadeBean(this, beanDeclaration, beanDeclaration.name() == "template");
			}	
		}
		
		protected function customBeanRegistration():void{
			
		}
		
		private function resolveBeans():void{
			
			
			do{
				hasUnresolved = false;
				somethingResolved = false;
				for each(var bean:ParadeBean in metaBeans){
					if(!bean.resolved()){
						notifyHasUnresolved();
						bean.resolve(); 
					}
				}
				
			}while(hasUnresolved && somethingResolved)
			
			
			if(hasUnresolved){				
				var msg:String = "";
				for(var beanName:String in metaBeans){
					if(!(metaBeans[beanName] as ParadeBean).resolved()){
						if(msg == ""){
							msg = beanName;
						}else{
							msg += ", "+beanName;
						}
					}
				}
				throw new IOCError("Bean Factory unable to resolve dependencies: {0}", msg);
			}else{
				for each(var bean:ParadeBean in metaBeans){
					bean.initializeProperties();
				}
			}
		}
		
		public function get resolved():Boolean{
			return !hasUnresolved;
		}
		
		public function notifyResolution():void{
			somethingResolved = true;
		}
		
		public function notifyHasUnresolved():void{
			hasUnresolved = true;
		}
			
		
		public function containsParadeBean(beanName:String):Boolean{
			return metaBeans[beanName] != null;
		} 
		
		public function containsPredefinedBean(beanName:String):Boolean{
			return predefinedBeans[beanName] != null;
		} 

		public function containsBean(beanName:String):Boolean{
			return containsParadeBean(beanName) || containsPredefinedBean(beanName);
		}
		
		public function getParadeBean(beanName:String):ParadeBean{
			return  metaBeans[beanName] as ParadeBean;
		}
		
		public function getPredefinedBean(beanName:String):Object{
			return  predefinedBeans[beanName];
		}
		
		public function getBean(beanName:String):Object{
			if(!containsParadeBean(beanName) && !containsPredefinedBean(beanName)){
				throw new IOCError("bean \"{0}\" wasn't registered in context", beanName);
			}
			
			if(containsParadeBean(beanName)){
				return (metaBeans[beanName] as ParadeBean).value;
			}else{
				return predefinedBeans[beanName];
			}
		}

		
		public function get resolvablesFactory():ResolvablesFactory{
			return _resolvablesFactory;
		}
		
		private function passiveInitialize():void{
			for each(var passive:* in _passives){
				initializeObject(passive);
			}
		}
		
		private function initializeObject(object:Object):void{
			
			var desc:XML = describeType(object);
			var variables:XMLList = desc.variable;
			var accessors:XMLList = desc.accessor;
			
			for each(var variable:XML in variables){
				metadataProcessor(variable, object);
			}
			
			for each(var accessor:XML in accessors){
				metadataProcessor(accessor, object);
			}
		}
		
		public function passiveInit(object:Object):void{
			if(hasUnresolved){
				_passives.push(object);	
			}else{
				initializeObject(object);
			}
			
		}
		
		private function metadataProcessor(decl:XML, object:Object):void{
			for each(var meta:XML in decl.metadata){
				if(meta.@name.toXMLString() == "Inject"){
					var propertyName:String = decl.@name.toXMLString();
					var retrieveBean:String;
						
					if(meta.arg.toXMLString() != ""){
						retrieveBean = meta.arg.@value.toXMLString();
					}else{
						retrieveBean = propertyName;
					}
			
					var bean:Object = getBean(retrieveBean);
					object[propertyName] = bean;
				}		
			}			
		}
		
		public function registerBean(beanName:String, instance:Object):void{
			if(instance == null){
				throw new IOCError("Not allowed to register nullable bean {0}", beanName);
			}
			
			if(beanName == ""){
				throw new IOCError("Not allowed to register bean {0} under empty name", instance);
			}
			predefinedBeans[beanName] = instance;
		}
		

	}
}