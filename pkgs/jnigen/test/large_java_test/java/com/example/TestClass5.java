package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.static_, MemberName: MemberName.isFoo, NestedKind: NestedKind.staticClass, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.final_, TypeKind: TypeKind.double_
public final class TestClass5<T>  implements Runnable, Cloneable {
  public void run() {}
  public static <S extends Number> double isFoo(double p1) { return 0.0; }
  public static class Nested {}

}
