package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.none, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.nestedCustom
public class TestClass129<T extends Number>  implements Runnable, Cloneable {
  public void run() {}
  public <S extends Number> Map.Entry<S, S>[] getFoo() { return null; }
  public static interface Nested {}

}
