// Basic enum.
public enum CompassPoint {
    case north
    case south
    case east
    case west
}

// Raw value enums, int based.
public enum DayOfWeek: Int {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
}

public enum MathConstants: Float {
    case sqrt2 = 1.41421
    case pi = 3.14159
    case e = 2.71828
    case phi = 1.61803
    case gamma = 0.57721
}

public enum Status: String {
    case success = "OK"
    case failure = "ERROR"
}

// Enum with associated values.
public enum Barcode {
    case upc(numberSystem: Int, manufacturer: Int, product: Int, check: Int)
    case qrCode(String)
}

// Indirect (recursive) enums.
// TODO(swift2objc): indirect recursive enums are not supported yet.
public indirect enum ArithmeticExpression {
    case number(Int)
    case addition(ArithmeticExpression, ArithmeticExpression)
    case multiplication(ArithmeticExpression, ArithmeticExpression)
}

// CaseIterable enums.
public enum Beverage: CaseIterable {
    case coffee, tea, juice
}

// Enum with methods and properties.
public enum TrafficLight {
    case red, yellow, green

    public init?(colorName: String) {
        switch colorName.lowercased() {
            case "red": self = .red
            case "yellow": self = .yellow
            case "green": self = .green
            default: return nil
        }
    }

    public var instruction: String {
        switch self {
            case .red: return "Stop"
            case .yellow: return "Prepare to stop"
            case .green: return "Proceed"
        }
    }

    public mutating func advance() {
        switch self {
            case .red: self = .green
            case .green: self = .yellow
            case .yellow: self = .red
        }
    }
}
