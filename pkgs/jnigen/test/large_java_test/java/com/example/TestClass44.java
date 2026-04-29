package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.field, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.none, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.long_
public sealed interface TestClass44<T extends Number>  {
  long myField = 0;
  public enum NestedEnum { V1 }

  public static final class Sub<T extends Number> implements TestClass44<T> {}
}
