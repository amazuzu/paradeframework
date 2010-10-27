package org.amazuzu.ioc.parade {
    import flash.system.ApplicationDomain;
    import flash.utils.getDefinitionByName;

    import org.amazuzu.ioc.parade.error.IOCError;
    import org.amazuzu.ioc.parade.resolvable.BeanReference;
    import org.amazuzu.ioc.parade.resolvable.IResolvable;
    import org.amazuzu.ioc.parade.resolvable.ParadeBean;
    import org.amazuzu.ioc.parade.resolvable.ParadeValueList;
    import org.amazuzu.ioc.parade.resolvable.ResolvedValue;

    public class ResolvablesFactory {
        private var beanFactory:BeanFactory = null;

        public function ResolvablesFactory(beanFactory:BeanFactory) {
            this.beanFactory = beanFactory;
        }

        public function createResolvable(valueXml:XML, applicationDomain:ApplicationDomain):IResolvable {

            if (valueXml.localName() == "property") {

                //<property name="foo" ref="foo" /> 
                if (valueXml.@ref.length() == 1) {
                    return new BeanReference(beanFactory, valueXml.@ref.toXMLString(), true);
                }

                //<property name="foo" value="foo"/> 
                if (valueXml.@value.length() == 1) {
                    return new ResolvedValue(valueXml.@value.toXMLString());
                }

                //<property name="clazz" class="com.lala.fafa.Foo" />
                if (valueXml.@["class"].length() == 1) {
                    return new ResolvedValue(getClass(valueXml.@["class"], applicationDomain));
                }

                valueXml = valueXml.children()[0];
            }

            //<bean name="foo" class="com.free.foo.bar.Baz" />
            if (valueXml.localName() == "bean") {
                var bean:ParadeBean = new ParadeBean(beanFactory, valueXml, false, applicationDomain);
                beanFactory.parade_ns::registerParadeBean(valueXml.@name.toXMLString(), bean);
                return bean;
            }

            //<template name="foo" />
            if (valueXml.localName() == "template") {
                return new ParadeBean(beanFactory, valueXml, true);
            }


            if (valueXml.localName() == "list") {
                return new ParadeValueList(beanFactory, valueXml.children(), false, applicationDomain);
            }

            // <vector type="Number"> ... </vector>
            if (valueXml.localName() == "vector") {
                var vectorType:String = valueXml.@type;
                return new ParadeValueList(beanFactory, valueXml.children(), false, applicationDomain, vectorType);
            }

            if (valueXml.localName() == "map") {
                return new ParadeValueList(beanFactory, valueXml.children(), true, applicationDomain);
            }

            //<xml> ... some xml <tag>..</tag> ... </xml>
            if (valueXml.localName() == "xml") {
                return new ResolvedValue(valueXml.children()[0]);
            }

            //<class>com.uimteam.client.test.Foo</class>
            if (valueXml.localName() == "class") {
                return new ResolvedValue(getClass(valueXml.text().toXMLString(), applicationDomain));
            }

            //<string>Foo</string>
            if (valueXml.localName() == "string") {
                return new ResolvedValue(valueXml.text().toXMLString());
            }

            //<int>23</int>
            if (valueXml.localName() == "int") {
                return new ResolvedValue(parseInt(valueXml.text().toXMLString()));
            }

            //<uint>0xAA</uint>
            if (valueXml.localName() == "uint") {
                return new ResolvedValue(parseInt(valueXml.text().toXMLString(), 16));
            }

            //<number>10.4</number>
            if (valueXml.localName() == "number") {
                return new ResolvedValue(parseFloat(valueXml.text().toXMLString()));
            }

            //<ref>foo</ref> 
            if (valueXml.localName() == "ref") {
                return new BeanReference(beanFactory, valueXml.text(), false);
            }

            //<property> <bean name="foo" class="com.free.foo.bar" /> </property>
            if (valueXml.localName() == "bean") {
                var bean:ParadeBean = new ParadeBean(beanFactory, valueXml, false);
                beanFactory.parade_ns::registerParadeBean(valueXml.@name.toXMLString(), bean);
                return bean;
            }

            //<property> <class>com.lala.fafa.Foo</clas> </property>
            if (valueXml.localName() == "class") {
                //trace("class found " + valueXml.children()[0].text());
                return new ResolvedValue(getClass(valueXml.text(), applicationDomain));
            }

            throw new IOCError("Error in XML DTD: {0}", valueXml.toXMLString());
        }

        private function getClass(classStr:String, applicationDomain:ApplicationDomain):Class {
            if (applicationDomain) {
                return applicationDomain.getDefinition(classStr) as Class;
            } else {
                return getDefinitionByName(classStr) as Class;
            }
        }

    }
}