package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.implements_, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.setFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.long_
public abstract class TestClass5<T>  implements Runnable {
  public void run() {}
  public abstract <S> long[] setFoo(long[] p1, int p2);
  public static record NestedRecord(int x) {}

}
