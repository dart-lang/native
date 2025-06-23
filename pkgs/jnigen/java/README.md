## ApiSummarizer

An early version of ApiSummarizer.

It analyzes java source code / jars and outputs a JSON representation of the public API.

It's currently used in `jnigen` to get the information of the Java API.

## Build

When using it via `jnigen`, the `jnigen:setup` script will take care of building the jar in appropriate location.

To build the jar manually, run `gradlew(.bat) buildFatJar` in project root. The jar will be created in `build/libs`
directory.

## Command line

```
usage: java -jar <JAR> [-s <SOURCE_DIR=.>] [-c <CLASSES_JAR>]
<CLASS_OR_PACKAGE_NAMES>
Class or package names should be fully qualified.

-b,--backend <arg>        backend to use for summary generation ('doclet'
or 'asm').
-c,--classes <arg>        paths to search for compiled classes
-D,--doctool-args <arg>   Arguments to pass to the documentation tool
-M,--use-modules          use Java modules
-m,--module-names <arg>   comma separated list of module names
-r,--recursive            Include dependencies of classes
-s,--sources <arg>        paths to search for source files
-v,--verbose              Enable verbose output
```

Here class or package names are specified as fully qualified names, for example `org.apache.pdfbox.pdmodel.PDDocument` will load `org/apache/pdfbox/pdmodel/PDDocument.java`. It assumes the package naming reflects directory structure. If such mapping results in a directory, for example `android.os` is given and a directory `android/os` is found under the source path, it is considered as a package and all Java source files under that directory are loaded recursively.

Note that some options are directly forwarded to the underlying tool.

ApiSummarizer's current use is in `jnigen` for obtaining public API of java packages. Only the features strictly required for that purpose are focused upon.

## Running tests

Run `gradlew(.bat) test`

There are not many tests at the moment. We plan to add some later.

## ASM backend

The main backend is based on javadoc API and generates summary based on java sources. A more experimental ASM backend also exists, and works somewhat okay-ish. It can summarize the compiled JARs. However, compiled jars without debug information do not include method parameter names. Some basic renaming is applied, i.e If type is `Object`, the parameter name will be output as `object` if an actual name is absent.

## TODO

See issue #23.
