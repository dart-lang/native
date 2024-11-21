// Test preamble text

import Foundation

@objc public class GlobalsWrapper: NSObject {
  // s:18symbolgraph_module14globalOptionalAA8MyStructVSgvp
  @objc static public var globalOptionalWrapper: MyStructWrapper {
    get {
      MyStructWrapper(globalOptional)
    }
    set {
      globalOptional = newValue.wrappedInstance
    }
  }
  
  // s:18symbolgraph_module16funcOptionalArgs5labelAA7MyClassCAESg_tF
  @objc static public func funcOptionalArgsWrapper(label param: MyClassWrapper) -> MyClassWrapper {
    let result = funcOptionalArgs(label: param.wrappedInstance)
    return MyClassWrapper(result)
  }
  
  // s:18symbolgraph_module23funcOptionalClassReturnAA02MyE0CSgyF
  @objc static public func funcOptionalClassReturnWrapper() -> MyClassWrapper? {
    let result = funcOptionalClassReturn()
    return result == nil ? nil : MyClassWrapper(result)
  }
  
  // s:18symbolgraph_module24funcMultipleOptionalArgs6label16label26label3yAA7MyClassCSg_SiAA0J6StructVSgtF
  @objc static public func funcMultipleOptionalArgsWrapper(label1 param1: MyClassWrapper, label2 param2: Int, label3 param3: MyStructWrapper) -> Void {
    return funcMultipleOptionalArgs(label1: param1.wrappedInstance, label2: param2, label3: param3.wrappedInstance)
  }
  
  // s:18symbolgraph_module24funcOptionalStructReturnAA02MyE0VSgyF
  @objc static public func funcOptionalStructReturnWrapper() -> MyStructWrapper? {
    let result = funcOptionalStructReturn()
    return result == nil ? nil : MyStructWrapper(result)
  }
}

@objc public class MyClassWrapper: NSObject {
  var wrappedInstance: MyClass
  
  // s:18symbolgraph_module7MyClassC16optionalPropertyACSgvp
  @objc public var optionalProperty: MyClassWrapper {
    get {
      MyClassWrapper(wrappedInstance.optionalProperty)
    }
    set {
      wrappedInstance.optionalProperty = newValue.wrappedInstance
    }
  }
  
  // 
  init(_ wrappedInstance: MyClass) {
    self.wrappedInstance = wrappedInstance
  }
  
  // s:18symbolgraph_module7MyClassC5labelA2CSg_tcfc
  @objc init(label param: MyClassWrapper) {
    wrappedInstance = MyClass(label: param.wrappedInstance)
  }
  
  // s:18symbolgraph_module7MyClassC18methodOptionalArgs5labelyACSg_tF
  @objc public func methodOptionalArgs(label param: MyClassWrapper) -> Void {
    return wrappedInstance.methodOptionalArgs(label: param.wrappedInstance)
  }
  
  // s:18symbolgraph_module7MyClassC20methodOptionalReturnACSgyF
  @objc public func methodOptionalReturn() -> MyClassWrapper? {
    let result = wrappedInstance.methodOptionalReturn()
    return result == nil ? nil : MyClassWrapper(result)
  }
}

@objc public class MyStructWrapper: NSObject {
  var wrappedInstance: MyStruct
  
  // s:18symbolgraph_module8MyStructV16optionalPropertyAA0C5ClassCSgvp
  @objc public var optionalProperty: MyClassWrapper {
    get {
      MyClassWrapper(wrappedInstance.optionalProperty)
    }
    set {
      wrappedInstance.optionalProperty = newValue.wrappedInstance
    }
  }
  
  // 
  init(_ wrappedInstance: MyStruct) {
    self.wrappedInstance = wrappedInstance
  }
  
  // s:18symbolgraph_module8MyStructV5labelAcA0C5ClassCSg_tcfc
  @objc init(label param: MyClassWrapper) {
    wrappedInstance = MyStruct(label: param.wrappedInstance)
  }
  
  // s:18symbolgraph_module8MyStructV18methodOptionalArgs5labelyAA0C5ClassCSg_tF
  @objc public func methodOptionalArgs(label param: MyClassWrapper) -> Void {
    return wrappedInstance.methodOptionalArgs(label: param.wrappedInstance)
  }
  
  // s:18symbolgraph_module8MyStructV20methodOptionalReturnACSgyF
  @objc public func methodOptionalReturn() -> MyStructWrapper? {
    let result = wrappedInstance.methodOptionalReturn()
    return result == nil ? nil : MyStructWrapper(result)
  }
}
