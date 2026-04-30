package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.interface, ParamCount: ParamCount.one, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customObject
public abstract interface TestClass96<T>  extends Runnable, Cloneable {
  <S extends Number> ArrayList<S>[] getFoo(ArrayList<S>[] p1);
  public static interface Nested {}

}
