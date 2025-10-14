# 3 Layers in Dart Interop

Dart native interop can be structured into three layers:
* Low level interop
* Dart-y API
* SDK-tailoring


## Layer 1: Low level interop

The goal of this layer is to provide a no-compromise, high-performance layer to
make non-Dart APIs and libraries accessible from Dart. This layer is designed to
be unopinionated, allowing threading, data transfer, and isolate life cycle to
be built upon it. The APIs provided and generated are very thin Dart wrappers
around the native APIs. They favor zero-cost abstractions such as extension types.
While using this layer directly offers the most possibilities, it can lead to
writing creole and presents footguns regarding memory management, threading, and
the isolate and VM life cycle.

**Technologies in this layer:**
* Low-level SDK libraries for calling native code, such as [`dart:ffi`][dart-ffi] and
  [`dart:js_interop`][dart-js-interop].
* Code generators such as [FFIgen][ffigen], [JNIgen][jnigen], and web_generator.

**Design principles for tech in this layer:**
* Performance comes first, usability second.
* It is either implemented as a compiler backend or as a code generator built on
  top of one.
* Zero-configuration should be used if possible. The generator technologies do
  not know how their code will be used, so it's preferable to generate code that
  permits multiple usage patterns.

## Layer 2: Dart-y API

The objective of this layer is to offer a Dart-y API that bridges the impedance
mismatch between Dart and the target language. Technologies in this layer are
opinionated and may make domain-specific choices about value conversions
(shallow or deep), concurrency models, etc.. They might sacrifice performance
for improved usability and may provide adapters for implementing Dart types such
as `Map` and `List`.

**Technologies in this layer:**
* Hand-written Dart wrappers around a layer 1 API for C libraries, such as
  [SQLite3][sqlite3].
* [Pigeon][pigeon], which decides on a full serialization and concurrency model.

**Design principles for tech in this layer:**
* APIs should have the feel of Dart APIs. No layer 1 types should be exposed,
  and Effective Dart guidelines should be followed.
* Users should not need to worry about the underlying native code. Native
  finalizers should be used to free resources.
* APIs should be structured to work with Dart's threading and isolate life
  cycle.
* This layer is typically hand-crafted or built with a generator that has a high
  degree of configuration fidelity.
* If different platforms offer non-identical feature sets, the preference is to
  publish platform-specific Dart APIs as packages and then build a
  platform-agnostic package on top of them.

## Layer 3: SDK-tailoring (optional)

This layer's purpose is to provide integration with specific SDKs built on Dart.
This layer is optional. If a solution can be provided as a layer 2 solution, it
should be, as this makes it reusable across multiple SDKs.

**Technologies in this layer:**
* Flutter Plugin API: Provides access to Flutter-defined elements such as App
  lifecycle, Android Context, etc.
* Flutter Plugins: These can, for example, hide the Android Context from the API
  they expose to a Dart developer.

## Cross-layer design principles

Layer 2 solutions have the option to provide "native escape hatches" to layer 1.
This allows layer 1 to give immediate access to new OS APIs while layer 2 is
being updated.

[dart-ffi]: https://api.dart.dev/dart-ffi/
[dart-js-interop]: https://api.dart.dev/dart-js_interop/
[ffigen]: ../pkgs/ffigen/
[jnigen]: ../pkgs/jnigen/
[pigeon]: https://pub.dev/packages/pigeon
[sqlite3]: https://pub.dev/packages/sqlite3
