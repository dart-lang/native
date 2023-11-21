# Errors in ffigen

This file documents various errors and their potential fixes related to ffigen.

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
