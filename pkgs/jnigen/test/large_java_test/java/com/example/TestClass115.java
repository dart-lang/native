package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.diamond, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.float_
public interface TestClass115<T extends Number>  extends DiamondLeft, DiamondRight {
  default <S, V> float getFoo(float p1, int p2) { return 0.0f; }
  public enum NestedEnum { V1 }

}
