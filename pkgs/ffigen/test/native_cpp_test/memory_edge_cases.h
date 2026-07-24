// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Node {
public:
    Node(int value, int* destructorCounter);
    ~Node();

    int getValue() const;

private:
    int value_;
    int* destructorCounter_;
};

class NodeManager {
public:
    NodeManager();
    int foo(Node* node);
    Node* getNode(int value, int* destructorCounter);
    Node* newNode(int value, int* destructorCounter);
    Node* getSingletonNode(int value, int* destructorCounter);
    int getValue(Node* node);
    int takeNode(Node* node);
};

