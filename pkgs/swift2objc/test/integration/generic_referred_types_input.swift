import Foundation

public class MyClass {
    public var customArray: Array<Int>
    public var customDictionary: Dictionary<Int, String>
    public var customSet: Set<String>
    public var nestedGenericVar: Array<Dictionary<Int, Set<String>>>?

    public init(
        customArray: Array<Int>, 
        customDictionary: Dictionary<Int, String>,
        customSet: Set<String>
    ) {
        self.customArray = customArray
        self.customDictionary = customDictionary
        self.customSet = customSet
    }

    public func myMethod(
        label1 param1: Array<String>?,
        param2: Dictionary<String, String>?,
        _ param3: Set<Int>,
        param4: Array<Int>?
    ) -> Array<Bool> {
        return []
    }

    public func nestedGenericMethod(
        param1: Set<Array<Int>>,
        param2: Dictionary<String, Set<Int>>?
    ) -> Array<Dictionary<Int, Set<String>>>? {
        return nil
    }

    public func getLabeledTuple() -> (id: Array<Array<Int>>?, name: Set<String>?) {
        return (id: nil, name: nil)
    }
}

public enum MyEnum {
    case array(Array<Int>)
    case dictionary(Dictionary<Int, Int>)
    case set(Set<Int>)
}

public enum TrafficLight {
    case red, yellow, green

    public var instruction: Array<String> {
        switch self {
            case .red: return ["Stop"]
            case .yellow: return ["Prepare to stop"]
            case .green: return ["Proceed"]
        }
    }
}
