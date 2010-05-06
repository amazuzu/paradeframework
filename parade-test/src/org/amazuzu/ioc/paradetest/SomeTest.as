package org.amazuzu.ioc.paradetest {
    import flexunit.framework.TestCase;

    import org.amazuzu.ioc.parade.BeanFactory;
    import org.amazuzu.ioc.paradetest.mixtestcase.B;
    import org.amazuzu.ioc.paradetest.mixtestcase.D;
    import org.amazuzu.ioc.paradetest.recursion.Ins1;
    import org.amazuzu.ioc.paradetest.recursion.Ins2;
    import org.amazuzu.ioc.paradetest.recursion.Ins3;
    import org.amazuzu.ioc.paradetest.recursion.Ins4;

    public class SomeTest extends TestCase {
        [Embed(source="testcases/constructor.xml", mimeType = "application/octet-stream")]
        private static var constructor:Class;

        [Embed(source="testcases/cyclic.xml", mimeType = "application/octet-stream")]
        private static var cyclic:Class;

        [Embed(source="testcases/list.xml", mimeType = "application/octet-stream")]
        private static var list:Class;

        [Embed(source="mixtestcase/mixtest.xml", mimeType = "application/octet-stream")]
        private static var mixtest:Class;

        [Embed(source="testcases/singleton.xml", mimeType = "application/octet-stream")]
        private static var singleton:Class;

        [Embed(source="recursion/recursion.xml", mimeType = "application/octet-stream")]
        private static var recursion:Class;

        [Embed(source="testcases/justannot.xml", mimeType = "application/octet-stream")]
        private static var justannot:Class;

        [Embed(source="testcases/inheritance.xml", mimeType = "application/octet-stream")]
        private static var inheritance:Class;

        [Embed(source="testcases/primitives.xml", mimeType = "application/octet-stream")]
        private static var primitives:Class;

        [Embed(source="modular/module1.xml", mimeType = "application/octet-stream")]
        private static var module1:Class;

        [Embed(source="modular/module2.xml", mimeType = "application/octet-stream")]
        private static var module2:Class;


        public function testConstructor():void {
            var factory:BeanFactory = new TestBeanFactory(constructor);
            factory.loadContext();
            assertEquals("foo(bar()[null],baz()[null])[baz()[FREE]]", factory.getBean("foo"));
        }

        public function testCyclic():void {
            var factory:BeanFactory = new TestBeanFactory(cyclic);
            factory.loadContext();
            assertNotNull("groo", factory.getBean("groo")as Groo);
            assertNotNull("bar", factory.getBean("bar")as Bar);
            assertNotNull("groo hasnt bar", (factory.getBean("groo")as Groo).bar);
            assertNotNull("bar hasnt groo", (factory.getBean("bar")as Bar).groo);
        }

        public function testList():void {
            var factory:BeanFactory = new TestBeanFactory(list);
            factory.loadContext();
            var groo:Groo = factory.getBean("groo")as Groo;
            var groolist:Array = groo.list;
            assertNotNull(groolist);
            assertTrue(groolist[0]is Baz);
            assertTrue(groolist[1]is Bar);

            assertNotNull(groo.theMap);

            assertEquals(groo.theMap["bar"], Bar);
            assertEquals(groo.theMap["baz"], Baz);

            assertEquals(groo.clazz, Baz);

            assertEquals(groo.someXml.baz.text(), "nana");


        }

        public function testMix():void {
            B;
            D;
            var factory:BeanFactory = new TestBeanFactory(mixtest);
            factory.loadContext();
        }



        public function testSingleton():void {
            var factory:BeanFactory = new TestBeanFactory(singleton);
            factory.loadContext();
            var s1:Groo = factory.getBean("grooSingleton")as Groo;
            var s2:Groo = factory.getBean("grooSingleton")as Groo;

            assertTrue(s1.singleCheck == s2.singleCheck);

            var s3:Groo = factory.getBean("groo")as Groo;
            var s4:Groo = factory.getBean("groo")as Groo;

            assertFalse(s3.singleCheck == s4.singleCheck);
        }

        public function testRecursion():void {
            var factory:BeanFactory = new TestBeanFactory(recursion);
            factory.loadContext();
            assertNotNull("ins1", factory.getBean("ins1")as Ins1);
            assertNotNull("ins2", factory.getBean("ins2")as Ins2);
            assertNotNull("ins3", factory.getBean("ins3")as Ins3);
            assertNotNull("ins4", factory.getBean("ins4")as Ins4);
        }

        public function testPassiveAnnotativeInitialize():void {
            var factory:BeanFactory = new TestBeanFactory(cyclic);
            factory.loadContext();
            var af:AnnoFoo = new AnnoFoo();
            factory.passiveInit(af);
            assertTrue(af.foobarbaz != null);
            assertTrue(af.bar != null);
            assertTrue(af.foo != null);
        }

        public function testAnnotations():void {
            var factory:BeanFactory = new TestBeanFactory(justannot);
            factory.loadContext();
            var af:AnnoFoo = (factory.getBean("afdep")as AFDependent).af;
            assertTrue(af.foobarbaz != null);
            assertTrue(af.bar != null);
            assertTrue(af.foo != null);
        }

        public function testInheritance():void {
            var factory:BeanFactory = new TestBeanFactory(inheritance);
            factory.loadContext();
            assertTrue(factory.getBean("bar") != null);
            assertTrue((factory.getBean("bar")as Bar).groo != null);
            assertTrue((factory.getBean("bar")as Bar).prop1 == "hello");

            assertTrue(factory.getBean("barSimilar") != null);
            assertTrue((factory.getBean("barSimilar")as BarSimilar).groo != null);
            assertTrue((factory.getBean("barSimilar")as BarSimilar).prop1 == "chiao");


            assertTrue(factory.getBean("barSimilar2") != null);
            assertTrue((factory.getBean("barSimilar2")as BarSimilar).groo != null);
            assertTrue((factory.getBean("barSimilar2")as BarSimilar).prop1 == "hello");

            assertTrue(factory.getBean("bar55") != null);
            assertTrue(factory.getBean("barSimilar55") != null);
            assertTrue((factory.getBean("barSimilar55")as BarSimilar).prop1 == "supersuper55");
            assertNotNull((factory.getBean("barSimilar55")as BarSimilar).groo);


            var bar1:BarSimilar = (factory.getBean("barXXX")as BarSimilar);
            var bar2:BarSimilar = (factory.getBean("barXXX")as BarSimilar);
            assertFalse(bar1 == bar2);
            assertFalse(bar1.groo == bar2.groo);


        }

        public function testPrimitives():void {
            PrimitiveHolder;
            var factory:BeanFactory = new TestBeanFactory(primitives);
            factory.loadContext();
            var holder:PrimitiveHolder = factory.getBean("primitive")as PrimitiveHolder;
            assertTrue(holder != null);

            assertTrue(holder.pInt == 10);
            assertTrue(holder.pNumber == 20.4);
            assertTrue(holder.pString == "hello");
            assertTrue(holder.pUint == 23);
            assertTrue(holder.pTrue == true);
            assertTrue(holder.pFalse == false);
            assertTrue(holder.pStringFalse == "false");

            assertNotNull(holder.list);
            assertEquals(holder.list[0], "foo");
            assertEquals(holder.list[1], 100);
            assertEquals(holder.list[2], 0xdd);
            assertEquals(holder.list[3], 3.1415);

        }

        public function testModularContext():void {
            var factory:BeanFactory = new TestBeanFactory(module1);
            factory.loadContext();
            assertFalse(factory.containsBean("foo"));
            factory.loadBeanContext([XML(new module2())]);
            assertTrue(factory.containsBean("foo"));
        }
    }
}