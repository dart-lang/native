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
  /// > [NSInputStream.read_maxLength_] must be called from a different thread
  /// > or [Isolate] than the one that calls [toNSInputStream]. Otherwise,
  /// > [NSInputStream.read_maxLength_] will deadlock waiting for data to be
  /// > added from the [Stream].
  NSInputStream toNSInputStream() {
    // Eagerly add data until `maxReadAheadSize` is buffered.
    const maxReadAheadSize = 4096;

    final port = ReceivePort();
    final inputStream =
        DartInputStreamAdapter.inputStreamWithPort_(port.sendPort.nativePort);
    late final StreamSubscription<dynamic> dataSubscription;

    print('Here1');
    dataSubscription = listen((data) {
      print('data: $data');
      if (inputStream.addData_(data.toNSData()) > maxReadAheadSize) {
        print('pause');
        dataSubscription.pause();
      }
    }, onError: (Object e) {
      print('error');
      final d = NSMutableDictionary.new1();
      d.setObject_forKey_(e.toString().toNSString(), NSLocalizedDescriptionKey);
      inputStream.setError_(NSError.errorWithDomain_code_userInfo_(
          'DartError'.toNSString(), 0, d));
    }, onDone: () {
      inputStream.setDone();
      print('Stream done');
    }, cancelOnError: true);

    dataSubscription.pause();
    port.listen((count) {
      print('count: $count');
      // -1 indicates that the `NSInputStream` is closed. All other values
      // indicate that the `NSInputStream` needs more data.
      if (count == -1) {
        dataSubscription.cancel();
        port.close();
      } else {
        print('Resuming');
        dataSubscription.resume();
      }
    }, onDone: () {
      dataSubscription.cancel();
      print('port done');
    });

    return inputStream;
  }
}
