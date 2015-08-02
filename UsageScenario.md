## XML context definition ##

create xml file like my-context.xml
```
<context>

    <bean name="groo" class="org.amazuzu.ioc.paradetest.Groo">
        <property name="bar" ref="bar" />
    </bean>

    <bean name="bar" class="org.amazuzu.ioc.paradetest.Bar">
        <ref>groo</ref>
    </bean>

    <bean name="foo" class="org.amazuzu.ioc.paradetest.Foo">
        <constructor>
            <ref>bar</ref>
            <bean class="org.amazuzu.ioc.paradetest.Baz" />
        </constructor>
    </bean>

</context>
```

  * Look at first bean declaration named "groo". Bean Factory will create a singleton    bean of name **groo** as instance of class **Groo** and initialize property **bar** by reference to instance named **bar** of class **Bar**. Note property name  (bar) is the same as a reference, so `<ref>bar</bar>` could be used instead.



## BeanFactory ##

To initialize BeanFactory you should extends a `BeanFactory` and provide context files by overriding corresponding method:

```
public class YourBeanFactory extends BeanFactory
{
    [Embed(source = "contextes/my-context.xml", mimeType="application/octet-stream")] 
    private static var my_context:Class;
    	
		
    public function YourBeanFactory()
    {
        super();
        Foo;
        Bar;
        Baz;
        Groo;
    }
		
    override protected function getContextResourceClasses():Array /* of Class */{
        return [my_context];
    } 
}
```

Note, in order to instantiate as3 classes you should declare it in code (see constructor). Also dont forget to make `YourBeanFactory` as a singleton to access it from everywhere.



## Usage ##
```
public function initFactory():void{
    var factory:BeanFactory = new YourBeanFactory();
    factory.loadContext();
    var groo:Groo = factory.getBean("groo") as Groo;
```



## IOC features ##



### List of values ###
```
<property name="list">
    <list>
        <bean class="org.amazuzu.ioc.paradetest.Baz" />
        <bean class="org.amazuzu.ioc.paradetest.Bar" />
    </list>
</property>
```
like `someObject.list = [Baz, Bar];`


### Map ###
```
<property name="someMap">
   <map>
        <property name="position">
	    <class>org.foo.Position</class>
        </property>
        <property name="dimenstion">
	    <class>org.foo.Dimension</class>
        </property>
    </map>
</property>				
```
like `someObject.someMap = {position: Position, dimension: Dimension};`



### Singleton ###
By default declared beans are singletons, but you can override default property in bean tag by specifying singleton attribute:
```
<context>
    <bean name="grooSingleton" class="org.amazuzu.ioc.paradetest.Groo"  />
    <bean name="groo" class="org.amazuzu.ioc.paradetest.Groo" singleton="false"/>
</context>
```



### Annotations ###
Sure Parade supports it
```
 public class AnnoFoo
    {
		
        [Inject("groo")]
        public var foobarbaz:Groo;
		
        [Inject]
        public var bar:Bar;
		
        private var _foo:Foo;
		
        [Inject]
        public function set foo(_foo:Foo):void{
            this._foo = _foo;
        }
		
        public function get foo():Foo{
            return _foo;
        }
		
		
        public function AnnoFoo()
        {
        }

    }
```
You could see both member and setter injection. If Inject annotation without name, same name as property assumes.


**Life cycle annotations**

You could specify [ParadeInitialize](ParadeInitialize.md) annotation for some method to be called after all properties injected by BeanFactory.

```
	public class AnnoFoo
	{
		private static var log:ILogger = Log.getLogger("AnnoFoo");
		
		[Inject("groo")]
		public var foobarbaz:Groo;
		
		[Inject]
		public var bar:Bar;
		
		private var _foo:Foo;
		
		[Inject]
		public function set foo(_foo:Foo):void{
			this._foo = _foo;
		}
		
		public function get foo():Foo{
			return _foo;
		}
		
		
		public function AnnoFoo()
		{
		}
		
		[ParadeInitialize]
		public function initialize():void{
			log.debug("YO-YO");
		}


	}
```

### Use of beans instantiated in MXML ###
```
override protected function customBeanRegistration():void{
    registerBean("button1", Application.application.button1);
    registerBean("theCheckBox", Application.application.boxCheck);
}
```



### Passive Initialize ###
In case if you have already instantiated bean and going to fill its annotated properties from BeanFactory you should do this:

```
public class AnnoFoo
{
    [Inject("groo")]
    public var foobarbaz:Groo;
		
    [Inject]
    public var bar:Bar;
		
    private var _foo:Foo;
		
    [Inject]
    public function set foo(_foo:Foo):void{
        this._foo = _foo;
    }
		
    public function get foo():Foo{
        return _foo;
    }
		
		
    public function AnnoFoo()
    {
        YourBeanFactory.instance.passiveInit(this);
    }

}
```
The moment of instantiation doesn't matter (before or after your BeanFactory complete injection). Passively initialized bean will be initialized correctly.




### Templates/Inheritance ###
This feature allows you to create templates of your beans. In current implementation you could specify a template via corresponding tag or via any regular bean. For create another bean that inherits properties of first bean just put inherit attribute to its declaration.

**Regular Bean as a template**

```
<context>
	<bean name="bar" class="org.amazuzu.ioc.paradetest.Bar">
		<property name="groo">
			<bean class="org.amazuzu.ioc.paradetest.Groo" />
		</property>
		<property name="prop1" value="hello" />
	</bean>
	
	<bean name="barSimilar" class="org.amazuzu.ioc.paradetest.BarSimilar" inherit="bar">
		<property name="prop1" value="chiao" />
	</bean>
	
</context>
```
Here bean **barSimilar** inherits groo property value of bean **bar**.

Since overriding also supported prop1 for barSimilar will be "chiao", not "hello".

**Templating**

```

        <template name="barTemplate">
		<property name="groo">
			<bean class="org.amazuzu.ioc.paradetest.Groo" />
		</property>
		<property name="prop1" value="nothello" />
	</template>
	
	<template name="barTemplate2" inherit="barTemplate">
		<property name="prop1" value="hello" />
	</template>
	
	<bean name="barSimilar2" class="org.amazuzu.ioc.paradetest.BarSimilar" inherit="barTemplate2" />
```
Here we declared base template **barTemplate** with two properties groo and prop1. The next template **barTemplate2** inherits properties from **barTemplate** and overrides prop1. **barSimilar2** use **barTemplate** to inherit its properties.