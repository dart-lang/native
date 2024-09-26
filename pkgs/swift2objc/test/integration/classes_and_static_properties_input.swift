import Foundation

public class MyClass {
    static public var customSetterVariable: MyOtherClass {
        get { MyOtherClass() }
        set { }
    }

    static public var customGetterVariable: MyOtherClass {
        get { MyOtherClass() }
    }

    static public var customVariableProperty: MyOtherClass = MyOtherClass()

    static public let customConstantProperty: MyOtherClass = MyOtherClass()

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

public class MyOtherClass {}
