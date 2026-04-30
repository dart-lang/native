package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.native, MemberName: MemberName.isFoo, NestedKind: NestedKind.innerClass, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.typeParam
public sealed class TestClass169<T extends Number>  {
  public native T[] isFoo(T[] p1);
  public class Nested {}

  public static final class Sub<T extends Number> extends TestClass169<T> {}
}
