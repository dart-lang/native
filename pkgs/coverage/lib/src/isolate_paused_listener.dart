// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:vm_service/vm_service.dart';

import 'util.dart';

typedef SyncIsolateCallback = void Function(IsolateRef isolate);
typedef AsyncIsolateCallback = Future<void> Function(IsolateRef isolate);
typedef AsyncIsolatePausedCallback = Future<void> Function(
    IsolateRef isolate, bool isLastIsolateInGroup);
typedef AsyncVmServiceEventCallback = Future<void> Function(Event event);
typedef SyncErrorLogger = void Function(String message);

/// Calls onIsolatePaused whenever an isolate reaches the pause-on-exit state,
/// and passes a flag stating whether that isolate is the last one in the group.
class IsolatePausedListener {
  IsolatePausedListener(this._service, this._onIsolatePaused, this._log);

  final VmService _service;
  final AsyncIsolatePausedCallback _onIsolatePaused;
  final SyncErrorLogger _log;

  final _isolateGroups = <String, IsolateGroupState>{};

  int _numNonMainIsolates = 0;
  final _allNonMainIsolatesExited = Completer<void>();
  bool _finished = false;

  IsolateRef? _mainIsolate;
  final _mainIsolatePaused = Completer<bool>();

  /// Starts listening and returns a future that completes when all isolates
  /// have exited.
  Future<void> waitUntilAllExited() async {
    await listenToIsolateLifecycleEvents(_service, _onStart, _onPause, _onExit);

    await _allNonMainIsolatesExited.future;

    // Resume the main isolate.
    try {
      if (_mainIsolate != null) {
        if (await _mainIsolatePaused.future) {
          await _runCallbackAndResume(_mainIsolate!, true);
        }
      }
    } finally {
      _finished = true;
    }
  }

  IsolateGroupState _getGroup(IsolateRef isolateRef) =>
      _isolateGroups[isolateRef.isolateGroupId!] ??= IsolateGroupState();

  void _onStart(IsolateRef isolateRef) {
    if (_finished) return;
    final group = _getGroup(isolateRef);
    group.start(isolateRef.id!);
    if (_mainIsolate == null && _isMainIsolate(isolateRef)) {
      _mainIsolate = isolateRef;
    } else {
      ++_numNonMainIsolates;
    }
  }

  Future<void> _onPause(IsolateRef isolateRef) async {
    if (_finished) return;
    final group = _getGroup(isolateRef);
    group.pause(isolateRef.id!);
    if (isolateRef.id! == _mainIsolate?.id) {
      _mainIsolatePaused.complete(true);

      // If the main isolate is the only isolate, then _allNonMainIsolatesExited
      // will never be completed. So check that case here.
      _checkCompleted();
    } else {
      await _runCallbackAndResume(isolateRef, group.noRunningIsolates);
    }
  }

  Future<void> _runCallbackAndResume(
      IsolateRef isolateRef, bool isLastIsolateInGroup) async {
    if (isLastIsolateInGroup) {
      _getGroup(isolateRef).collected = true;
    }
    try {
      await _onIsolatePaused(isolateRef, isLastIsolateInGroup);
    } finally {
      await _service.resume(isolateRef.id!);
    }
  }

  void _onExit(IsolateRef isolateRef) {
    if (_finished) return;
    final group = _getGroup(isolateRef);
    group.exit(isolateRef.id!);
    if (group.noLiveIsolates && !group.collected) {
      _log('ERROR: An isolate exited without pausing, causing '
          'coverage data to be lost for group ${isolateRef.isolateGroupId!}.');
    }
    if (isolateRef.id! == _mainIsolate?.id) {
      if (!_mainIsolatePaused.isCompleted) {
        // Main isolate exited without pausing.
        _mainIsolatePaused.complete(false);
      }
    } else {
      --_numNonMainIsolates;
      _checkCompleted();
    }
  }

  void _checkCompleted() {
    if (_numNonMainIsolates == 0 && !_allNonMainIsolatesExited.isCompleted) {
      _allNonMainIsolatesExited.complete();
    }
  }

  static bool _isMainIsolate(IsolateRef isolateRef) {
    // HACK: This should pretty reliably detect the main isolate, but it's not
    // foolproof and relies on unstable features. The Dart standalone embedder
    // and Flutter both call the main isolate "main", and they both also list
    // this isolate first when querying isolates from the VM service. So
    // selecting the first isolate named "main" combines these conditions and
    // should be reliable enough for now, while we wait for a better test.
    // TODO(https://github.com/dart-lang/sdk/issues/56732): Switch to more
    // reliable test when it's available.
    return isolateRef.name == 'main';
  }
}

/// Listens to isolate start and pause events, and backfills events for isolates
/// that existed before listening started.
///
/// Ensures that:
///  - Every [onIsolatePaused] and [onIsolateExited] call will be preceeded by
///    an [onIsolateStarted] call for the same isolate.
///  - Not every [onIsolateExited] call will be preceeded by a [onIsolatePaused]
///    call, but a [onIsolatePaused] will never follow a [onIsolateExited].
///  - [onIsolateExited] will always run after [onIsolatePaused] completes, even
///    if an exit event arrives while [onIsolatePaused] is being awaited.
///  - Each callback will only be called once per isolate.
Future<void> listenToIsolateLifecycleEvents(
    VmService service,
    SyncIsolateCallback onIsolateStarted,
    AsyncIsolateCallback onIsolatePaused,
    SyncIsolateCallback onIsolateExited) async {
  final started = <String>{};
  void onStart(IsolateRef isolateRef) {
    if (started.add(isolateRef.id!)) onIsolateStarted(isolateRef);
  }

  final paused = <String, Future<void>>{};
  Future<void> onPause(IsolateRef isolateRef) async {
    try {
      onStart(isolateRef);
    } finally {
      await (paused[isolateRef.id!] ??= onIsolatePaused(isolateRef));
    }
  }

  final exited = <String>{};
  Future<void> onExit(IsolateRef isolateRef) async {
    onStart(isolateRef);
    if (exited.add(isolateRef.id!)) {
      try {
        // Wait for in-progress pause callbacks, and prevent future pause
        // callbacks from running.
        await (paused[isolateRef.id!] ??= Future<void>.value());
      } finally {
        onIsolateExited(isolateRef);
      }
    }
  }

  final eventBuffer = IsolateEventBuffer((Event event) async {
    switch (event.kind) {
      case EventKind.kIsolateStart:
        return onStart(event.isolate!);
      case EventKind.kPauseExit:
        return await onPause(event.isolate!);
      case EventKind.kIsolateExit:
        return await onExit(event.isolate!);
    }
  });

  // Listen for isolate start/exit events.
  service.onIsolateEvent.listen(eventBuffer.add);
  await service.streamListen(EventStreams.kIsolate);

  // Listen for isolate paused events.
  service.onDebugEvent.listen(eventBuffer.add);
  await service.streamListen(EventStreams.kDebug);

  // Backfill. Add/pause isolates that existed before we subscribed.
  for (final isolateRef in await getAllIsolates(service)) {
    onStart(isolateRef);
    final isolate = await service.getIsolate(isolateRef.id!);
    if (isolate.pauseEvent?.kind == EventKind.kPauseExit) {
      await onPause(isolateRef);
    }
  }

  // Flush the buffered stream events, and the start processing them as they
  // arrive.
  await eventBuffer.flush();
}

/// Keeps track of isolates in an isolate group.
class IsolateGroupState {
  // IDs of the isolates running in this group.
  @visibleForTesting
  final running = <String>{};

  // IDs of the isolates paused just before exiting in this group.
  @visibleForTesting
  final paused = <String>{};

  bool collected = false;

  bool get noRunningIsolates => running.isEmpty;
  bool get noLiveIsolates => running.isEmpty && paused.isEmpty;

  void start(String id) {
    paused.remove(id);
    running.add(id);
  }

  void pause(String id) {
    running.remove(id);
    paused.add(id);
  }

  void exit(String id) {
    running.remove(id);
    paused.remove(id);
  }

  @override
  String toString() => '{running: $running, paused: $paused}';
}

/// Buffers VM service isolate [Event]s until [flush] is called.
///
/// [flush] passes each buffered event to the handler function. After that, any
/// further events are immediately passed to the handler. [flush] returns a
/// future that completes when all the events in the queue have been handled (as
/// well as any events that arrive while flush is in progress).
class IsolateEventBuffer {
  IsolateEventBuffer(this._handler);

  final AsyncVmServiceEventCallback _handler;
  final _buffer = Queue<Event>();
  var _flushed = false;

  Future<void> add(Event event) async {
    if (_flushed) {
      await _handler(event);
    } else {
      _buffer.add(event);
    }
  }

  Future<void> flush() async {
    while (_buffer.isNotEmpty) {
      final event = _buffer.removeFirst();
      await _handler(event);
    }
    _flushed = true;
  }
}
