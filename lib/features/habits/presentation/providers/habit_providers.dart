import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_task_habit_tracker/features/habits/data/datasources/habit_local_data_source.dart';
import 'package:mini_task_habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:mini_task_habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:mini_task_habit_tracker/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:mini_task_habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:uuid/uuid.dart';

// Data Sources
final habitLocalDataSourceProvider = Provider<HabitLocalDataSource>((ref) {
  return HabitLocalDataSourceImpl();
});

final habitRemoteDataSourceProvider = Provider<HabitRemoteDataSource>((ref) {
  return HabitRemoteDataSourceImpl();
});

// Repository
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(
    localDataSource: ref.watch(habitLocalDataSourceProvider),
    remoteDataSource: ref.watch(habitRemoteDataSourceProvider),
  );
});

// Habit List State
class HabitListNotifier extends StateNotifier<AsyncValue<List<HabitModel>>> {
  final HabitRepository repository;

  HabitListNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await repository.getAllHabits();
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addHabit({required String name, required int targetDays}) async {
    final now = DateTime.now();
    final habit = HabitModel(
      id: const Uuid().v4(),
      name: name,
      targetDays: targetDays,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await repository.addHabit(habit);
      await loadHabits();
    } catch (e) {
      await loadHabits();
    }
  }

  Future<void> updateHabit(HabitModel habit) async {
    try {
      await repository.updateHabit(habit);
      await loadHabits();
    } catch (e) {
      await loadHabits();
    }
  }

  Future<void> toggleHabitCompletion(String id) async {
    try {
      await repository.toggleHabitCompletion(id);
      await loadHabits();
    } catch (e) {
      await loadHabits();
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await repository.deleteHabit(id);
      await loadHabits();
    } catch (e) {
      await loadHabits();
    }
  }
}

final habitListProvider =
    StateNotifierProvider<HabitListNotifier, AsyncValue<List<HabitModel>>>((
      ref,
    ) {
      return HabitListNotifier(ref.watch(habitRepositoryProvider));
    });

// Single Habit Provider
final singleHabitProvider = Provider.family<HabitModel?, String>((ref, id) {
  final habitsState = ref.watch(habitListProvider);
  return habitsState.valueOrNull?.firstWhere(
    (h) => h.id == id,
    orElse: () => throw Exception('Habit not found'),
  );
});
