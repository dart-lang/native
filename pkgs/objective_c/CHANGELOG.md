## 4.0.0-wip

- Use ffigen 16.0.0
- Add `NSOrderedCollectionDifference` to the package.

## 3.0.0

- Add the following stream-related types to the core package:
  - `NSInputStream`
  - `NSOutputStream`
  - `NSRunLoop`
  - `NSStream`
  - `NSStreamDelegate`
  - `NSStreamEvent`
  - `NSStreamStatus`
- Add `UnimplementedOptionalMethodException`, which is thrown by the ObjC
  bindings if an optional method is invoked, and the instance doesn't implement
  the method.
- Dispatch all object/block releases to the main thread.
- Add utils for converting Dart `String`s to Objective-C selectors and back.
- Require Dart 3.4 or later (due to the use of `dart:ffi`
  `Struct.create` by `package:ffigen`).
- __Breaking change__: Return structs from ObjC methods by value instead of
  taking a struct return pointer.

## 2.0.0

- Drop API methods that are deprecated in the oldest versions of iOS and macOS
  that flutter supports.
- Added `ObjCBlock`, which is the new user-facing representation of ObjC blocks.
- Migrate to ARC (Automatic Reference Counting).
- Enable ObjC objects and blocks to be sent between isolates.
- Add `autorelease` and `retainAndAutorelease` methods to ObjC objects and
  blocks.
- __Breaking change__: Remove some convenience methods from `_ObjCRefHolder`:
  `isReleased`, `release`, `pointer`, and `retainAndReturnPointer`. Uses of
  these methods now need to go through `.ref`. Eg `obj.pointer` becomes
  `obj.ref.pointer`.

## 1.1.0

- Add `DartProxy`, which is an implementation of `NSProxy` that enables
  implementing ObjC protocols from Dart. Also adds `DartProxyBuilder` for
  constructing `DartProxy`.
- Add some extensions methods for `NSMutableData`.
- Fix the `NSError` bindings so that they're not empty.
- Add `ObjCProtocolBuilder`, which is an ergonomic wrapper around
  `DartProxyBuilder`.
- Add `ObjCProtocolMethod`, which contains all the information that
  `ObjCProtocolBuilder` needs to implement a method. These objects are created
  by the ffigen bindings for a protocol.
- Make all of the code-genned structs and enums public so they can be reused by
  user bindings.
- Use `package:dart_flutter_team_lints`.

## 1.0.1

- Mention experimental status in readme.

## 1.0.0

- Move sharable code from ffigen's generated code into this package, including
  `ObjCObjectBase`, and `ObjCBlockBase`, as well as the core Objective C runtime
  functions (except `objc_msgSend`, which is library specific).
- Move core ObjC classes such as `NSString` into this package.
- Delete Dart functions associated with ObjC closure blocks when the block is
  destroyed. Fixes https://github.com/dart-lang/native/issues/204
- Improve debuggability of memory management errors.
