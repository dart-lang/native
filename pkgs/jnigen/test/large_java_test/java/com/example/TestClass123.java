package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.any, NestedKind: NestedKind.record, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.final_, TypeKind: TypeKind.boolean_
public final class TestClass123<T>  implements Runnable, Cloneable {
  public void run() {}
  public synchronized <S, V> boolean[] myMethod(boolean[] p1, int p2) { return null; }
  public static record NestedRecord(int x) {}

}
