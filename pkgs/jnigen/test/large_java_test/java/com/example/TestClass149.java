package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public abstract class TestClass149<T, U>  implements Runnable, Cloneable {
  public void run() {}
  public abstract <S, V> Map.Entry<S, S>[] getFoo();
  public static record NestedRecord(int x) {}

}
