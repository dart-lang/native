// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  @objc static public var globalCustomConstantWrapper: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(globalCustomConstant)
    }
  }

  @objc static public var globalCustomVariableWrapper: MyOtherClassWrapper {
    get {
      MyOtherClassWrapper(globalCustomVariable)
    }
    set {
      globalCustomVariable = newValue.wrappedInstance
    }
  }

  @objc static public var globalGetterVariableWrapper: Double {
    get {
      globalGetterVariable
    }
  }

  @objc static public var globalSetterVariableWrapper: Double {
    get {
      globalSetterVariable
    }
    set {
      globalSetterVariable = newValue
    }
  }

  @objc static public var globalRepresentableConstantWrapper: Int {
    get {
      globalRepresentableConstant
    }
  }

  @objc static public var globalRepresentableVariableWrapper: Int {
    get {
      globalRepresentableVariable
    }
    set {
      globalRepresentableVariable = newValue
    }
  }

  @objc static public func globalCustomFunctionWrapper(label1 param1: Int, param2: MyOtherClassWrapper) -> MyOtherClassWrapper {
    let result = globalCustomFunction(label1: param1, param2: param2.wrappedInstance)
    return MyOtherClassWrapper(result)
  }

  @objc static public func globalRepresentableFunctionWrapper1() {
    return globalRepresentableFunction()
  }

  @objc static public func globalRepresentableFunctionWrapperWrapper() {
    return globalRepresentableFunctionWrapper()
  }

}

@objc public class MyOtherClassWrapper: NSObject {
  var wrappedInstance: MyOtherClass

  init(_ wrappedInstance: MyOtherClass) {
    self.wrappedInstance = wrappedInstance
  }

}

