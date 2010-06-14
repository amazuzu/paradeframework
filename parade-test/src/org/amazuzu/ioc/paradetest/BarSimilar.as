package org.amazuzu.ioc.paradetest {

    public class BarSimilar {
        public var groo:Groo;

        public var str:String;

        private var _prop1:String;

        public var setsCounter:int = 0;

        public function BarSimilar() {
        }

        public function set prop1(_prop1:String):void {
            this._prop1 = _prop1;
            setsCounter++;
        }

        public function get prop1():String {
            return _prop1;
        }

    }
}