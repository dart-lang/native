# Native Doc Dartifier

## Introduction
Experimental tool that uses JNIgen and Gemini to translate native code to equivalent Dart code.

Facilitate the integration of native code examples, such as those found in Android documentation (Java/Kotlin), into Dart and Flutter projects.

It leverages JNIgen to generate Java Native Interface (JNI) bindings, and employs Gemini to translate native code snippets into equivalent Dart code that utilizes these bindings. This automation streamlines the process of adapting native code examples for use within the Dart ecosystem, reducing the manual effort and complexity.

## Example

Here's a simple example Java snippet from the Android docs.
```java
public void onClick() {
    ImageCapture.OutputFileOptions outputFileOptions =
            new ImageCapture.OutputFileOptions.Builder(new File(...)).build();
    imageCapture.takePicture(outputFileOptions, cameraExecutor,
        new ImageCapture.OnImageSavedCallback() {
            @Override
            public void onImageSaved(ImageCapture.OutputFileResults outputFileResults) {
                // insert your code here.
            }
            @Override
            public void onError(ImageCaptureException error) {
                // insert your code here.
            }
       }
    );
}
```

This produces the following Dart equivalent code that uses JNI bindings:
```dart
void onClick() {
  final ImageCapture_OutputFileOptions outputFileOptions =
      ImageCapture_OutputFileOptions_Builder(File("...".toJString())).build();

  imageCapture.takePicture$1(outputFileOptions, cameraExecutor,
      ImageCapture_OnImageSavedCallback.implement(
          $ImageCapture_OnImageSavedCallback(
        onImageSaved: (ImageCapture_OutputFileResults outputFileResults) {
          // insert your code here.
        },
        onError: (ImageCaptureException error) {
          // insert your code here.
        }
      )));
}
```
