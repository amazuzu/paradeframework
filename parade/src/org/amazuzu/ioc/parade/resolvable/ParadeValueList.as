package org.amazuzu.ioc.parade.resolvable {
    import flash.system.ApplicationDomain;
    import flash.utils.getDefinitionByName;
    
    import org.amazuzu.ioc.parade.BeanFactory;
    import org.amazuzu.ioc.parade.error.IOCError;
    import org.amazuzu.ioc.parade.parade_ns;

    public class ParadeValueList implements IResolvable {
        private var values:Array /* of IResolvable */;

        private var _propertiesResolved:Boolean;

        private var _value:Object = null;

        private var associative:Boolean;

        private var beanFactory:BeanFactory;

        private var applicationDomain:ApplicationDomain;

        private var vectorType:String;

        public function ParadeValueList(beanFactory:BeanFactory, listXml:XMLList, associative:Boolean, applicationDomain:ApplicationDomain, vectorType:String = null) {
            this.beanFactory = beanFactory;
            this.associative = associative;
            this.applicationDomain = applicationDomain;
			this.vectorType = vectorType; 

            values = [];

            _propertiesResolved = true;
            for each (var property:XML in listXml) {
                if (property.localName() == "constructor") {
                    continue;
                }
                //property should contain name
                var propName:String = property.@name.toXMLString();
                if (associative) {
                    var resolvable:IResolvable = beanFactory.parade_ns::resolvablesFactory.createResolvable(property, applicationDomain);
                    if (resolvable is BeanReference && (resolvable as BeanReference).reference != null) {
                        propName = (resolvable as BeanReference).reference;
                    }
                    values[propName] = resolvable;
                } else {
                    var resolvable:IResolvable = beanFactory.parade_ns::resolvablesFactory.createResolvable(property, applicationDomain);
                    values.push(resolvable);
                }
            }

        }

        public function set annotations(_annotations:Array):void {
            for each (var annotEntry:Object in _annotations) {
                var prop:String = annotEntry.property;
                var reference:String = annotEntry.reference;
                if (values[prop] == null) {
                    values[prop] = new BeanReference(beanFactory, reference, false);
                }
            }
        }

        public function resolve():void {
            for each (var property:IResolvable in values) {
                if (!property.resolved()) {
                    property.resolve();
                }
            }
        }

        public function resolved():Boolean {
            for each (var property:IResolvable in values) {
                if (!property.resolved()) {
                    return false;
                }
            }
            return true;
        }

        public function get value():Object {
            if (associative) {
                var argso:Object = {};
                for (var argName:String in values) {
                    argso[argName] = (values[argName] as IResolvable).value;
                }
                _value = argso;
            } else {
                if (vectorType) {
					var vectClass:Class = getDefinitionByName("__AS3__.vec::Vector.<"+vectorType+">") as Class;
                    var argsv:Object = new vectClass();
                    for each (var resolvedArg:IResolvable in values) {
                        argsv.push(resolvedArg.value);
                    }
                    _value = argsv;
					
                } else {
                    var argsa:Array = [];
                    for each (var resolvedArg:IResolvable in values) {
                        argsa.push(resolvedArg.value);
                    }
                    _value = argsa;
                }

            }

            return _value;

        }

        public function initializeProperties():void {
            for each (var property:IResolvable in values) {
                if (!property.resolved()) {
                    property.resolve();
                }
                if (!beanFactory.parade_ns::testMode && !property.resolved()) {
                    throw new IOCError("value {0} couldnt be resolved.", property);
                }
                property.initializeProperties();
            }
        }

        public function performInheritance(childList:ParadeValueList):void {
            for (var propertyName:String in values) {
                if (!childList.valuesMap.hasOwnProperty(propertyName)) {
                    childList.valuesMap[propertyName] = values[propertyName];
                }
            }
        }

        public function get valuesMap():Object {
            return values;
        }
    }
}