import Foundation

public class MyStruct {
    let representableProperty: Int
    let customProperty: MyOtherStruct
    
    public init(outerLabel representableProperty: Int, customProperty: MyOtherStruct) {
        self.representableProperty = representableProperty
        self.customProperty = customProperty
    }
}

public struct MyOtherStruct {}
