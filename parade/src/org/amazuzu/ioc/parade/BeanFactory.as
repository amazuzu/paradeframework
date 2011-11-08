package org.amazuzu.ioc.parade {
    import flash.system.ApplicationDomain;
    import flash.utils.describeType;

    import org.amazuzu.ioc.parade.error.IOCError;
    import org.amazuzu.ioc.parade.resolvable.ParadeBean;

    public class BeanFactory {
        private var predefinedBeans:Object /* of Beans */;

        private var metaBeans:Object /* of BeanMeta */;

        private var somethingResolved:Boolean;

        private var hasUnresolved:Boolean;

        private var _resolvablesFactory:ResolvablesFactory = null;

        private var _passives:Array;

        protected var _testMode:Boolean = false;

        protected function getContextResourceClasses():Array /* of Class*/ {
            throw new IOCError("Illegal use of IoC", null);
        }

        protected function getSubscribers():Array /* of ISubscriber */ {
            return null;
        }

        public function BeanFactory() {
            metaBeans = {};
            predefinedBeans = {};
            _passives = [];
            hasUnresolved = true;
            _resolvablesFactory = new ResolvablesFactory(this);
        }

        public function loadContext():void {
            customBeanRegistration();

            var contextResourceClasses:Array = getContextResourceClasses();
            for each (var ContextResourceClass:Class in contextResourceClasses) {
                loadBeansDefinitions(XML(new ContextResourceClass()));
            }

            resolveBeans();

            passiveInitialize();
        }

        public function loadBeanContext(contextResources:Array /* of XML*/, applicationDomain:ApplicationDomain = null):void {


            for each (var contextResource:XML in contextResources) {
                loadBeansDefinitions(contextResource, applicationDomain);
            }
            resolveBeans();

        }

        private function loadBeansDefinitions(xmlResorceContext:XML, applicationDomain:ApplicationDomain = null):void {
            for each (var beanDeclaration:XML in xmlResorceContext.children()) {
                if (beanDeclaration.name() == "") {
                    continue;
                }
                //top level beans should have names
                var beanName:String = beanDeclaration.@name.toXMLString();
                if (beanName == "") {
                    throw new IOCError("Context contains unnamed bean: {0}", beanDeclaration);
                }
                metaBeans[beanName] = new ParadeBean(this, beanDeclaration, beanDeclaration.name() == "template", applicationDomain);
            }
        }

        protected function customBeanRegistration():void {

        }

        private function resolveBeans():void {


            do {
                hasUnresolved = false;
                somethingResolved = false;
                for (var beanName:String in metaBeans) {
                    var bean:ParadeBean = metaBeans[beanName] as ParadeBean;
                    if (!bean.resolved()) {
                        parade_ns::notifyHasUnresolved();

                        bean.resolve();
                    }
                }

            } while (hasUnresolved && somethingResolved)


            if (hasUnresolved) {
                var msg:String = "";
                for (var beanName:String in metaBeans) {
                    if (!(metaBeans[beanName] as ParadeBean).resolved()) {
                        if (msg == "") {
                            msg = beanName;
                        } else {
                            msg += ", " + beanName;
                        }
                    }
                }
                throw new IOCError("Bean Factory unable to resolve dependencies: {0}", msg);
            } else {
                for (var beanName:String in metaBeans) {
                    var bean:ParadeBean = metaBeans[beanName] as ParadeBean;
                    if (!bean.lazy && !bean.initialized) {
                        bean.initializeProperties();
                        bean.initialized = true;
                    }
                }
            }
        }

        parade_ns function notifyResolution():void {
            somethingResolved = true;
        }

        parade_ns function notifyHasUnresolved():void {
            hasUnresolved = true;
        }


        parade_ns function containsParadeBean(beanName:String):Boolean {
            return metaBeans[beanName] != null;
        }

        parade_ns function containsPredefinedBean(beanName:String):Boolean {
            return predefinedBeans[beanName] != null;
        }

        public function containsBean(beanName:String):Boolean {
            return parade_ns::containsParadeBean(beanName) || parade_ns::containsPredefinedBean(beanName);
        }

        parade_ns function getParadeBean(beanName:String):ParadeBean {
            return metaBeans[beanName] as ParadeBean;
        }

        parade_ns function getPredefinedBean(beanName:String):Object {
            return predefinedBeans[beanName];
        }

        public function getBean(beanName:String):Object {
            if (!parade_ns::containsParadeBean(beanName) && !parade_ns::containsPredefinedBean(beanName)) {
                if (!_testMode) {
                    throw new IOCError("bean \"{0}\" wasn't registered in context", beanName);
                } else {
                    return null;
                }
            }

            if (parade_ns::containsParadeBean(beanName)) {
                return (metaBeans[beanName] as ParadeBean).value;
            } else {
                return predefinedBeans[beanName];
            }
        }


        parade_ns function get resolvablesFactory():ResolvablesFactory {
            return _resolvablesFactory;
        }

        private function passiveInitialize():void {
            for each (var passive:* in _passives) {
                initializeObject(passive);
            }

            for each (var passive:* in predefinedBeans) {
                initializeObject(passive);
            }
        }

        private function initializeObject(object:Object):void {

            var desc:XML = describeType(object);
            var variables:XMLList = desc.variable;
            var accessors:XMLList = desc.accessor;
            var methods:XMLList = desc.method;

            for each (var variable:XML in variables) {
                metadataProcessor(variable, object);
            }

            for each (var accessor:XML in accessors) {
                metadataProcessor(accessor, object);
            }

            for each (var method:XML in methods) {
                metadataProcessor(method, object);
            }


        }

        public function passiveInit(object:Object):void {
            if (hasUnresolved) {
                _passives.push(object);
            } else {
                initializeObject(object);
            }

        }

        private function metadataProcessor(decl:XML, object:Object):void {
            for each (var meta:XML in decl.metadata) {
                var metaName:String = meta.@name.toXMLString();
                if (metaName == "Inject") {
                    var propertyName:String = decl.@name.toXMLString();
                    var retrieveBean:String;

                    if (meta.arg.toXMLString() != "") {
                        retrieveBean = meta.arg.@value.toXMLString();
                    } else {
                        retrieveBean = propertyName;
                    }

                    var bean:Object = getBean(retrieveBean);
                    object[propertyName] = bean;
                } else if (metaName == "ParadeInitialize") {
                    object[decl.@name]();
                }
            }
        }

        parade_ns function registerParadeBean(name:String, bean:Object):void {
            metaBeans[name] = bean;
        }

        public function registerBean(beanName:String, instance:Object):void {
            if (instance == null) {
                throw new IOCError("Not allowed to register nullable bean {0}", beanName);
            }

            if (beanName == "") {
                throw new IOCError("Not allowed to register bean {0} under empty name", instance);
            }
            predefinedBeans[beanName] = instance;
        }

    }
}
