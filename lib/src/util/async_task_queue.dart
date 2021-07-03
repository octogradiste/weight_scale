import 'dart:async';
import 'dart:collection';

typedef Work = Future<void> Function();
typedef Task<T> = Future<T> Function();

/// A queue executing async tasks one by one.
class AsyncTaskQueue {
  bool _isWorking = false;
  final Queue<Work> _queue = Queue();

  /// Adds a [task] and returns a [Future] with the result [T] of the [task].
  Future<T> add<T>(Task<T> task) {
    Completer<T> completer = Completer();
    _queue.add(() async => completer.complete(await task()));
    if (!_isWorking) _work();
    return completer.future;
  }

  /// Executes (recursively) all tasks in [_queue] one by one.
  void _work() async {
    if (_isWorking) throw Exception("Private work method invoke while working");

    _isWorking = true;
    Work work = _queue.removeFirst();
    await work();
    _isWorking = false;

    if (_queue.isNotEmpty) _work();
  }
}
