import Foundation

public protocol Greetable {
    var name: String { get }
    func greet() -> String
}


public protocol Identifiable {
    var id: String { get }
}

public protocol User: Identifiable {
    static var configurationName: String { get }
    static func configure()
    var currentState: String { get set }
    var isActive: Bool { get }
    var email: String { get }
    func displayInfo() -> String
}

@objc public protocol OptionallyResponds {
    @objc optional func optionalMethod()
    @objc optional var response: String { get set }
    func requiredMethod()
}