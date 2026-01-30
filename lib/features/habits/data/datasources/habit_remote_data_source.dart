import 'dart:math';
import 'package:mini_task_habit_tracker/features/habits/data/models/habit_model.dart';

/// Fake remote data source that simulates API calls with delays and random errors
abstract class HabitRemoteDataSource {
  Future<List<HabitModel>> fetchAllHabits();
  Future<HabitModel> createHabit(HabitModel habit);
  Future<HabitModel> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  final Random _random = Random();

  Duration get _randomDelay =>
      Duration(milliseconds: 200 + _random.nextInt(600));

  bool get _shouldThrowError => _random.nextDouble() < 0.2;

  void _maybeThrowError() {
    if (_shouldThrowError) {
      final errors = [
        'Network connection failed',
        'Server timeout',
        'Service unavailable',
        'Internal server error',
      ];
      throw Exception(errors[_random.nextInt(errors.length)]);
    }
  }

  @override
  Future<List<HabitModel>> fetchAllHabits() async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
    return [];
  }

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
    return habit;
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
    return habit;
  }

  @override
  Future<void> deleteHabit(String id) async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
  }
}
