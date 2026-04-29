package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.implements_, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.setFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.map
public abstract class TestClass3<T extends Number>  implements Runnable {
  public void run() {}
  public abstract <S extends Number> Map<S, S>[] setFoo();
}
