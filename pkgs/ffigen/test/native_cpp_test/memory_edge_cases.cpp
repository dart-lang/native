// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "memory_edge_cases.h"

Node::Node(int value, int* destructorCounter)
    : value_(value), destructorCounter_(destructorCounter) {}

Node::~Node() {
    if (destructorCounter_ != nullptr) {
        (*destructorCounter_)++;
    }
}

int Node::getValue() const { return value_; }
