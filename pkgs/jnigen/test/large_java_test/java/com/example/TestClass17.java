package com.example;
import java.util.*;

// Generics: Generics.twoParams, Inheritance: Inheritance.multipleImplements, IsArray: IsArray.no, Member: Member.method, MemberGenerics: MemberGenerics.twoParams, MemberModifier: MemberModifier.native, MemberName: MemberName.isFoo, NestedKind: NestedKind.enum_, ParamCount: ParamCount.two, TopLevelKind: TopLevelKind.class_, TopLevelModifier: TopLevelModifier.none, TypeKind: TypeKind.customObject
public class TestClass17<T, U>  implements Runnable, Cloneable {
  public void run() {}
  public native <S, V> ArrayList<S> isFoo(ArrayList<S> p1, int p2);
  public enum NestedEnum { V1 }

}
