package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.any, NestedKind: NestedKind.staticClass, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.short_
public abstract class TestClass99<T>  implements Runnable, Cloneable {
  public void run() {}
  public abstract <S> short myMethod(short p1, int p2);
  public static class Nested {}

}
