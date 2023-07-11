[![dart](https://github.com/dart-lang/native/actions/workflows/dart.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/dart.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)

## Overview

This repository is home to Dart packages related to FFI and native assets
building and bundling.

## Packages

| Package                                      | Description                                                                                 | Version |
| -------------------------------------------- | ------------------------------------------------------------------------------------------- | ------- |
| [c_compiler](pkgs/c_compiler/)               | A library to invoke the native C compiler installed on the host machine.                    |         |
| [native_assets_builder](pkgs/native_assets_builder/) | A library that contains the logic for building native assets. This should not be used by users, and is used as shared implementation between dartdev and flutter_tools. |         |
| [native_assets_cli](pkgs/native_assets_cli/) | A library that contains the argument and file formats for implementing a native assets CLI. |         |

<!-- ## Publishing automation

For information about our publishing automation and release process, see
https://github.com/dart-lang/ecosystem/wiki/Publishing-automation.

For additional information about contributing, see our
[contributing](CONTRIBUTING.md) page. -->
