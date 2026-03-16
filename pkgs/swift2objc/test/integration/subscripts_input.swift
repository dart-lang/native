import Foundation
public class SubscriptClass {
    public var stored: String = ""

    public subscript(index: Int) -> String {
        get {
            return stored
        }
        set {
            stored = newValue
        }
    }
}

public class MultipleArgsSubscript {
    public subscript(row: Int, col: Int) -> Int {
        get {
            return row + col
        }
    }
}

public class ZeroArgsSubscript {
    public subscript() -> Int {
        get {
            return 42
        }
    }
}

public class StaticSubscript {
    public static subscript(name: String) -> String {
        get {
            return "Hello, " + name
        }
    }
}

public class NonTrivialTypesSubscript {
    public subscript(other: SubscriptClass) -> SubscriptClass {
        get {
            return other
        }
    }
}

@objc public class OptionalSubscript: NSObject {
    @objc public subscript(opt: String?) -> String? {
        get {
            return opt == nil ? nil : "Value: \(opt!)"
        }
    }
}

public struct SubscriptStruct {
    public var value: Int = 0

    public subscript(index: Int) -> Int {
        get {
            return value + index
        }
        set {
            value = index + newValue
        }
    }
}

public class ThrowingSubscript {
    public subscript(index: Int) -> String {
        get throws {
            return "OK"
        }
    }
}

public class AsyncSubscript {
    public subscript(index: Int) -> String {
        get async {
            return "Async OK"
        }
    }
}
