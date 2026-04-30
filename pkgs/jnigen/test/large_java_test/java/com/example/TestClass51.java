package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.none, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.final_, TypeKind: TypeKind.typeParam
public final class TestClass51<T extends Number>  implements Runnable, Cloneable {
  public void run() {}
  public synchronized <S extends Number> T getFoo(T p1) { return null; }
}
