[![Build Status](https://github.com/dart-lang/native/actions/workflows/objective_c.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/objective_c.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/objective_c.svg)](https://pub.dev/packages/objective_c)
[![package publisher](https://img.shields.io/pub/publisher/objective_c.svg)](https://pub.dev/packages/objective_c/publisher)

# objective_c

A library to access Objective C from Flutter that acts as a support library for
package:ffigen.

This library isn't very useful on its own. Typically it is used while
interoperating with an Objective C library created by package:ffigen. See
https://pub.dev/packages/ffigen

For general information about interop with Objective C, see
https://dart.dev/guides/libraries/objective-c-interop

## Memory management

Objective C and Dart use different styles of memory management. Dart is garbage
collected, while Objective C uses reference counting. This difference is a
common cause of bugs when interoperating between the two languages.

Memory management issues typically manifest as seg faults, which can be hard to
debug as they often have no useful stack trace. The most common issue is use
after free errors, where a Dart object is constructed to wrap an Objective C
object that has already been destroyed. To debug these issues, try running your
program with [asserts enabled](https://dart.dev/language/error-handling#assert).
When the Dart wrapper object is created or destroyed, an assert checks that the
Objective C object still exists, which should provide a much more useful stack
trace.

References are automatically retained when the Dart wrapper object is
created, and released when the Dart object is garbage collected. But to fix a
reference counting issue, it may occasionally be necessary to manually control
the ref count. The ref count of the Objective C object can be controlled from
Dart by the `retain` and `release` options in the Dart wrapper object
constructors, and by the `retainAndReturnPointer()` and `release()` methods.
