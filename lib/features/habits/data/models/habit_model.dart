import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 1)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int targetDays; // 7, 21, 30

  @HiveField(3)
  List<DateTime> completedDates;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  HabitModel({
    required this.id,
    required this.name,
    required this.targetDays,
    List<DateTime>? completedDates,
    required this.createdAt,
    required this.updatedAt,
  }) : completedDates = completedDates ?? [];

  /// Calculate current streak
  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates =
        completedDates
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterday = todayNormalized.subtract(const Duration(days: 1));

    // Check if the streak is still active (completed today or yesterday)
    if (!sortedDates.contains(todayNormalized) &&
        !sortedDates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = sortedDates.first;

    for (var date in sortedDates) {
      if (date == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Check if completed today
  bool get isCompletedToday {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    return completedDates.any(
      (d) =>
          d.year == todayNormalized.year &&
          d.month == todayNormalized.month &&
          d.day == todayNormalized.day,
    );
  }

  /// Progress percentage
  double get progress {
    return (currentStreak / targetDays).clamp(0.0, 1.0);
  }

  HabitModel copyWith({
    String? id,
    String? name,
    int? targetDays,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetDays: targetDays ?? this.targetDays,
      completedDates: completedDates ?? List.from(this.completedDates),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
