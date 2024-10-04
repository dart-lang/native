// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:coverage/src/isolate_paused_listener.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

import 'collect_coverage_mock_test.mocks.dart';

Event event(
  String id, {
  String? kind,
  String? groupId,
  String? name,
}) =>
    Event(
        kind: kind,
        isolate: IsolateRef(
          isolateGroupId: groupId,
          id: id,
          name: name,
        ));

Isolate isolate(
  String id, {
  String? groupId,
  String? name,
  String? pauseKind,
}) =>
    Isolate(
      isolateGroupId: groupId,
      id: id,
      name: name,
      pauseEvent: pauseKind == null ? null : Event(kind: pauseKind),
    );

(MockVmService, StreamController<Event>) createServiceAndEventStreams() {
  final service = MockVmService();
  when(service.streamListen(any)).thenAnswer((_) async => Success());

  // The VM service events we care about come in on 2 different streams,
  // onIsolateEvent and onDebugEvent. We want to write tests that send sequences
  // of events like [I1, D1, I2, D2, I3, D3], but since I and D go to separate
  // streams, the listener may see them arrive like [I1, I2, I3, D1, D2, D3] or
  // [D1, D2, D3, I1, I2, I3] or any other interleaving. So instead we send all
  // the events through a single stream that gets split up. This emulates how
  // the events work in reality, since they all come from a single web socket.
  final allEvents = StreamController<Event>();
  final isolateEvents = StreamController<Event>();
  final debugEvents = StreamController<Event>();
  allEvents.stream.listen((Event e) {
    if (e.kind == EventKind.kIsolateStart ||
        e.kind == EventKind.kIsolateStart) {
      isolateEvents.add(e);
    } else {
      debugEvents.add(e);
    }
  });
  when(service.onIsolateEvent).thenAnswer((_) => isolateEvents.stream);
  when(service.onDebugEvent).thenAnswer((_) => debugEvents.stream);

  return (service, allEvents);
}

void main() {
  group('IsolateEventBuffer', () {
    test('buffers events', () async {
      final received = <String>[];
      final eventBuffer = IsolateEventBuffer((Event event) async {
        await Future<void>.delayed(Duration.zero);
        received.add(event.isolate!.id!);
      });

      await eventBuffer.add(event('a'));
      await eventBuffer.add(event('b'));
      await eventBuffer.add(event('c'));
      expect(received, <String>[]);

      await eventBuffer.flush();
      expect(received, ['a', 'b', 'c']);

      await eventBuffer.flush();
      expect(received, ['a', 'b', 'c']);

      await eventBuffer.add(event('d'));
      await eventBuffer.add(event('e'));
      await eventBuffer.add(event('f'));
      expect(received, ['a', 'b', 'c', 'd', 'e', 'f']);

      await eventBuffer.flush();
      expect(received, ['a', 'b', 'c', 'd', 'e', 'f']);
    });

    test('buffers events during flush', () async {
      final received = <String>[];
      final pause = Completer<void>();
      final eventBuffer = IsolateEventBuffer((Event event) async {
        await pause.future;
        received.add(event.isolate!.id!);
      });

      await eventBuffer.add(event('a'));
      await eventBuffer.add(event('b'));
      await eventBuffer.add(event('c'));
      expect(received, <String>[]);

      final flushing = eventBuffer.flush();
      expect(received, <String>[]);

      await eventBuffer.add(event('d'));
      await eventBuffer.add(event('e'));
      await eventBuffer.add(event('f'));
      expect(received, <String>[]);

      pause.complete();
      await flushing;
      expect(received, ['a', 'b', 'c', 'd', 'e', 'f']);
    });
  });

  test('IsolateEventBuffer', () {
    final group = IsolateGroupState();
    expect(group.running, isEmpty);
    expect(group.paused, isEmpty);
    expect(group.noRunningIsolates, isTrue);
    expect(group.noLiveIsolates, isTrue);

    group.start('a');
    expect(group.running, unorderedEquals(['a']));
    expect(group.paused, isEmpty);
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.start('a');
    expect(group.running, unorderedEquals(['a']));
    expect(group.paused, isEmpty);
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.start('b');
    expect(group.running, unorderedEquals(['a', 'b']));
    expect(group.paused, isEmpty);
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.pause('a');
    expect(group.running, unorderedEquals(['b']));
    expect(group.paused, unorderedEquals(['a']));
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.pause('a');
    expect(group.running, unorderedEquals(['b']));
    expect(group.paused, unorderedEquals(['a']));
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.pause('c');
    expect(group.running, unorderedEquals(['b']));
    expect(group.paused, unorderedEquals(['a', 'c']));
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.start('c');
    expect(group.running, unorderedEquals(['b', 'c']));
    expect(group.paused, unorderedEquals(['a']));
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.pause('c');
    expect(group.running, unorderedEquals(['b']));
    expect(group.paused, unorderedEquals(['a', 'c']));
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.exit('a');
    expect(group.running, unorderedEquals(['b']));
    expect(group.paused, unorderedEquals(['c']));
    expect(group.noRunningIsolates, isFalse);
    expect(group.noLiveIsolates, isFalse);

    group.pause('b');
    expect(group.running, isEmpty);
    expect(group.paused, unorderedEquals(['b', 'c']));
    expect(group.noRunningIsolates, isTrue);
    expect(group.noLiveIsolates, isFalse);

    group.exit('b');
    expect(group.running, isEmpty);
    expect(group.paused, unorderedEquals(['c']));
    expect(group.noRunningIsolates, isTrue);
    expect(group.noLiveIsolates, isFalse);

    group.exit('c');
    expect(group.running, isEmpty);
    expect(group.paused, isEmpty);
    expect(group.noRunningIsolates, isTrue);
    expect(group.noLiveIsolates, isTrue);
  });

  group('listenToIsolateLifecycleEvents', () {
    late MockVmService service;
    late StreamController<Event> allEvents;
    late Completer<List<Isolate>> isolates;
    late Future<void> backfilled;
    late Future<void> testEnded;

    late List<String> received;
    Future<void>? delayTheOnPauseCallback;

    void startEvent(String id) =>
        allEvents.add(event(id, kind: EventKind.kIsolateStart));
    void exitEvent(String id) =>
        allEvents.add(event(id, kind: EventKind.kIsolateExit));
    void pauseEvent(String id) =>
        allEvents.add(event(id, kind: EventKind.kPauseExit));
    void otherEvent(String id, String kind) =>
        allEvents.add(event(id, kind: kind));

    Future<void> backfill(List<Isolate> isos) async {
      isolates.complete(isos);
      await backfilled;
    }

    // We end the test by sending an exit event with a specific ID.
    const endTestEventId = 'END';
    Future<void> endTest() {
      exitEvent(endTestEventId);
      return testEnded;
    }

    setUp(() {
      (service, allEvents) = createServiceAndEventStreams();

      isolates = Completer<List<Isolate>>();
      when(service.getVM())
          .thenAnswer((_) async => VM(isolates: await isolates.future));
      when(service.getIsolate(any)).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0];
        return (await isolates.future).firstWhere((iso) => iso.id == id);
      });

      received = <String>[];
      delayTheOnPauseCallback = null;
      final testEnder = Completer<void>();
      testEnded = testEnder.future;
      backfilled = listenToIsolateLifecycleEvents(
        service,
        (iso) {
          if (iso.id == endTestEventId) return;
          received.add('Start ${iso.id}');
        },
        (iso) async {
          received.add('Pause ${iso.id}');
          if (delayTheOnPauseCallback != null) {
            await delayTheOnPauseCallback;
            received.add('Pause done ${iso.id}');
          }
        },
        (iso) {
          if (iso.id == endTestEventId) {
            testEnder.complete();
          } else {
            received.add('Exit ${iso.id}');
          }
        },
      );
    });

    test('ordinary flows', () async {
      // Events sent before backfill.
      startEvent('A');
      startEvent('C');
      startEvent('B');
      pauseEvent('C');
      pauseEvent('A');
      startEvent('D');
      pauseEvent('D');
      exitEvent('A');

      // Run backfill.
      await backfill([
        isolate('B'),
        isolate('C', pauseKind: EventKind.kPauseExit),
        isolate('D'),
        isolate('E'),
        isolate('F', pauseKind: EventKind.kPauseExit),
      ]);

      // All the backfill events happen before any of the real events.
      expect(received, [
        // Backfill events.
        'Start B',
        'Start C',
        'Pause C',
        'Start D',
        'Start E',
        'Start F',
        'Pause F',

        // Real events from before backfill.
        'Start A',
        'Pause A',
        'Pause D',
        'Exit A',
      ]);

      // Events sent after backfill.
      received.clear();
      startEvent('G');
      exitEvent('C');
      exitEvent('B');
      exitEvent('G');
      exitEvent('D');
      exitEvent('E');
      exitEvent('F');

      await endTest();
      expect(received, [
        'Start G',
        'Exit C',
        'Exit B',
        'Exit G',
        'Exit D',
        'Exit E',
        'Exit F',
      ]);

      verify(service.streamListen(EventStreams.kIsolate)).called(1);
      verify(service.streamListen(EventStreams.kDebug)).called(1);
    });

    test('pause and exit events without start', () async {
      await backfill([]);

      pauseEvent('A');
      exitEvent('B');

      await endTest();
      expect(received, [
        'Start A',
        'Pause A',
        'Start B',
        'Exit B',
      ]);
    });

    test('pause event after exit is ignored', () async {
      await backfill([]);

      exitEvent('A');
      pauseEvent('A');

      await endTest();
      expect(received, [
        'Start A',
        'Exit A',
      ]);
    });

    test('event deduping', () async {
      startEvent('A');
      startEvent('A');
      pauseEvent('A');
      pauseEvent('A');
      exitEvent('A');
      exitEvent('A');

      pauseEvent('B');
      startEvent('B');

      exitEvent('C');
      startEvent('C');

      await backfill([]);
      await endTest();
      expect(received, [
        'Start A',
        'Pause A',
        'Exit A',
        'Start B',
        'Pause B',
        'Start C',
        'Exit C',
      ]);
    });

    test('ignore other events', () async {
      await backfill([]);

      startEvent('A');
      pauseEvent('A');
      otherEvent('A', EventKind.kResume);
      exitEvent('A');

      startEvent('B');
      otherEvent('B', EventKind.kPauseBreakpoint);
      exitEvent('B');

      otherEvent('C', EventKind.kInspect);

      await endTest();
      expect(received, [
        'Start A',
        'Pause A',
        'Exit A',
        'Start B',
        'Exit B',
      ]);
    });

    test('exit event during pause callback', () async {
      final delayingTheOnPauseCallback = Completer<void>();
      delayTheOnPauseCallback = delayingTheOnPauseCallback.future;
      await backfill([]);

      startEvent('A');
      pauseEvent('A');
      exitEvent('A');

      while (received.length < 2) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(received, [
        'Start A',
        'Pause A',
      ]);

      delayingTheOnPauseCallback.complete();
      await endTest();
      expect(received, [
        'Start A',
        'Pause A',
        'Pause done A',
        'Exit A',
      ]);
    });

    test('exit event during pause callback, event deduping', () async {
      final delayingTheOnPauseCallback = Completer<void>();
      delayTheOnPauseCallback = delayingTheOnPauseCallback.future;
      await backfill([]);

      startEvent('A');
      pauseEvent('A');
      exitEvent('A');
      pauseEvent('A');
      pauseEvent('A');
      exitEvent('A');
      exitEvent('A');

      while (received.length < 2) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(received, [
        'Start A',
        'Pause A',
      ]);

      delayingTheOnPauseCallback.complete();
      await endTest();
      expect(received, [
        'Start A',
        'Pause A',
        'Pause done A',
        'Exit A',
      ]);
    });
  });

  group('IsolatePausedListener', () {
    late MockVmService service;
    late StreamController<Event> allEvents;
    late Future<void> allIsolatesExited;

    late List<String> received;
    late bool stopped;

    void startEvent(String id, String groupId, [String? name]) =>
        allEvents.add(event(
          id,
          kind: EventKind.kIsolateStart,
          groupId: groupId,
          name: name ?? id,
        ));
    void exitEvent(String id, String groupId, [String? name]) =>
        allEvents.add(event(
          id,
          kind: EventKind.kIsolateExit,
          groupId: groupId,
          name: name ?? id,
        ));
    void pauseEvent(String id, String groupId, [String? name]) =>
        allEvents.add(event(
          id,
          kind: EventKind.kPauseExit,
          groupId: groupId,
          name: name ?? id,
        ));

    Future<void> endTest() async {
      await allIsolatesExited;
      stopped = true;
    }

    setUp(() {
      (service, allEvents) = createServiceAndEventStreams();

      // Backfill was tested above, so this test does everything using events,
      // for simplicity. No need to report any isolates.
      when(service.getVM()).thenAnswer((_) async => VM());

      received = <String>[];
      when(service.resume(any)).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0];
        received.add('Resume $id');
        return Success();
      });

      stopped = false;
      allIsolatesExited = IsolatePausedListener(
        service,
        (iso, isLastIsolateInGroup) async {
          expect(stopped, isFalse);
          received.add('Pause ${iso.id}. Last in group ${iso.isolateGroupId}? '
              '${isLastIsolateInGroup ? 'Yes' : 'No'}');
        },
        (message) => received.add(message),
      ).waitUntilAllExited();
    });

    test('ordinary flows', () async {
      startEvent('A', '1');
      startEvent('B', '1');
      pauseEvent('A', '1');
      startEvent('C', '1');
      pauseEvent('B', '1');
      exitEvent('A', '1');
      startEvent('D', '2');
      startEvent('E', '2');
      startEvent('F', '2');
      pauseEvent('C', '1');
      pauseEvent('F', '2');
      pauseEvent('E', '2');
      exitEvent('C', '1');
      exitEvent('E', '2');
      startEvent('G', '3');
      exitEvent('F', '2');
      startEvent('H', '3');
      startEvent('I', '3');
      pauseEvent('I', '3');
      exitEvent('I', '3');
      pauseEvent('H', '3');
      exitEvent('H', '3');
      pauseEvent('D', '2');
      pauseEvent('G', '3');
      exitEvent('D', '2');
      exitEvent('G', '3');
      exitEvent('B', '1');

      await endTest();

      // Events sent after waitUntilAllExited is finished do nothing.
      startEvent('Z', '9');
      pauseEvent('Z', '9');
      exitEvent('Z', '9');

      expect(received, [
        'Pause A. Last in group 1? No',
        'Resume A',
        'Pause B. Last in group 1? No',
        'Resume B',
        'Pause C. Last in group 1? Yes',
        'Resume C',
        'Pause F. Last in group 2? No',
        'Resume F',
        'Pause E. Last in group 2? No',
        'Resume E',
        'Pause I. Last in group 3? No',
        'Resume I',
        'Pause H. Last in group 3? No',
        'Resume H',
        'Pause D. Last in group 2? Yes',
        'Resume D',
        'Pause G. Last in group 3? Yes',
        'Resume G',
      ]);
    });

    test('exit without pausing', () async {
      // If an isolate exits without pausing, this may mess up coverage
      // collection (if it happens to be the last isolate in the group, that
      // group won't be collected). The best we can do is log an error, and make
      // sure not to wait forever for pause events that aren't coming.
      startEvent('A', '1');
      startEvent('B', '1');
      exitEvent('A', '1');
      pauseEvent('B', '1');
      startEvent('C', '2');
      startEvent('D', '2');
      pauseEvent('D', '2');
      exitEvent('D', '2');
      exitEvent('C', '2');
      exitEvent('B', '1');

      await endTest();

      // B was paused correctly and was the last to exit isolate 1, so isolate 1
      // was collected ok.
      expect(received, [
        'Pause B. Last in group 1? Yes',
        'Resume B',
        'Pause D. Last in group 2? No',
        'Resume D',
        'ERROR: An isolate exited without pausing, causing coverage data to '
            'be lost for group 2.',
      ]);
    });

    test('main isolate resumed last', () async {
      startEvent('A', '1', 'main');
      startEvent('B', '1', 'main'); // Second isolate named main, ignored.
      pauseEvent('B', '1', 'main');
      startEvent('C', '2', 'main'); // Third isolate named main, ignored.
      pauseEvent('A', '1', 'main');
      startEvent('D', '2');
      pauseEvent('C', '2');
      exitEvent('C', '2');
      pauseEvent('D', '2');
      exitEvent('D', '2');
      exitEvent('B', '1');

      await endTest();

      expect(received, [
        'Pause B. Last in group 1? No',
        'Resume B',
        'Pause C. Last in group 2? No',
        'Resume C',
        'Pause D. Last in group 2? Yes',
        'Resume D',
        'Pause A. Last in group 1? Yes',
        'Resume A',
      ]);
    });

    test('main isolate exits without pausing', () async {
      startEvent('A', '1', 'main');
      startEvent('B', '1');
      pauseEvent('B', '1');
      exitEvent('A', '1', 'main');
      exitEvent('B', '1');

      await endTest();

      expect(received, [
        'Pause B. Last in group 1? No',
        'Resume B',
        'ERROR: An isolate exited without pausing, causing coverage data to '
            'be lost for group 1.',
      ]);
    });

    test('main isolate is the only isolate', () async {
      startEvent('A', '1', 'main');
      pauseEvent('A', '1', 'main');

      await endTest();

      expect(received, [
        'Pause A. Last in group 1? Yes',
        'Resume A',
      ]);
    });

    test('all other isolates exit before main isolate pauses', () async {
      startEvent('A', '1', 'main');
      startEvent('B', '1');
      pauseEvent('B', '1');
      exitEvent('B', '1');

      await Future<void>.delayed(Duration.zero);

      pauseEvent('A', '1', 'main');
      exitEvent('A', '1', 'main');

      await endTest();

      expect(received, [
        'Pause B. Last in group 1? No',
        'Resume B',
        'Pause A. Last in group 1? Yes',
        'Resume A',
      ]);
    });

    test('group reopened', () async {
      // If an isolate is reported in a group after the group as believed to be
      // closed, reopen the group. This double counts some coverage, but at
      // least won't miss any.

      startEvent('Z', '9'); // Separate isolate to keep the system alive until
      pauseEvent('Z', '9'); // the test is complete.

      startEvent('A', '1');
      startEvent('B', '1');
      pauseEvent('A', '1');
      pauseEvent('B', '1');
      exitEvent('B', '1');
      exitEvent('A', '1');

      startEvent('D', '2');
      startEvent('E', '2');
      pauseEvent('E', '2');
      pauseEvent('D', '2');
      exitEvent('E', '2');
      exitEvent('D', '2');

      startEvent('C', '1');
      pauseEvent('F', '2');
      pauseEvent('C', '1');
      exitEvent('C', '1');
      exitEvent('F', '2');

      exitEvent('Z', '9');

      await endTest();

      expect(received, [
        'Pause Z. Last in group 9? Yes',
        'Resume Z',
        'Pause A. Last in group 1? No',
        'Resume A',
        'Pause B. Last in group 1? Yes',
        'Resume B',
        'Pause E. Last in group 2? No',
        'Resume E',
        'Pause D. Last in group 2? Yes',
        'Resume D',
        'Pause F. Last in group 2? Yes',
        'Resume F',
        'Pause C. Last in group 1? Yes',
        'Resume C',
      ]);
    });
  });
}
