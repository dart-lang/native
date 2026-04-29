package com.example;
import java.util.*;

// Generics: Generics.oneParam, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.upperBound, MemberModifier: MemberModifier.abstract_, MemberName: MemberName.getFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.zero, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.float_
public abstract class TestClass53<T>  implements Runnable, Cloneable {
  public void run() {}
  public abstract <S extends Number> float getFoo();
  public enum NestedEnum { V1 }

}
