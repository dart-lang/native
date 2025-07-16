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
  /// > [NSInputStream.read] must be called from a different thread or [Isolate]
  /// > than the one that calls [toNSInputStream]. Otherwise,
  /// > [NSInputStream.read] will deadlock waiting for data to be added from the
  /// > [Stream].
  NSInputStream toNSInputStream() {
    // Eagerly add data until `maxReadAheadSize` is buffered.
    const maxReadAheadSize = 4096;

    final port = ReceivePort();
    final inputStream = DartInputStreamAdapter.inputStreamWithPort(
      port.sendPort.nativePort,
    );
    //    final weakInputStream =
    //        DOBJCDartInputStreamAdapterWeakHolder.initWithAdapter(inputStream);
    late final StreamSubscription<dynamic> dataSubscription;

    dataSubscription = listen(
      (data) {
        //        final s = DartInputStreamAdapter.castFrom(weakInputStream.adapter);
        /*      if (s.addData(data.toNSData()) > maxReadAheadSize) {
          dataSubscription.pause();
        }*/
      },
      onError: (Object e) {
        //        final s = DartInputStreamAdapter.castFrom(weakInputStream.adapter);
        final d = NSMutableDictionary();
        d[NSLocalizedDescriptionKey] = e.toString().toNSString();
        /*      s.setError(
          NSError.errorWithDomain(
            'DartError'.toNSString(),
            code: 0,
            userInfo: d,
          ),
        );*/
        port.close();
      },
      onDone: () {
        print('dataSubscription.onDone');
        //        final s = DartInputStreamAdapter.castFrom(weakInputStream.adapter);
        //      s.setDone();
        port.close();
      },
      cancelOnError: true,
    );

    dataSubscription.pause();
    port.listen(
      (count) {
        print(count);
        // -1 indicates that the `NSInputStream` is closed. All other values
        // indicate that the `NSInputStream` needs more data.
        //
        // If [DartInputStreamAdapter.setError] or
        // [DartInputStreamAdapter.setDone] is called then the close message
        // (-1) will not be sent when the input stream is closed.
        if (count == -1) {
          port.close();
        } else {
          dataSubscription.resume();
        }
      },
      onDone: () {
        print('port.onDone');
        dataSubscription.cancel();
      },
    );
    print('Returned a stream');
    return inputStream;
  }
}
