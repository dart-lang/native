import Foundation

public class MyClass {
    public let representableProperty: Int
    public let customProperty: MyOtherClass
    
    public init(outerLabel representableProperty: Int, customProperty: MyOtherClass) {
        self.representableProperty = representableProperty
        self.customProperty = customProperty
    }

    public init(label1 name1: Int, label2: Int, _ name3: Int) {
        self.representableProperty = name1
        self.customProperty = MyOtherClass()
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
