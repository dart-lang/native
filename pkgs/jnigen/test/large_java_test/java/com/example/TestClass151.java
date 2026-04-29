package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.record, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.short_
public abstract class TestClass151<T, U>  implements Runnable, Cloneable {
  public void run() {}
  public abstract <S, V> short[] getFoo();
  public static record NestedRecord(int x) {}

}
