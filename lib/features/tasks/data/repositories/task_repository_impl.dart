import 'package:mini_task_habit_tracker/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/models/task_model.dart';
import 'package:mini_task_habit_tracker/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      // Simulate remote API call (will randomly throw errors)
      await remoteDataSource.fetchAllTasks();
    } catch (e) {
      // Log error but continue with local data
      // In a real app, you might want to show a sync status
    }

    // Return local data
    final tasks = await localDataSource.getAllTasks();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    return await localDataSource.getTaskById(id);
  }

  @override
  Future<void> addTask(TaskModel task) async {
    // Try to sync with remote
    try {
      await remoteDataSource.createTask(task);
    } catch (e) {
      // Continue with local storage even if remote fails
    }

    await localDataSource.saveTask(task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());

    try {
      await remoteDataSource.updateTask(updatedTask);
    } catch (e) {
      // Continue with local storage
    }

    await localDataSource.updateTask(updatedTask);
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
    } catch (e) {
      // Continue with local storage
    }

    await localDataSource.deleteTask(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final task = await localDataSource.getTaskById(id);
    if (task != null) {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );
      await localDataSource.updateTask(updatedTask);
    }
  }
}
