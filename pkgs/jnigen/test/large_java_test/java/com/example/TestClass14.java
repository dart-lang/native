package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extends_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.set
public interface TestClass14<T, U>  extends Runnable {
  default Set<T> myMethod(Set<T> p1) { return null; }
  public static record NestedRecord(int x) {}

}
