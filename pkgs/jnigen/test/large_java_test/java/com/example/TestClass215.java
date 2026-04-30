package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.none, IsArray: IsArray.no, Member: Member.field, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.transient, MemberName: MemberName.any, NestedKind: NestedKind.innerClass, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.typeParam
public sealed class TestClass215<T extends Number>  {
  public transient T myField;
  public class Nested {}

  public static final class Sub<T extends Number> extends TestClass215<T> {}
}
