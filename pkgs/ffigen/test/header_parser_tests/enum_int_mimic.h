// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include<stdint.h>

enum Simple {
    A0,
    A1,
};

enum SimpleWithNegative {
    B0,
    B1=-1000,
};

enum ExplicitType : int16_t {
    E0,
    E1,
};

struct Test {
    enum Simple simple;
    enum SimpleWithNegative *simpleWithNegative;
    enum ExplicitType explicitType[5];

    enum {ANONYMOUS1} simpleWithAnonymousEnum;
    enum {ANONYMOUS2=-1000} simpleNegativeWithAnonymousEnum;
    enum : int8_t {ANONYMOUS3} explicitTypeWithAnonymousEnum;
};