package org.amazuzu.ioc.paradetest {

    public class ConstructVector {

        private var vect:Vector.<String>;

        public function ConstructVector(vect:Vector.<String>) {
            this.vect = vect;
        }

        public function getVector():Vector.<String> {
            return vect;
        }
    }
}