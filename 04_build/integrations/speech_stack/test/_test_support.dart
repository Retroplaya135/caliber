import 'dart:async';

typedef TestBody = FutureOr<void> Function();

class TestFailure implements Exception {
  const TestFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<void> runTest(String name, TestBody body) async {
  try {
    await body();
    print('PASS $name');
  } catch (error, stackTrace) {
    print('FAIL $name');
    print(error);
    print(stackTrace);
    rethrow;
  }
}

void check(bool condition, String message) {
  if (!condition) {
    throw TestFailure(message);
  }
}

Future<void> checkThrows<T>(
  FutureOr<void> Function() body,
  String message,
) async {
  try {
    await body();
  } catch (error) {
    if (error is T) {
      return;
    }
    throw TestFailure('expected $T, got ${error.runtimeType}: $message');
  }
  throw TestFailure('expected $T but nothing was thrown: $message');
}
