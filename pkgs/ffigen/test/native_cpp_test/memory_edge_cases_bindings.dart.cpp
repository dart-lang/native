#include "memory_edge_cases.h"

#if defined(_WIN32)
#define FFIGEN_EXPORT __declspec(dllexport)
#else
#define FFIGEN_EXPORT
#endif

extern "C" {

FFIGEN_EXPORT Node* Node_new(int value, int * destructorCounter) {
  return new Node(value, destructorCounter);
}

FFIGEN_EXPORT int Node_getValue(const Node* self) {
  return self->getValue();
}

FFIGEN_EXPORT void Node_delete(Node* self) {
  delete self;
}

FFIGEN_EXPORT NodeManager* NodeManager_new() {
  return new NodeManager();
}

FFIGEN_EXPORT int NodeManager_foo(NodeManager* self, Node* node) {
  return self->foo(node);
}

FFIGEN_EXPORT Node* NodeManager_getNode(NodeManager* self, int value, int * destructorCounter) {
  return self->getNode(value, destructorCounter);
}

FFIGEN_EXPORT Node* NodeManager_newNode(NodeManager* self, int value, int * destructorCounter) {
  return self->newNode(value, destructorCounter);
}

FFIGEN_EXPORT Node* NodeManager_getSingletonNode(NodeManager* self, int value, int * destructorCounter) {
  return self->getSingletonNode(value, destructorCounter);
}

FFIGEN_EXPORT int NodeManager_getValue(NodeManager* self, Node* node) {
  return self->getValue(node);
}

FFIGEN_EXPORT int NodeManager_takeNode(NodeManager* self, Node* node) {
  return self->takeNode(node);
}

FFIGEN_EXPORT void NodeManager_delete(NodeManager* self) {
  delete self;
}

}
