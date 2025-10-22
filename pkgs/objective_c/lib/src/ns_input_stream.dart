import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import '../objective_c.dart';

import 'objective_c_bindings_generated.dart';

extension NSInputStreamStreamExtension on Stream<List<int>> {
  /// Return a [NSInputStream] that, when read, will contain the contents of
  /// the [Stream].
  ///
  /// > [!IMPORTANT]
  /// > `NSInputStream.read` must be called from a different thread or [Isolate]
  /// > than the one that calls [toNSInputStream]. Otherwise,
  /// > `NSInputStream.read` will deadlock waiting for data to be added from the
  /// > [Stream].
  ///
  /// > [!IMPORTANT]
  /// > `NSInputStream.read` must be called from a different thread or [Isolate]
  /// > than the one that calls `toNSInputStream`. Otherwise,
  /// > `NSInputStream.read` will deadlock waiting for data to be added from the
  /// > [Stream].
  ///
  /// > [!IMPORTANT]
  /// > `toNSInputStream` creates a reference cycle between Dart and
  /// > Objective-C. Unless this cycle is broken, the [Isolate] calling
  /// > `toNSInputStream` will never exit. The cycle can be broken by calling
  /// > `NSInputStream.close` or releasing the `NSInputStream` using
  /// > `NSInputStream.ref.release()`.
  NSInputStream toNSInputStream() {
    // Eagerly add data until `maxReadAheadSize` is buffered.
    const maxReadAheadSize = 4096;

    final port = ReceivePort();

    late final DartInputStreamAdapter inputStream;
    late final DartInputStreamAdapterWeakHolder weakInputStream;

    // Only hold a weak reference to the returned `inputStream` so that there is
    // no unbreakable reference cycle between Dart and Objective-C. When the
    // `inputStream`'s `dealloc` method is called then it sends this code a
    // message saying that it was closed.
    autoReleasePool(() {
      inputStream = DartInputStreamAdapter.inputStreamWithPort(
        port.sendPort.nativePort,
      );
      weakInputStream =
          DartInputStreamAdapterWeakHolder.holderWithInputStreamAdapter(
            inputStream,
          );
    });

    late final StreamSubscription<dynamic> dataSubscription;

    dataSubscription = listen(
      (data) {
        final inputStream = weakInputStream.adapter;
        if (inputStream.addData(data.toNSData()) > maxReadAheadSize) {
          dataSubscription.pause();
        }
        inputStream.ref.release();
      },
      onError: (Object e) {
        final inputStream = weakInputStream.adapter;
        final d = NSMutableDictionary();
        // d[NSLocalizedDescriptionKey] = e.toString().toNSString();
        inputStream.setError(
          NSError.errorWithDomain(
            'DartError'.toNSString(),
            code: 0,
            userInfo: d,
          ),
        );
        inputStream.ref.release();
        port.close();
      },
      onDone: () {
        final inputStream = weakInputStream.adapter;
        inputStream.setDone();
        inputStream.ref.release();
        port.close();
      },
      cancelOnError: true,
    );

    dataSubscription.pause();
    port.listen(
      (count) {
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
        dataSubscription.cancel();
      },
    );

    return inputStream;
  }
}
