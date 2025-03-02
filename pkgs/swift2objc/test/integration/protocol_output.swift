// Test preamble text

import Foundation

@objc public protocol OptionallyRespondsWrapper {
  @objc var response: String {  }
  @objc func optionalMethod() 
  func requiredMethod() 
}

@objc public protocol IdentifiableWrapper {
  var id: String {  }
}

@objc public protocol UserWrapper {
  var email: String {  }
  var currentState: String {  }
  static var configurationName: String {  }
  var isActive: Bool {  }
  static func configure() 
  func displayInfo() -> String 
}

@objc public protocol GreetableWrapper {
  var name: String {  }
  func greet() -> String 
}

