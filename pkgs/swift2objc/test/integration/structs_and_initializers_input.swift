import Foundation

public class MyStruct {
    public let representableProperty: Int
    public let customProperty: MyOtherStruct
    
    public init(outerLabel representableProperty: Int, customProperty: MyOtherStruct) {
        self.representableProperty = representableProperty
        self.customProperty = customProperty
    }

    public init(label1 name1: Int, label2: Int, _ name3: Int) {
        self.representableProperty = name1
        self.customProperty = MyOtherStruct()
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
