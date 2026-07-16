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

}
