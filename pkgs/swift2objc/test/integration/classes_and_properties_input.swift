import Foundation

public class MyClass {
    public var customSetterProperty: MyOtherClass {
        get { MyOtherClass() }
        set { }
    }

    public var customGetterProperty: MyOtherClass {
        get { MyOtherClass() }
    }

    public var customVariableProperty: MyOtherClass

    public let customConstantProperty: MyOtherClass

    public var representableSetterProperty: Int {
        get { 1 }
        set { }
    }

    public var representableGetterProperty: Int {
        get { 1 }
    }

    public var implicitGetterProperty: Int { 1 }

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
