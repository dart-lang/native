# Linking Issues with Native Assets

This document describes common linking issues that can occur when using native
assets in Dart and provides workarounds.

## Conflicting with Embedder Library Dependencies

When a native asset provides a library that is also a dependency of the
embedder, you may encounter runtime crashes. This is because the symbols from
the already-loaded library can conflict with the symbols from the native asset. 

This can happen, for example, when using a hook that bundles sqlite3 hook in a
Flutter application on Linux. The Flutter embedder already depends on
`libsqlite3.so`, so when the Dart code tries to load the `sqlite3` native asset,
the dynamic linker can get confused and resolve symbols to the wrong library,
leading to a crash.

This issue only happens on Linux, as the other OSes use some kind of namespacing
for symbols by default. On Linux, trying to use namespacing leads to issues with
using sanitizers, so on Linux Dart and Flutter do not enable namespacing. See
[GitHub issue #2724](https://github.com/dart-lang/native/issues/2724) for more
details.

### Workaround 1: Symbol Prefixing

Create a wrapper library that statically links the conflicting library (e.g.,
SQLite) and re-exposes its symbols with a unique prefix. This avoids name
collisions with the library loaded by the embedder.

If your library enables end-users to load either a custom native library or one
from the operating system, you can design the wrapper to dynamically link
against that library while still re-exposing the symbols with a prefix. This
prevents having to duplicate the `@Native` bindings for supporting that
user-define.

### Workaround 2: Symbol Versioning and Export Maps

Use `ffigen` to generate a list of symbols that need to be accessed from
Dart. Then, use the `-Wl,--version-script=` linker flag with a script that
marks only those necessary symbols as global and all others as local. This
reduces the list of symbols that could conflict with the embedder. If one of the
required symbols clashes with the embedder, this method doesn't work.

### Workaround 3: `-Bsymbolic` Linker Flag

Adding `DF_SYMBOLIC` as an ELF dynamic entry via the `-Wl,-Bsymbolic` linker
flag can resolve conflicts within a single dynamic library. This flag tells
the dynamic linker to resolve symbol references within the library first,
before searching in other libraries. This is similar in effect to using the
`RTLD_DEEPBIND` flag with `dlopen`. 
