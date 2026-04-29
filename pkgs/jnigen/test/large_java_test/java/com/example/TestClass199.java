package com.example;
import java.util.*;

// Generics: Generics.upperBound, Inheritance: Inheritance.extends_, IsArray: IsArray.yes, Member: Member.method, MemberGenerics: MemberGenerics.oneParam, MemberModifier: MemberModifier.default_, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.interface, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.float_
public interface TestClass199<T extends Number>  extends Runnable {
  default <S> float[] getFoo(float[] p1, int p2) { return null; }
  public enum NestedEnum { V1 }

}
