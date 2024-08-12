import Foundation

public struct MyStruct {
    public var customSetterVariable: MyOtherStruct {
        get { MyOtherStruct() }
        set { }
    }

    public var customGetterVariable: MyOtherStruct {
        get { MyOtherStruct() }
    }

    public var customVariableProperty: MyOtherStruct

    public let customConstantProperty: MyOtherStruct

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
