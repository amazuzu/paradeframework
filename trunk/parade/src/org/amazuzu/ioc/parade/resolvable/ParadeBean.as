package org.amazuzu.ioc.parade.resolvable {
    import flash.system.ApplicationDomain;
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;

    import mx.utils.StringUtil;

    import org.amazuzu.ioc.parade.BeanFactory;
    import org.amazuzu.ioc.parade.IBeanNameAware;
    import org.amazuzu.ioc.parade.error.IOCError;
    import org.amazuzu.ioc.parade.error.IOCInternalError;
    import org.amazuzu.ioc.parade.parade_ns;

    public class ParadeBean implements IResolvable {

        private var _beanName:String = null;

        private var beanFactory:BeanFactory = null;

        private var constrList:IResolvable;

        private var propList:ParadeValueList;

        private var _classStr:String = null;

        private var _singleton:Boolean;

        private var _value:Object = null;

        private var instantiated:Boolean = false;

        private var inherit:String = null;

        private var _template:Boolean;

        private var _inherited:Boolean = false;

        private var paradeInitialize:String = null;

        private var _lazy:Boolean = false;

        private var applicationDomain:ApplicationDomain;

        public var initialized:Boolean = false;

        public function ParadeBean(beanFactory:BeanFactory, beanXml:XML, _template:Boolean, applicationDomain:ApplicationDomain = null) {
            this.beanFactory = beanFactory;
            this.applicationDomain = applicationDomain;

            this._template = _template;

            if (beanXml.attribute("name").toXMLString() != "") {
                _beanName = beanXml.attribute("name").toXMLString();

            } else {
            }

            if (!_template && beanXml.attribute("class").toXMLString() != "") {
                _classStr = beanXml.attribute("class").toXMLString();

            } else {
            }

            if (!_template && beanXml.@singleton.toXMLString() == "false") {
                _singleton = false;
            } else {
                _singleton = true;
            }

            if (!_singleton || beanXml.@lazy.length() == 1 && beanXml.@lazy.toXMLString() == "true") {
                _lazy = true;
            }

            if (beanXml.attribute("inherit").toXMLString() != "") {
                inherit = beanXml.attribute("inherit").toXMLString();
            } else {
            }





            if (!_template) {
                constrList = new ParadeValueList(beanFactory, beanXml.constructor.children(), false, applicationDomain);
            }

            propList = new ParadeValueList(beanFactory, beanXml.children(), true, applicationDomain);


        }

//* for prop list */
        private function collectAnnotatedReferences(_class:Class):void {
            var annotations:Array /* of Objects {property:..., reference:...}*/ = [];


            var desc:XML = describeType(_class).factory[0];

            var variables:XMLList = desc.variable;
            var accessors:XMLList = desc.accessor;
            var methods:XMLList = desc.method;

            for each (var variable:XML in variables) {
                metadataProcessor(annotations, variable);
            }

            for each (var accessor:XML in accessors) {
                metadataProcessor(annotations, accessor);
            }

            for each (var method:XML in methods) {
                metadataProcessor(annotations, method);
            }

            propList.annotations = annotations;
        }


        private function metadataProcessor(annotations:Array, decl:XML):void {
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
                    annotations.push({ property: propertyName, reference: retrieveBean });
                } else if (metaName == "ParadeInitialize") {
                    paradeInitialize = decl.@name;
                }
            }
        }


        public function resolved():Boolean {
            return _template || constrList.resolved() && (_singleton && instantiated || !_singleton);
        }

        public function resolve():void {
            if (_template) {
                throw new IOCInternalError();
            }

            if (constrList.resolved()) {
                if (_singleton && !instantiated) {
                    instantiate();
                }
                beanFactory.parade_ns::notifyResolution();

            } else {
                beanFactory.parade_ns::notifyHasUnresolved();
                constrList.resolve();
            }
        }

        private function instantiate():void {
            if (_template) {
                return;
            }

            var a:Array = constrList.value as Array;

            var _class:Class = null;
            if (applicationDomain) {
                _class = applicationDomain.getDefinition(_classStr) as Class;
            } else {
                _class = getDefinitionByName(_classStr) as Class;
            }
            collectAnnotatedReferences(_class);

            switch (a.length) {
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


            if (_value is IBeanNameAware) {
                (_value as IBeanNameAware).beanName = _beanName;
            }



            if (_singleton && instantiated) {
                //couldn't be instantiated twicely
                throw new IOCInternalError();
            }

            instantiated = true;

        }


        public function initializeProperties():void {


            if (!_template) {

                if (_singleton && !instantiated || !_singleton) {
                    instantiate();
                }
            }

            if (!_template) {
                constrList.initializeProperties();
            }


            if (inherit != null) {

                if (!_inherited) {
                    var inherits:Array = null;

                    if (inherit.indexOf(",") != -1) {
                        inherits = inherit.split(",");

                    } else {
                        inherits = [ inherit ]
                    }


                    for each (var template:String in inherits) {
                        var father:ParadeBean = beanFactory.parade_ns::getParadeBean(StringUtil.trim(template));

                        if (father == null) {
                            throw new IOCError("Definition for template '{0}' wasn't found in context. See bean of class {1}", StringUtil.trim(template), _classStr);
                            return;
                        }

                        if (!father.inherited) {
                            father.initializeProperties();
                        }
                        father.propertiesList.performInheritance(propList);
                    }
                    _inherited = true;
                }


            }

            propList.initializeProperties();

            if (!_template) {
                var values:Object = propList.value;
                for (var propertyName:String in values) {
                    _value[propertyName] = values[propertyName];
                }

                if (paradeInitialize) {
                    _value[paradeInitialize]();

                }
            }
        }

        public function get inherited():Boolean {
            return _inherited;
        }

        public function get value():Object {
            if (_singleton) {
                return _value;
            } else {
                initializeProperties();
                return _value;
            }


        }

        public function get propertiesList():ParadeValueList {
            return propList as ParadeValueList;
        }

        public function initializeInstance(instance:Object):void {
            var values:Object = propList.value;
            for (var propertyName:String in values) {
                instance[propertyName] = values[propertyName];
            }
        }

        public function get lazy():Boolean {
            return _lazy;
        }

    }
}
