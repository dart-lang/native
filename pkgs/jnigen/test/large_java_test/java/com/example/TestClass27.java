package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.extends_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.static_, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customInterface
public interface TestClass27<T, U>  extends Runnable {
  static <S extends Number> Runnable getFoo(Runnable p1) { return null; }
  public static record NestedRecord(int x) {}

}
