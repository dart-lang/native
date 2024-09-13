import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'ns_data.dart';
import 'ns_string.dart';
import 'objective_c_bindings_generated.dart';

extension NSInputStreamStreamExtension on Stream<List<int>> {
  /// Return a [NSInputStream] that, when read, will contain the contents of
  /// the [Stream].
  ///
  /// > [!IMPORTANT]
  /// > [NSInputStream.read_maxLength_] must called called from a different
  /// > thread or [Isolate] than the one that calls [toNSInputStream].
  /// > Otherwise, [NSInputStream.read_maxLength_] will deadlock waiting for
  /// > data to be added from the [Stream].
  NSInputStream toNSInputStream() {
    // Eagerly add data until `maxReadAheadSize` is buffered.
    const maxReadAheadSize = 4096;

    final port = ReceivePort();
    final inputStream =
        DartInputStreamAdapter.inputStreamWithPort_(port.sendPort.nativePort);
    late final StreamSubscription<dynamic> dataSubscription;

    dataSubscription = listen((data) {
      if (inputStream.addData_(data.toNSData()) > maxReadAheadSize) {
        dataSubscription.pause();
      }
    }, onError: (Object e) {
      final d = NSMutableDictionary.new1();
      d.setObject_forKey_(e.toString().toNSString(), NSLocalizedDescriptionKey);
      inputStream.setError_(NSError.errorWithDomain_code_userInfo_(
          'DartError'.toNSString(), 0, d));
    }, onDone: inputStream.setDone, cancelOnError: true);

    dataSubscription.pause();
    port.listen((count) {
      if (count == -1) {
        dataSubscription.cancel();
        port.close();
      } else {
        dataSubscription.resume();
      }
    }, onDone: dataSubscription.cancel);

    return inputStream;
  }
}
