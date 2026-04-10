package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.complexDag, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.static_, MemberName: MemberName.isFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customInterface
public class TestClass3<T extends Number>  implements DagA, DagD, DagE {
  public void run() {}
  public static <S> Runnable[] isFoo() { return null; }
  public static interface Nested {}

}
