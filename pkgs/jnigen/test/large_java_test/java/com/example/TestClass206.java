package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.any, NestedKind: NestedKind.enum_, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.customEnum
public sealed class TestClass206<T extends Number>  {
  public synchronized CustomEnum myMethod(CustomEnum p1) { return null; }
  public enum NestedEnum { V1 }

  public static final class Sub<T extends Number> extends TestClass206<T> {}
}
