import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weight_scale/src/util/state_stream.dart';

void main() {
  group('StateStream', () {
    late StateStream<int> stateStream;

    setUp(() {
      stateStream = StateStream(initValue: 0);
    });

    tearDown(() async {
      await stateStream.close();
    });

    test('[initValue] is set correctly', () {
      expect(stateStream.state, equals(0));
    });

    test('Setting a state updates the getter correctly.', () {
      stateStream.setState(42);
      expect(stateStream.state, equals(42));
    });

    test('The new state is emitted on the events stream.', () {
      fakeAsync((async) {
        StateStream<int> stateStream = StateStream(initValue: 0);
        fakeAsync((async) {
          int newValue = 4;
          stateStream.events.listen((event) {
            expect(event, equals(newValue));
          });
          stateStream.setState(newValue);
          async.flushMicrotasks();
        });
      });
    });

    test('Before closing [isClosed] returns false.', () {
      expect(stateStream.isClosed, isFalse);
    });

    test('After closing [isClosed] returns true.', () {
      stateStream.close();
      expect(stateStream.isClosed, isTrue);
    });

    test('Adding values to closed stream throws.', () {
      stateStream.close();
      expect(() => stateStream.setState(0),
          throwsA(isInstanceOf<StateStreamClosedException>()));
    });
  });
}
