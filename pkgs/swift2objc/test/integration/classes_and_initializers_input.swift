import Foundation

public class MyClass {
    public let representableProperty: Int
    public let customProperty: MyOtherClass
    
    public init(outerLabel representableProperty: Int, customProperty: MyOtherClass) {
        self.representableProperty = representableProperty
        self.customProperty = customProperty
    }
}

public class MyOtherClass {}
