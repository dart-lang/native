package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extends_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.map
public interface TestClass28<T extends Number>  extends Runnable {
  Map<T, T> getFoo(Map<T, T> p1);
  public static record NestedRecord(int x) {}

}
