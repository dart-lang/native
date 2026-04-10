package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extends_, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.synchronized, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customObject
public interface TestClass15<T extends Number>  extends Runnable {
  <S extends Number> ArrayList<S>[] getFoo(ArrayList<S>[] p1, int p2);
  public static interface Nested {}

}
