// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The outcome of an operation that can either succeed with a value of type [S]
/// or fail with an error of type [E].
///
/// This is a sealed class, meaning its implementations are fixed: [Success] and
/// [Failure].
///
/// Modeled after the Rust `Result` type.
sealed class Result<S, E> {
  /// Private constructor to prevent direct instantiation.
  const Result._();

  /// Returns `true` if this is a [Success] instance.
  ///
  /// This getter can be used as an alternative to an `is Success` check with
  /// the type argument spelled out. (The type arguments are not inferred.
  /// https://github.com/dart-lang/language/issues/4366)
  bool get isSuccess => this is Success<S>;

  /// Returns `true` if this is a [Failure] instance.
  ///
  /// This getter can be used as an alternative to an `is Failure` check with
  /// the type argument spelled out. (The type arguments are not inferred.
  /// https://github.com/dart-lang/language/issues/4366)
  bool get isFailure => this is Failure<E>;

  /// Returns this result as a [Success] instance.
  ///
  /// Throws if this is a [Failure].
  ///
  /// This getter can be used as an alternative to an `as Success` cast with
  /// the type argument spelled out.
  Success<S> get asSuccess;

  /// Returns this result as a [Failure] instance.
  ///
  /// Throws if this is a [Success].
  ///
  /// This getter can be used as an alternative to an `as Failure` cast with
  /// the type argument spelled out.
  Failure<E> get asFailure;

  /// Retrieves the success value from a [Success] instance.
  ///
  /// Throws if this is a [Failure].
  ///
  /// This getter can be used as an alternative to `(as Success).value`. (Flow
  /// analysis does not take sealed types into account after a `if (is Failure)
  /// return;` https://github.com/dart-lang/language/issues/4364)
  S get success;

  /// Retrieves the failure error from a [Failure] instance.
  ///
  /// Throws if this is a [Success].
  ///
  /// This getter can be used as an alternative to `(as Failure).value`. (Flow
  /// analysis does not take sealed types into account after a `if (is Success)
  /// return;` https://github.com/dart-lang/language/issues/4364)
  E get failure;
}

/// The successful outcome of an operation, containing the [value].
class Success<S> extends Result<S, Never> {
  /// The value of this [Success].
  final S value;

  /// Creates a [Success] instance with the given [value].
  const Success(this.value) : super._();

  @override
  S get success => value;

  @override
  Never get failure => throw StateError('Is not a Failure.');

  @override
  Success<S> get asSuccess => this;

  @override
  Failure<Never> get asFailure => throw StateError('Is not a Failure.');
}

/// The failed outcome of an operation, containing the error [value].
class Failure<E> extends Result<Never, E> {
  /// The value of this [Failure].
  final E value;

  /// Creates a [Failure] instance with the given error [value].
  const Failure(this.value) : super._();

  @override
  Never get success => throw StateError('Is not a Success.');

  @override
  E get failure => value;

  @override
  Success<Never> get asSuccess => throw StateError('Is not a Success.');

  @override
  Failure<E> get asFailure => this;
}
