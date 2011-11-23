package org.amazuzu.ioc.paradetest {
    import org.amazuzu.ioc.parade.IBeanNameAware;

    public class PrimitiveHolder implements IBeanNameAware {
        public var pInt:int;

        public var pNumber:Number;

        public var pString:String;

        public var pUint:uint;

        public var pTrue:Boolean;

        public var pFalse:Boolean;

        public var pStringFalse:String;

        public var list:Array;

        public var numVector:Vector.<Number>;
        
        public var myBeanName:String;

        public function PrimitiveHolder(foo:int) {
            trace("" + foo + " " + (foo as int));
        }

        public function set beanName(_beanBean:String):void {
            myBeanName = _beanBean;
        }

    }
}
