# Errors in FFIgen

This file documents various errors and their potential fixes related to FFIgen.

## Errors in source header files

FFIgen uses libclang to parse header files. Any compiler warnings/errors should be logged (with SEVERE level).
Compiler errors and warnings should be resolved as they can potentially generate invalid bindings that might cause silent errors and crashes at runtime.

> You can pass in args to libclang using  `compiler-opts` via cmd line or yaml config or both.

Here we'll list some common usecases. You can find the full list of [supported args here](https://clang.llvm.org/docs/ClangCommandLineReference.html#id5).

### Missing headers

These are the most common source file errors. You can specify [include paths to clang](https://clang.llvm.org/docs/ClangCommandLineReference.html#id6) like this 
```yaml
compiler-opts:
  - "-I/path/to/folder"
```

### Ignoring source errors

As a last resort, you can pass in `--ignore-source-errors` or set `ignore-source-errors: true` in yaml config.

**Warning: This will likely lead to incorrect bindings!**

## Errors in Objective-C bindings

### Method not defined

ObjC's method naming is a bit different to Dart's. For example, `NSString` has
a method `stringWithCharacters:length:`. To make invocation feel as similar to
ObjC as possible, we generate this as a method named `stringWithCharacters`,
with a named required parameter called `length`.

So one reason you might be having trouble invoking the method is that this
naming convention is different to ObjC. The generated methods have a comment
giving their full ObjC name, so you can try searching for that string to find
the corresponding Dart method.

Since Dart doesn't support method overloading, the method may have been renamed
to avoid collisions. Again the best approach is to search for the ObjC method
name.

When FFIgen generates bindings for an ObjC interface, eg `Foo`, it generates a
Dart class `Foo`, which contains the constructor and static methods. The
instance methods are generated in an extension, `Foo$Methods`.

So if you've searched for the generated method and found it, and still can't
invoke it, it's possible that you've imported the class, `Foo`, but not the
extension `Foo$Methods`. This can happen if you're using `show`/`hide` when you
import the bindings. Make sure to import both `Foo` and `Foo$Methods`.
