// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <memory>

// Classes whose own member signatures refer back to them. Parsing one of these
// re-enters the class parser for a class that is still being parsed, so the
// parser must recognize the class it is already working on instead of
// recursing until the stack is exhausted.

// Self-reference through a return type.
class Node {
 public:
  virtual ~Node() = default;
  virtual Node* clone() = 0;
};

// Self-reference through a parameter type.
class Merger {
 public:
  virtual void merge(Merger* other) = 0;
};

// Self-reference through a smart pointer return type.
class Owner {
 public:
  virtual std::unique_ptr<Owner> take() = 0;
};

// Mutual recursion between two classes.
class Branch;

class Leaf {
 public:
  virtual Branch* parent() = 0;
};

class Branch {
 public:
  virtual Leaf* firstLeaf() = 0;
};

Node* node_create(void);
Merger* merger_create(void);
Owner* owner_create(void);
Leaf* leaf_create(void);
Branch* branch_create(void);
