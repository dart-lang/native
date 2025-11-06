# Objective C example

This example shows how to use FFIgen to generate bindings for an Objective C
library. It uses the AVFAudio framework to play audio files.

```
dart play_audio.dart test.mp3
```

## Config notes

The FFIgen config for an Objective C library looks very similar to a C library.
The most important difference is that you must set `FfiGenerator.objectiveC`.
If you want to filter which interfaces are included you can use the
`FfiGenerator.objectiveC.interfaces` option.
This works similarly to the other filtering options.

It is recommended that you filter out just about everything you're not
interested in binding (see the FFIgen config in [pubspec.yaml](./pubspec.yaml)).
Virtually all Objective C libraries depend on Apple's internal libraries, which
are huge. Filtering can reduce the generated bindings from millions of lines to
thousands.

In this example, we're only interested in `AVAudioPlayer`, so we've filtered out
everything else. FFIgen will automatically pull in anything referenced by
any of the fields or methods of `AVAudioPlayer`, but by default they're
generated as stubs. To generate full bindings for the transient dependencies,
add them to your include set, or set `Interfaces.includeTransitive` to `true`.

## Generating bindings

At the root of this example (`example/objective_c`), run:

```
dart run generate_code.dart
```

This will generate [avf_audio_bindings.dart](./avf_audio_bindings.dart).
