import 'dart:async';

/// Exception thrown when trying to add a value to a closed [StateStream].
class StateStreamClosedException implements Exception {}

/// A state holding class with and event stream.
///
/// To have good separation of concerns only expose the [state]
/// and [events] stream.
class StateStream<T> {
  late T _state;
  final StreamController<T> _controller = StreamController.broadcast();

  /// When a new state is set, this stream broadcasts it to its listeners.
  late final Stream<T> events = _controller.stream;

  StateStream({required T initValue}) {
    _state = initValue;
  }

  /// Returns the current state.
  T get state => _state;

  /// Returns true if the stream has been closed.
  bool get isClosed => _controller.isClosed;

  /// Sets the new [state] and emits it on the [events] stream.
  ///
  /// If this [StateStream] is already closed, [StateStreamClosedException] is
  /// thrown. Use [isClosed] to check if the stream has been closed.
  void setState(T value) {
    if (isClosed) throw StateStreamClosedException();
    _state = value;
    _controller.add(value);
  }

  /// Closes the [StateStream] so that no new values can be added.
  Future<void> close() async {
    await _controller.close();
  }
}
