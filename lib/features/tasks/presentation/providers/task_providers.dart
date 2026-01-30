import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/models/task_model.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:mini_task_habit_tracker/features/tasks/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

// Data Sources
final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl();
});

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl();
});

// Repository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    localDataSource: ref.watch(taskLocalDataSourceProvider),
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
  );
});

// Task Filter
enum TaskFilter { all, active, done }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

// Task Sort
enum TaskSort { dateDesc, dateAsc, priorityHigh, priorityLow }

final taskSortProvider = StateProvider<TaskSort>((ref) => TaskSort.dateDesc);

// Search Query
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

// Task List State
class TaskListNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskRepository repository;

  TaskListNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    int priorityIndex = 0,
    int tagIndex = 0,
  }) async {
    final now = DateTime.now();
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priorityIndex: priorityIndex,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      tagIndex: tagIndex,
    );

    try {
      await repository.addTask(task);
      await loadTasks();
    } catch (e) {
      // Reload to show current state
      await loadTasks();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await repository.updateTask(task);
      await loadTasks();
    } catch (e) {
      await loadTasks();
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    try {
      await repository.toggleTaskCompletion(id);
      await loadTasks();
    } catch (e) {
      await loadTasks();
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await repository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      await loadTasks();
    }
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, AsyncValue<List<TaskModel>>>((ref) {
      return TaskListNotifier(ref.watch(taskRepositoryProvider));
    });

// Task Statistics Provider
final taskStatsProvider =
    Provider<({int total, int completed, double percentage})>((ref) {
      final tasksState = ref.watch(taskListProvider);
      return tasksState.when(
        loading: () => (total: 0, completed: 0, percentage: 0.0),
        error: (_, _) => (total: 0, completed: 0, percentage: 0.0),
        data: (tasks) {
          final total = tasks.length;
          final completed = tasks.where((t) => t.isCompleted).length;
          final percentage = total > 0 ? (completed / total) * 100 : 0.0;
          return (total: total, completed: completed, percentage: percentage);
        },
      );
    });

// Filtered and Searched Tasks
final filteredTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksState = ref.watch(taskListProvider);
  final filter = ref.watch(taskFilterProvider);
  final sort = ref.watch(taskSortProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider).toLowerCase();

  return tasksState.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
    data: (tasks) {
      var filteredTasks = tasks.toList();

      // Apply filter
      filteredTasks = switch (filter) {
        TaskFilter.all => filteredTasks,
        TaskFilter.active =>
          filteredTasks.where((t) => !t.isCompleted).toList(),
        TaskFilter.done => filteredTasks.where((t) => t.isCompleted).toList(),
      };

      // Apply search
      if (searchQuery.isNotEmpty) {
        filteredTasks = filteredTasks
            .where((t) => t.title.toLowerCase().contains(searchQuery))
            .toList();
      }

      // Apply sort
      filteredTasks = switch (sort) {
        TaskSort.dateDesc =>
          filteredTasks..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        TaskSort.dateAsc =>
          filteredTasks..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
        TaskSort.priorityHigh =>
          filteredTasks
            ..sort((a, b) => b.priorityIndex.compareTo(a.priorityIndex)),
        TaskSort.priorityLow =>
          filteredTasks
            ..sort((a, b) => a.priorityIndex.compareTo(b.priorityIndex)),
      };

      return AsyncValue.data(filteredTasks);
    },
  );
});

// Single Task Provider
final singleTaskProvider = Provider.family<TaskModel?, String>((ref, id) {
  final tasksState = ref.watch(taskListProvider);
  return tasksState.valueOrNull?.firstWhere(
    (t) => t.id == id,
    orElse: () => throw Exception('Task not found'),
  );
});
