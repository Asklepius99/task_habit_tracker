import 'package:flutter_test/flutter_test.dart';
import 'package:mini_task_habit_tracker/features/habits/data/models/habit_model.dart';

void main() {
  group('HabitModel', () {
    test('isCompletedToday returns true when completed today', () {
      final today = DateTime.now();
      final habit = HabitModel(
        id: 'test-1',
        name: 'Test Habit',
        targetDays: 21,
        completedDates: [today],
        createdAt: today,
        updatedAt: today,
      );

      expect(habit.isCompletedToday, isTrue);
    });

    test('isCompletedToday returns false when not completed today', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final habit = HabitModel(
        id: 'test-2',
        name: 'Test Habit',
        targetDays: 21,
        completedDates: [yesterday],
        createdAt: today,
        updatedAt: today,
      );

      expect(habit.isCompletedToday, isFalse);
    });

    test('currentStreak calculates consecutive days correctly', () {
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);
      final habit = HabitModel(
        id: 'test-3',
        name: 'Test Habit',
        targetDays: 21,
        completedDates: [
          todayNormalized,
          todayNormalized.subtract(const Duration(days: 1)),
          todayNormalized.subtract(const Duration(days: 2)),
        ],
        createdAt: today,
        updatedAt: today,
      );

      expect(habit.currentStreak, equals(3));
    });

    test('currentStreak returns 0 when no recent completions', () {
      final today = DateTime.now();
      final habit = HabitModel(
        id: 'test-4',
        name: 'Test Habit',
        targetDays: 21,
        completedDates: [today.subtract(const Duration(days: 5))],
        createdAt: today,
        updatedAt: today,
      );

      expect(habit.currentStreak, equals(0));
    });

    test('progress is calculated correctly', () {
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);
      final habit = HabitModel(
        id: 'test-5',
        name: 'Test Habit',
        targetDays: 10,
        completedDates: [
          todayNormalized,
          todayNormalized.subtract(const Duration(days: 1)),
          todayNormalized.subtract(const Duration(days: 2)),
          todayNormalized.subtract(const Duration(days: 3)),
          todayNormalized.subtract(const Duration(days: 4)),
        ],
        createdAt: today,
        updatedAt: today,
      );

      expect(habit.currentStreak, equals(5));
      expect(habit.progress, equals(0.5));
    });

    test('progress is clamped to 1.0 when exceeds target', () {
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);
      final completedDates = List.generate(
        15,
        (i) => todayNormalized.subtract(Duration(days: i)),
      );

      final habit = HabitModel(
        id: 'test-6',
        name: 'Test Habit',
        targetDays: 7,
        completedDates: completedDates,
        createdAt: today,
        updatedAt: today,
      );

      expect(habit.progress, equals(1.0));
    });
  });
}
