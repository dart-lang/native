import Foundation

public class CustomIndex {}

public class ClassWithSubscripts {
    public subscript(index: Int) -> String {
        get { "" }
        set {}
    }

    public subscript(x: Int, y: Int) -> String {
        get { "" }
        set {}
    }

    public subscript() -> String {
        get { "" }
        set {}
    }

    public static subscript(index: Int) -> String {
        get { "" }
        set {}
    }

    public subscript(index: CustomIndex) -> String {
        get { "" }
        set {}
    }

    public subscript(index: Int?) -> String {
        get { "" }
        set {}
    }

    public subscript(throwing index: Int) -> String {
        get throws { "" }
    }

    public subscript(async index: Int) -> String {
        get async { "" }
    }
}

public struct StructWithSubscript {
    public subscript(index: Int) -> String {
        get { "" }
        set {}
    }
}
