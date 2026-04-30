package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.none, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.throws, MemberName: MemberName.any, NestedKind: NestedKind.innerClass, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.sealed, TypeKind: TypeKind.int_
public sealed class TestClass4<T, U>  {
  public int[] myMethod(int[] p1, int p2) throws Exception { return null; }
  public class Nested {}

  public static final class Sub<T, U> extends TestClass4<T, U> {}
}
