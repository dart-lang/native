
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
