# Differences between Dart compilers

The various Dart compilers and compilation modes have different optimizations.
This can lead to differences in the recorded API usage between compilers.

## Compiler Optimizations

The following compiler optimizations can influence the recorded API usage:

*   **Tree-shaking / Dead code elimination:** Code that is not used is removed
    from the compiled output. If an API is only used in code that is
    tree-shaken, the API usage will not be recorded. The compilers have
    different levels of sophistication in their tree-shaking algorithms. For
    example, `dart compile exe` might tree-shake a call, while `dart2js` might
    not.
*   **Constant propagation and inlining:** Constant propagation and inlining of
    other code might lead to `record-use` annotated API calls receiving more
    constant arguments or being promoted to static calls. These optimizations
    might also lead to tearoffs being promoted to static calls or const values
    showing up for call sites that were propagated there by the compiler. (The
    record-use annotated API itself should not be optimized away by inlining
    or constant propagation. The compilers preserve such APIs.)
*   **Other optimizations:** Other optimizations that can affect the recorded
    API usage include type inference and propagation, loop optimizations, and
    `late` variable initialization.

## Recommendations for Accurate Recording with `package:record_use`

The `package:record_use` library records API usage by analyzing the compiled
output of a program. This means that the recorded API usage can vary depending
on the compiler and compilation mode that is used. To ensure more accurate and
consistent recording, consider the following recommendations:

*   **`@mustBeConst` annotation:** When designing APIs that are intended for
    analysis by `package:record_use`, consider using the `@mustBeConst`
    annotation on parameters. This annotation forces call sites to provide
    *obviously constant* arguments, which compilers are more likely to treat
    consistently across different optimization levels.
*   **Warning for non-constant or dynamic calls:** To improve the accuracy and
    reliability of `package:record_use` reports, consider adding a warning
    mechanism within the tool's analysis (e.g., in a "link hook"). This warning
    would trigger if any API calls are found with non-constant arguments,
    dynamic calls, or tear-offs. These constructs can lead to inconsistent
    reporting across compilers due to varying optimization strategies.
