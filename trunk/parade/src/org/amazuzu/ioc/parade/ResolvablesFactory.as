package org.amazuzu.ioc.parade
{
	import flash.utils.getDefinitionByName;
	
	import org.amazuzu.ioc.parade.error.IOCError;
	import org.amazuzu.ioc.parade.resolvable.BeanReference;
	import org.amazuzu.ioc.parade.resolvable.IResolvable;
	import org.amazuzu.ioc.parade.resolvable.ParadeBean;
	import org.amazuzu.ioc.parade.resolvable.ParadeValueList;
	import org.amazuzu.ioc.parade.resolvable.ResolvedValue;
	
	public class ResolvablesFactory
	{
		private var beanFactory:BeanFactory = null;
		
		public function ResolvablesFactory(beanFactory:BeanFactory)
		{
			this.beanFactory = beanFactory;
		}
		
		public function createResolvable(valueXml:XML):IResolvable{
			
			
			
			//<bean name="foo" class="com.free.foo.bar.Baz" />
			if(valueXml.localName() == "bean"){
				return new ParadeBean(beanFactory, valueXml, false);
			}
			
			//<template name="foo" />
			if(valueXml.localName() == "template"){
				return new ParadeBean(beanFactory, valueXml, true);
			}
			
			// <list> ... </list>
			if(valueXml.list.toXMLString() != ""){
				return new ParadeValueList(beanFactory, valueXml.list.children(), false); 
			}
			
			//<map> ... </map>
			if(valueXml.map.toXMLString() != ""){
				return new ParadeValueList(beanFactory, valueXml.map.children(), true); 
			}
			
		    //<xml> ... some xml <tag>..</tag> ... </xml>
		    if(valueXml.localName() == "xml"){
		    	return new ResolvedValue(valueXml.children()[0]);
		    }  
		    
		    //<property name="xml"><xml> ... some xml <tag>..</tag> ... </xml></property>
		    if(valueXml.xml.toXMLString() != ""){
		    	return new ResolvedValue(valueXml.xml.children()[0]);
		    }
		
			//<property name="foo" ref="foo" />
			var valueRef:String = valueXml.@ref.toXMLString(); 
			if(valueRef != ""){
				return new BeanReference(beanFactory, valueRef, true);
			}
			
			//<property name="foo" value="foo"/>
			var aValue:String = valueXml.@value.toXMLString(); 
			if(aValue != ""){
				return new ResolvedValue(aValue);
			}
				
			//<class>com.uimteam.client.test.Foo</class>
			if(valueXml.localName() == "class"){
				return new ResolvedValue(getDefinitionByName(valueXml.text()));
			}
			
			//<string>Foo</string>
			if(valueXml.localName() == "string"){
				return new ResolvedValue(valueXml.text());
			}
			
			//<int>23</int>
			if(valueXml.localName() == "int"){
				return new ResolvedValue(parseInt(valueXml.text()));
			}
			
			//<uint>0xAA</uint>
			if(valueXml.localName() == "uint"){
				return new ResolvedValue(parseInt(valueXml.text(), 16));
			}
			
			//<number>10.4</number>
			if(valueXml.localName() == "number"){
				return new ResolvedValue(parseFloat(valueXml.text()));
			}
			
			//<ref>foo</ref> 
			if(valueXml.localName() == "ref"){
				return new BeanReference(beanFactory, valueXml.text(), false);
			}
			
			//<property> <bean name="foo" class="com.free.foo.bar" /> </property>
			if(valueXml.bean.toXMLString() != ""){
				return new ParadeBean(beanFactory, valueXml.bean[0], false);
			}
			
			//<property name="clazz" class="com.lala.fafa.Foo" />
			if(valueXml.@["class"].toXMLString() != ""){
				return new ResolvedValue(getDefinitionByName(valueXml.@["class"]));
			}
			
			//<property> <class>com.lala.fafa.Foo</clas> </property>
			if(valueXml.children()[0].localName() == "class"){
				trace("class found "+valueXml.children()[0].text());
				return new ResolvedValue(getDefinitionByName(valueXml.children()[0].text()));
			}
			
			throw new IOCError("Error in XML DTD: {0}", valueXml.toXMLString()); 
		}

	}
}