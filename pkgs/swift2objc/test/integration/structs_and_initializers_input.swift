import Foundation

public class MyStruct {
    let representableProperty: Int
    let customProperty: MyOtherStruct
    
    public init(outerLabel representableProperty: Int, customProperty: MyOtherStruct) {
        self.representableProperty = representableProperty
        self.customProperty = customProperty
    }

    public init?(outerLabel x: Int) {
        if x == 0 {
            return nil
        } else {
            self.representableProperty = x
            self.customProperty = MyOtherStruct()
        }
    }
}

public struct MyOtherStruct {}
