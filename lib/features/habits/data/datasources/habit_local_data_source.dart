import 'package:hive/hive.dart';
import 'package:mini_task_habit_tracker/features/habits/data/models/habit_model.dart';

abstract class HabitLocalDataSource {
  Future<List<HabitModel>> getAllHabits();
  Future<HabitModel?> getHabitById(String id);
  Future<void> saveHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Future<void> updateHabit(HabitModel habit);
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  static const String boxName = 'habits';

  Box<HabitModel>? _box;

  Future<Box<HabitModel>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<HabitModel>(boxName);
    return _box!;
  }

  @override
  Future<List<HabitModel>> getAllHabits() async {
    final habitBox = await box;
    return habitBox.values.toList();
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    final habitBox = await box;
    return habitBox.get(id);
  }

  @override
  Future<void> saveHabit(HabitModel habit) async {
    final habitBox = await box;
    await habitBox.put(habit.id, habit);
  }

  @override
  Future<void> deleteHabit(String id) async {
    final habitBox = await box;
    await habitBox.delete(id);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final habitBox = await box;
    await habitBox.put(habit.id, habit);
  }
}
