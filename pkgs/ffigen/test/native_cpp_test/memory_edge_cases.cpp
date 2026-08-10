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

NodeManager::NodeManager() {}

int NodeManager::foo(Node* node) {
    return node->getValue();
}

Node* NodeManager::getNode(int value, int* destructorCounter) {
    return new Node(value, destructorCounter);
}


Node* NodeManager::newNode(int value, int* destructorCounter) {
    return new Node(value, destructorCounter);
}

static Node* gSingletonNode = nullptr;

Node* NodeManager::getSingletonNode(int value, int* destructorCounter) {
    if (gSingletonNode == nullptr) {
        gSingletonNode = new Node(value, destructorCounter);
    }
    return gSingletonNode;
}

int NodeManager::getValue(Node* node) {
    return node->getValue();
}

int NodeManager::takeNode(Node* node) {
    int val = node->getValue();
    delete node;
    return val;
}
