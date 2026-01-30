import 'package:flutter_test/flutter_test.dart';
import 'package:mini_task_habit_tracker/core/utils/async_state.dart';

void main() {
  group('AsyncState', () {
    test('AsyncLoading has correct properties', () {
      const state = AsyncLoading<String>();

      expect(state.isLoading, isTrue);
      expect(state.isSuccess, isFalse);
      expect(state.isError, isFalse);
      expect(state.data, isNull);
      expect(state.errorMessage, isNull);
    });

    test('AsyncSuccess has correct properties', () {
      const state = AsyncSuccess<String>('test data');

      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isTrue);
      expect(state.isError, isFalse);
      expect(state.data, equals('test data'));
      expect(state.errorMessage, isNull);
    });

    test('AsyncError has correct properties', () {
      const state = AsyncError<String>('error message');

      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isError, isTrue);
      expect(state.data, isNull);
      expect(state.errorMessage, equals('error message'));
    });

    test('when returns correct result for loading', () {
      const state = AsyncLoading<String>();

      final result = state.when(
        loading: () => 'loading',
        success: (data) => 'success: $data',
        error: (message) => 'error: $message',
      );

      expect(result, equals('loading'));
    });

    test('when returns correct result for success', () {
      const state = AsyncSuccess<String>('test data');

      final result = state.when(
        loading: () => 'loading',
        success: (data) => 'success: $data',
        error: (message) => 'error: $message',
      );

      expect(result, equals('success: test data'));
    });

    test('when returns correct result for error', () {
      const state = AsyncError<String>('something went wrong');

      final result = state.when(
        loading: () => 'loading',
        success: (data) => 'success: $data',
        error: (message) => 'error: $message',
      );

      expect(result, equals('error: something went wrong'));
    });

    test('maybeWhen returns orElse when callback not provided', () {
      const state = AsyncLoading<String>();

      final result = state.maybeWhen(
        success: (data) => 'success',
        orElse: () => 'fallback',
      );

      expect(result, equals('fallback'));
    });
  });
}
