package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extends_, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public interface TestClass109<T, U>  extends Runnable {
  default <S> long[] myMethod(long[] p1, int p2) { return null; }
  public static interface Nested {}

}
