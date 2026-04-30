package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.implements_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customInterface
public interface TestClass144<T extends Number>  extends Cloneable {
  default <S> Runnable myMethod(Runnable p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
