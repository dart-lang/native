## 1.1.0-wip

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
