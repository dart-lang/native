package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.diamond, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.isFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.memberTypeParam
public class TestClass169<T, U>  implements DiamondLeft, DiamondRight {
  public void run() {}
  public synchronized <S, V> S[] isFoo(S[] p1, int p2) { return null; }
}
