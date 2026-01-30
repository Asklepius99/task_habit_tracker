import 'dart:math';
import 'package:mini_task_habit_tracker/features/tasks/data/models/task_model.dart';

/// Fake remote data source that simulates API calls with delays and random errors
abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> fetchAllTasks();
  Future<TaskModel> fetchTaskById(String id);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Random _random = Random();

  // Simulated delay range (200ms - 800ms)
  Duration get _randomDelay =>
      Duration(milliseconds: 200 + _random.nextInt(600));

  // 20% chance of error
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
  Future<List<TaskModel>> fetchAllTasks() async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
    // In real app, this would fetch from API
    return [];
  }

  @override
  Future<TaskModel> fetchTaskById(String id) async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
    throw Exception('Task not found');
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
    return task;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    await Future.delayed(_randomDelay);
    _maybeThrowError();
  }
}
