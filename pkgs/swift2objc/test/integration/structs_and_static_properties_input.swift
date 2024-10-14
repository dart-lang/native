import Foundation

public struct MyStruct {
    static public var customSetterVariable: MyOtherStruct {
        get { MyOtherStruct() }
        set { }
    }

    static public var customGetterVariable: MyOtherStruct {
        get { MyOtherStruct() }
    }

    static public var customVariableProperty: MyOtherStruct = MyOtherStruct()

    static public let customConstantProperty: MyOtherStruct = MyOtherStruct()

    static public var representableSetterVariable: Int {
        get { 1 }
        set { }
    }

    static public var representableGetterVariable: Int {
        get { 1 }
    }

    static public var representableVariableProperty: Int = 1

    static public let representableConstantProperty: Int = 1
}

public struct MyOtherStruct {}
