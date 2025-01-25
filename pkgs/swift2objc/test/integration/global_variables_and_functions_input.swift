import Foundation

public var globalRepresentableVariable = 1
public let globalRepresentableConstant = 1

public var globalCustomVariable = MyOtherClass()
public let globalCustomConstant = MyOtherClass()

public var globalGetterVariable: Double { get { 123 } }
public var globalSetterVariable: Double { get { 123 } set {} }

public func globalCustomFunction(label1 param1: Int, param2: MyOtherClass) -> MyOtherClass {
    return MyOtherClass()
}

public func globalRepresentableFunction() -> Void {
    1 + 1
}

public func globalRepresentableFunctionWrapper() {
    globalRepresentableFunction()
}

public class MyOtherClass {}
