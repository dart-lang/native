package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.list
public interface TestClass194<T, U>  extends DiamondLeft, DiamondRight {
  <S, V> List<S> getFoo(List<S> p1);
}
