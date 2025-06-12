import Foundation

public struct MyStruct {
    public var customSetterProperty: MyOtherStruct {
        get { MyOtherStruct() }
        set { }
    }

    public var customGetterProperty: MyOtherStruct {
        get { MyOtherStruct() }
    }

    public var customVariableProperty: MyOtherStruct

    public let customConstantProperty: MyOtherStruct

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

    public var mutatingProperty: Int {
        mutating get { 1 }
    }


    init(
        customVariableProperty: MyOtherStruct, 
        customConstantProperty: MyOtherStruct,
        representableVariableProperty: Int,
        representableConstantProperty: Int
    ) {
        self.customVariableProperty = customVariableProperty
        self.customConstantProperty = customConstantProperty
        self.representableVariableProperty = representableVariableProperty
        self.representableConstantProperty = representableConstantProperty
    }
}

public struct MyOtherStruct {}
