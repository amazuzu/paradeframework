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
		private var beanFactory:IInternalBeanFactory = null;
		
		public function ResolvablesFactory(beanFactory:IInternalBeanFactory)
		{
			this.beanFactory = beanFactory;
		}
		
		public function createResolvable(valueXml:XML):IResolvable{
			
			
			
			//<bean name="foo" class="com.free.foo.bar.Baz" />
			if(valueXml.localName() == "bean"){
				return new ParadeBean(beanFactory, valueXml);
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
			
			//<ref>foo</ref> 
			if(valueXml.localName() == "ref"){
				return new BeanReference(beanFactory, valueXml.text(), false);
			}
			
			//<property> <bean name="foo" class="com.free.foo.bar" /> </property>
			if(valueXml.bean.toXMLString() != ""){
				return new ParadeBean(beanFactory, valueXml.bean[0]);
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