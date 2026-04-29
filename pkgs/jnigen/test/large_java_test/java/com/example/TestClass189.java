package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.native, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.object
public interface TestClass189<T extends Number>  extends Runnable, Cloneable {
  <S> Object[] getFoo(Object[] p1, int p2);
  public enum NestedEnum { V1 }

}
