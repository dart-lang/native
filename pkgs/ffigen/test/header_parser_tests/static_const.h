// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <math.h>
#include <stdint.h>

static const int TEST_INT = 10;
static const int TEST_NEGATIVE_INT = -10;
static const double TEST_DOUBLE = 3.14;
static const double TEST_NEGATIVE_DOUBLE = -3.14;

static const int TEST_EXPRESSION = 5 + 5;
static const int TEST_HEX = 0xFF;
static const int TEST_NEGATIVE_HEX = -0xFF;

static const double TEST_INF = INFINITY;
static const double TEST_NEGATIVE_INF = -INFINITY;
static const double TEST_NAN = NAN;

static const char* const TEST_STRING = "test";
static const char* const TEST_STRING_SPECIAL = "$dollar";
static const char* const TEST_STRING_QUOTES = "test's";
static const char* const TEST_STRING_BACKSLASH = "test\\";
static const char* const TEST_STRING_CONTROLS = "hello\n\t\r\v\b";

typedef uint64_t MyFlags;
typedef MyFlags MyBufferUsage;
static const MyBufferUsage MyBufferUsage_None = 0x0000000000000000;
static const MyBufferUsage MyBufferUsage_MapRead = 0x0000000000000001;

// Should be generated as Globals.
static const char TEST_STRING_ARRAY[] = "test_array";
int test_global;
