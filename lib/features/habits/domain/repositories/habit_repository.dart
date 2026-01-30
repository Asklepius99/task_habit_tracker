import 'package:mini_task_habit_tracker/features/habits/data/models/habit_model.dart';

abstract class HabitRepository {
  Future<List<HabitModel>> getAllHabits();
  Future<HabitModel?> getHabitById(String id);
  Future<void> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Future<void> toggleHabitCompletion(String id);
}
