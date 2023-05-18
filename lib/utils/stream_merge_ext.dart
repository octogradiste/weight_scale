import 'dart:async';

extension StreamMergeExt<A> on Stream<A> {
  /// Merges this stream with an [other] to form a new stream of type [C].
  ///
  /// The first element emitted by the new stream, is the first value of
  /// this stream merged with the [initialValue] or (if the [other] has
  /// already emitted some values) with the latest value emitted by the [other].
  ///
  /// Then the new stream emits an new event as soon as this or the [other]
  /// stream emits a value. This value will be merged with the latest value of
  /// the [other] or this stream respectively.
  ///
  /// The function [onMerge] is used to merge values from the two streams.
  Stream<C> merge<B, C>({
    required Stream<B> other,
    required B initialValue,
    required C Function(A a, B b) onMerge,
  }) {
    bool thisIsDone = false;
    bool otherIsDone = false;

    StreamController<C> controller = StreamController();

    A? latestThis;
    B latestOther = initialValue;

    listen(
      (event) {
        controller.add(onMerge(event, latestOther));
        latestThis = event;
      },
      onDone: () {
        thisIsDone = true;
        if (otherIsDone) controller.close();
      },
    );

    other.listen(
      (event) {
        if (latestThis != null) {
          controller.add(onMerge(latestThis as A, event));
        }
        latestOther = event;
      },
      onDone: () {
        otherIsDone = true;
        if (thisIsDone) controller.close();
      },
    );

    return controller.stream;
  }
}
