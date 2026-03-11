public class MyClass {
    public func originalFunc() -> Int {
        return 0
    }
}

public extension MyClass {
    func extensionFunc(p: String) -> Int {
        return 0
    }

    var extensionComputedProp: Int {
        return 0
    }
}

// Multiple extensions on same type
public extension MyClass {
    static func staticExtensionFunc() -> Int {
        return 0
    }
}

public class BareClass {}

public extension BareClass {
    func fromExtension() -> Int {
        return 0
    }
}

// Extension on struct
public struct MyStruct {
    public func originalStructFunc() -> Int {
        return 0
    }
}

public extension MyStruct {
    func extensionStructFunc(p: String) -> Int {
        return 0
    }

    static func extensionStaticFunc() -> Int {
        return 0
    }

    init(value: Int) {}
}

// Extension on enum
public enum MyEnum {
    case myCase
}

public extension MyEnum {
    func extensionEnumFunc() -> Int {
        return 0
    }
}