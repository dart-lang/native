# pdfbox_plugin_example

Demonstrates how to use the PDFBox bindings generated using `jni_gen`. This is a Linux Flutter application. The sample application lists the PDF files in a directory with number of pages and title, also allowing to navigate between directories.

First, it's required to have generated the dart and C bindings in the plugin directory, which also downloads the required JARs using maven. The bindings are not committed because generated code is several thousands of lines.

On a Linux machine, following commands can be used to run the example application.

```
cd .. ## From this folder
dart run jni_gen --config jnigen.yaml ## Downloads PDFBox JARs and generates bindings.
cd example/
flutter run --release ## Opens the files list from home directory
```

It may take some time for PDFBox to process all PDFs in a directory. In the interest of simplicity, this example application displays the list after all PDFs are processed.

Follow along the code in `lib/main.dart` to see how generated bindings are used.
