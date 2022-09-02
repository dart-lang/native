## Running
After generating `pdfbox_plugin` bindings in the parent directory

* setup native libraries: `dart run jni:setup && dart run jni:setup -p pdfbox_plugin`

* `dart run bin/pdf_info.dart <Path_to_PDF_File>`

Alternatively, it's possible to compile `bin/pdf_info.dart` and then run it.

To run it from other directories, the `helperDir` and `classpath` parameters in `Jni.spawn` call should be adjusted appropriately.
