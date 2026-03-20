import Foundation

public func applyGlobal(callback: (Int) -> Int, value: Int) -> Int {
  callback(value)
}

public func makeGlobalCallback() -> (Int) -> Int {
  { value in value + 1 }
}

public class ClosureBox {
  public init() {}

  public func apply(callback: (Int) -> Int, value: Int) -> Int {
    callback(value)
  }

  public func makeCallback() -> (Int) -> Int {
    { value in value + 1 }
  }
}
