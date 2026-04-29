package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.none, MemberModifier: MemberModifier.throws, MemberName: MemberName.isFoo, NestedKind: NestedKind.staticClass, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.final_, TypeKind: TypeKind.typeParam
public final class TestClass4<T>  implements Runnable, Cloneable {
  public void run() {}
  public T isFoo(T p1) throws Exception { return null; }
  public static class Nested {}

}
