
#include "base.h"

struct A_Struct1{
    int a;
};

union A_Union1{
    int a;
};

enum A_Enum{
    A_ENUM_1,
    A_ENUM_2,
};

#define A_MACRO_1 1;

void a_func1();

void a_func2(struct BaseStruct2 s, union BaseUnion2 u, BaseTypedef2 t);

void a_func3(BaseNativeTypedef1 i);

void a_func4(BaseNativeTypedef2 i);

void a_func5(BaseNativeTypedef3 i);

