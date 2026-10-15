import 'package:flutter_test/flutter_test.dart';
import 'package:pixez/utils/serial_executor.dart';

void main() {
  test('runs tasks one at a time in submission order', () async {
    final executor = SerialExecutor();
    final events = <String>[];

    // Earlier tasks take longer; without serialization they finish last.
    final futures = [
      for (var i = 0; i < 3; i++)
        executor.run(() async {
          events.add('start $i');
          await Future<void>.delayed(Duration(milliseconds: 30 - i * 10));
          events.add('end $i');
          return i;
        }),
    ];

    expect(await Future.wait(futures), [0, 1, 2]);
    expect(events, [
      'start 0',
      'end 0',
      'start 1',
      'end 1',
      'start 2',
      'end 2',
    ]);
  });

  test('a failing task does not block later tasks', () async {
    final executor = SerialExecutor();

    final failed = executor.run<void>(() async => throw StateError('boom'));
    final next = executor.run(() async => 'next');

    await expectLater(failed, throwsStateError);
    expect(await next, 'next');
  });
}
