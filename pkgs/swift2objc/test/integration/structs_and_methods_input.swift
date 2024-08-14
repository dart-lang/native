import Foundation

public struct MyStruct {
    public func myMethod(label1 param1: Int, param2: MyOtherStruct) -> MyOtherStruct {
        return MyOtherStruct()
    }

    public func myMethod2() -> Void {
        1 + 1
    }

    public func myMethod3() {
        1 + 1
    }
}

public struct MyOtherStruct {}
