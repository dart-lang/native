package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extends_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customInterface
public interface TestClass224<T extends Number>  extends Runnable {
  default <S, V> Runnable myMethod(Runnable p1, int p2) { return null; }
}
