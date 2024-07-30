import Foundation

public class MyClass {
    public var customSetterVariable: MyOtherClass {
        get { MyOtherClass() }
        set { }
    }

    public var customGetterVariable: MyOtherClass {
        get { MyOtherClass() }
    }

    public var customVariableProperty: MyOtherClass

    public let customConstantProperty: MyOtherClass

    public var representableSetterVariable: Int {
        get { 1 }
        set { }
    }

    public var representableGetterVariable: Int {
        get { 1 }
    }

    public var representableVariableProperty: Int

    public let representableConstantProperty: Int


    init(
        customVariableProperty: MyOtherClass, 
        customConstantProperty: MyOtherClass,
        representableVariableProperty: Int,
        representableConstantProperty: Int
    ) {
        self.customVariableProperty = customVariableProperty
        self.customConstantProperty = customConstantProperty
        self.representableVariableProperty = representableVariableProperty
        self.representableConstantProperty = representableConstantProperty
    }
}

public class MyOtherClass {}
