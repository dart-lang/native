import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'ns_data.dart';
import 'ns_string.dart';
import 'objective_c_bindings_generated.dart';

@Native<Pointer<Void> Function()>(
  isLeaf: true,
  symbol: 'objc_autoreleasePoolPush',
)
external Pointer<Void> autoreleasePoolPush();

@Native<Void Function(Pointer<Void>)>(
  isLeaf: true,
  symbol: 'objc_autoreleasePoolPop',
)
external void autoreleasePoolPop(Pointer<Void> pool);

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

    final DartInputStreamAdapter inputStream;
    final DOBJCDartInputStreamAdapterWeakHolder weakInputStream;
    final pool = autoreleasePoolPush();
    try {
      inputStream = DartInputStreamAdapter.inputStreamWithPort(
        port.sendPort.nativePort,
      );
      weakInputStream = DOBJCDartInputStreamAdapterWeakHolder.initWithAdapter(
        inputStream,
      );
      print('The pointer for inputStream is: ${inputStream.ref.pointer}');
      print(
        'The pointer for weakInputStream is: ${weakInputStream.ref.pointer}',
      );
    } finally {
      autoreleasePoolPop(pool);
    }

    print('The pointer for inputStream is: ${inputStream.ref.pointer}');
    print('The pointer for weakInputStream is: ${weakInputStream.ref.pointer}');

    late final StreamSubscription<dynamic> dataSubscription;

    dataSubscription = listen(
      (data) {
        final s = DartInputStreamAdapter.castFrom(weakInputStream.adapter);
        if (s.addData(data.toNSData()) > maxReadAheadSize) {
          dataSubscription.pause();
        }
        s.ref.release();
      },
      onError: (Object e) {
        final s = weakInputStream.adapter;
        final d = NSMutableDictionary();
        d[NSLocalizedDescriptionKey] = e.toString().toNSString();
        s.setError(
          NSError.errorWithDomain(
            'DartError'.toNSString(),
            code: 0,
            userInfo: d,
          ),
        );
        s.ref.release();
        port.close();
      },
      onDone: () {
        print('dataSubscription.onDone');
        final s = weakInputStream.adapter;
        s.setDone();
        s.ref.release();
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
