import 'dart:async';
import 'dart:collection';

typedef Work = Future<void> Function();
typedef Task<T> = Future<T> Function();

/// A queue executing async tasks one by one.
class AsyncTaskQueue {
  bool _isWorking = false;
  final Queue<Work> _queue = Queue();

  /// Adds a [task] and returns a [Future] with the result [T] of the [task].
  ///
  /// If [task] throws an error, the returned [Future] will complete with the
  /// same error.
  Future<T> add<T>(Task<T> task) {
    Completer<T> completer = Completer();
    _queue.add(() async {
      try {
        T result = await task();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    if (!_isWorking) _work();
    return completer.future;
  }

  /// Executes (recursively) all tasks in [_queue] one by one.
  void _work() async {
    /// If is already working on some others task, something is wrong.
    if (_isWorking) throw Exception("Private work method invoke while working");

    _isWorking = true;
    Work work = _queue.removeFirst();
    await work();
    _isWorking = false;

    if (_queue.isNotEmpty) _work();
  }
}
