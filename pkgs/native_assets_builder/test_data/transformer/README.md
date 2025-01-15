An example of a library that transforms some source files and bundles them as
data assets.

## Usage

Data assets are not yet consumable in Dart and Flutter.
This package is for illustration purposes only.

## Code organization

A typical layout of a package with data assets:

* `data/` contains source files.
* `hook/build.dart` loops over all these files and transforms them. It reports
  the transformed files as data assets. The file transformations are cached
  within the hook to prevent retransforming the files if the sources didn't
  change.
