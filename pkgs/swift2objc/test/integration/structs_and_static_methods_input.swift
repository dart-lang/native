import Foundation

public struct MyStruct {
    static public func myMethod(label1 param1: Int, param2: MyOtherStruct) -> MyOtherStruct {
        return MyOtherStruct()
    }

    static public func myMethod2() -> Void {
        1 + 1
    }

    static public func myMethod3() {
        1 + 1
    }
}

public struct MyOtherStruct {}
