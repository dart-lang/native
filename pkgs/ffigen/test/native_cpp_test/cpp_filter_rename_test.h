// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test header for filtering and renaming C++ classes and methods.

// This class will be included, and its Dart name will be renamed to 'MyWidget'.
class MyClass {
public:
    // This method will be included (renamed to 'greet').
    void myMethod() {}
    // This method will be filtered out via visitor filter.
    void filteredMethod() {}
};

// This class will be included unchanged.
class OtherClass {
public:
    void method() {}
};

// This class will be excluded via the include filter.
class FilteredOutClass {
public:
    void unused() {}
};
