import Foundation

public class Greeter {
    public func greet(name: String = "World", times: Int = 1) -> String {
        return String(repeating: "Hello, \(name)! ", count: times)
    }
    
    public init(greeting: String = "Hi") {
        self.greeting = greeting
    }
    
    private let greeting: String
}

public func globalFunc(param: Int = 12) -> Int {
    return param * 2
}

public func multiDefault(a: Int, b: Int = 10, c: String = "test") -> String {
    return "\(a) \(b) \(c)"
}
