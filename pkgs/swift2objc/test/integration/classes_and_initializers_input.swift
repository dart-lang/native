import Foundation

public class MyClass {
    public let representableProperty: Int
    public let customProperty: MyOtherClass
    
    public init(outerLabel representableProperty: Int, customProperty: MyOtherClass) {
        self.representableProperty = representableProperty
        self.customProperty = customProperty
    }

    public init?(outerLabel x: Int) {
        if x == 0 {
            return nil
        } else {
            self.representableProperty = x
            self.customProperty = MyOtherClass()
        }
    }
}

public class MyOtherClass {}
