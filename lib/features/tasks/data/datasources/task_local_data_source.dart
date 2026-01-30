import 'package:hive/hive.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> updateTask(TaskModel task);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String boxName = 'tasks';

  Box<TaskModel>? _box;

  Future<Box<TaskModel>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<TaskModel>(boxName);
    return _box!;
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final taskBox = await box;
    return taskBox.values.toList();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    final taskBox = await box;
    return taskBox.get(id);
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final taskBox = await box;
    await taskBox.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    final taskBox = await box;
    await taskBox.delete(id);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final taskBox = await box;
    await taskBox.put(task.id, task);
  }
}
