package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extends_, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.any, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public interface TestClass234<T extends Number>  extends Runnable {
  default <S, V> long myMethod(long p1, int p2) { return 0; }
}
