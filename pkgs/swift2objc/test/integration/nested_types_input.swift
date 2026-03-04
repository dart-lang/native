public class OuterClass {
  public static func makeOuter() -> OuterClass { return OuterClass(); }
  public static func makeInnerClass() -> InnerClass { return InnerClass(); }
  public static func makeInnerStruct() -> InnerStruct { return InnerStruct(); }

  public class InnerClass {
    public static func makeOuter() -> OuterClass { return OuterClass(); }
    public static func makeInner() -> InnerClass { return InnerClass(); }
  }

  public struct InnerStruct {
    public static func makeOuter() -> OuterClass { return OuterClass(); }
    public static func makeInner() -> InnerStruct { return InnerStruct(); }
  }

  public func makeOther() -> OuterStruct.InnerClass {
    return OuterStruct.InnerClass();
  }
}

public struct OuterStruct {
  public static func makeOuter() -> OuterStruct { return OuterStruct(); }
  public static func makeInnerClass() -> InnerClass { return InnerClass(); }
  public static func makeInnerStruct() -> InnerStruct { return InnerStruct(); }

  public class InnerClass {
    public static func makeOuter() -> OuterStruct { return OuterStruct(); }
    public static func makeInner() -> InnerClass { return InnerClass(); }
  }

  public struct InnerStruct {
    public static func makeOuter() -> OuterStruct { return OuterStruct(); }
    public static func makeInner() -> InnerStruct { return InnerStruct(); }
  }

  public func makeOther() -> OuterClass.InnerClass {
    return OuterClass.InnerClass();
  }
}
