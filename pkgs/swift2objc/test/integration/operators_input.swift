infix operator ***: MultiplicationPrecedence


public class Vec2 {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public static func + (lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func == (lhs: Vec2, rhs: Vec2) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public static func *** (lhs: Vec2, rhs: Vec2) -> Double {
        return (lhs.x * rhs.x) + (lhs.y * rhs.y)
    }
}