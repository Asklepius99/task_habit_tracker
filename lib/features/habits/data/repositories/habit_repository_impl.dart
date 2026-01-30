import 'package:mini_task_habit_tracker/features/habits/data/datasources/habit_local_data_source.dart';
import 'package:mini_task_habit_tracker/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:mini_task_habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:mini_task_habit_tracker/features/habits/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;
  final HabitRemoteDataSource remoteDataSource;

  HabitRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<HabitModel>> getAllHabits() async {
    try {
      await remoteDataSource.fetchAllHabits();
    } catch (e) {
      // Continue with local data
    }

    final habits = await localDataSource.getAllHabits();
    habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return habits;
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    return await localDataSource.getHabitById(id);
  }

  @override
  Future<void> addHabit(HabitModel habit) async {
    try {
      await remoteDataSource.createHabit(habit);
    } catch (e) {
      // Continue with local storage
    }

    await localDataSource.saveHabit(habit);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final updatedHabit = habit.copyWith(updatedAt: DateTime.now());

    try {
      await remoteDataSource.updateHabit(updatedHabit);
    } catch (e) {
      // Continue with local storage
    }

    await localDataSource.updateHabit(updatedHabit);
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await remoteDataSource.deleteHabit(id);
    } catch (e) {
      // Continue with local storage
    }

    await localDataSource.deleteHabit(id);
  }

  @override
  Future<void> toggleHabitCompletion(String id) async {
    final habit = await localDataSource.getHabitById(id);
    if (habit == null) return;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    List<DateTime> updatedDates = List.from(habit.completedDates);

    if (habit.isCompletedToday) {
      // Remove today's completion
      updatedDates.removeWhere(
        (d) =>
            d.year == todayNormalized.year &&
            d.month == todayNormalized.month &&
            d.day == todayNormalized.day,
      );
    } else {
      // Add today's completion
      updatedDates.add(todayNormalized);
    }

    final updatedHabit = habit.copyWith(
      completedDates: updatedDates,
      updatedAt: DateTime.now(),
    );

    await localDataSource.updateHabit(updatedHabit);
  }
}
