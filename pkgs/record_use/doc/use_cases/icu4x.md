# Icu4x record_use

This is a rust library, and the goal is to tree-shake native code if symbols are
not reachable from Dart code to cut down binary size from ~40MB to a couple of
MBs.

## Information needed for tree-shaking

The native symbols that are reachable:

```dart
@ffi.Native<ffi.Pointer<ffi.Void> Function(ffi.Size, ffi.Size)>(
  symbol: 'diplomat_alloc',
  isLeaf: true,
)
external ffi.Pointer<ffi.Void> _diplomat_alloc(int len, int align);
```
([[source](https://github.com/unicode-org/icu4x/blob/e5a29a7d591157e8906bbd3f00021f164031f7cd/ffi/dart/lib/src/bindings/lib.g.dart#L237C1-L237C68))


The link hook needs to know `diplomat_alloc` is reachable or not.

This can be achieved by knowing whether the static function `_diplomat_alloc` is reachable.

### Mapping Dart identifiers to native identifiers

The file containing the external static functions is a generated file.

The link hook could import a generated file that contains the mapping:

```dart
const dartStaticCallToNativeSymbol = {
    'diplomat_alloc': '_diplomat_alloc',
    // ...
};
```

## Links

* https://pub.dev/packages/icu4x
