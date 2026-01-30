import 'package:mini_task_habit_tracker/features/tasks/data/models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id);
}
