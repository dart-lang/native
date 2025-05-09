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

    public weak var weakProperty: MyOtherClass?
    public unowned var unownedProperty: MyOtherClass
    public lazy var lazyProperty: Int = { 1 }();


    init(
        customVariableProperty: MyOtherClass, 
        customConstantProperty: MyOtherClass,
        representableVariableProperty: Int,
        representableConstantProperty: Int,
        unownedProperty: MyOtherClass
    ) {
        self.customVariableProperty = customVariableProperty
        self.customConstantProperty = customConstantProperty
        self.representableVariableProperty = representableVariableProperty
        self.representableConstantProperty = representableConstantProperty
        self.unownedProperty = unownedProperty
    }
}

public class MyOtherClass {}
