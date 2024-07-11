import Foundation

@objc public class MyOtherClassWrapper: NSObject {
    var wrappedInstance: MyOtherClass
    init(_ wrappedInstance: MyOtherClass) {
        self.wrappedInstance = wrappedInstance
    }
}
@objc public class MyClassWrapper: NSObject {
    var wrappedInstance: MyClass
    init(_ wrappedInstance: MyClass) {
        self.wrappedInstance = wrappedInstance
    }
    @objc func myMethod2() -> Void {
        return wrappedInstance.myMethod2()
    }
    @objc func myMethod3() {
        wrappedInstance.myMethod3()
    }
    @objc func myMethod(label1 param1: Int, param2: MyOtherClassWrapper) -> MyOtherClassWrapper {
        let result = wrappedInstance.myMethod(label1: param1, param2: param2.wrappedInstance)
        let wrappedResult = MyOtherClassWrapper(result)
        return wrappedResult
    }
}