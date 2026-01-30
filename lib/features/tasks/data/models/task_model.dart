import 'package:hive/hive.dart';

part 'task_model.g.dart';

enum TaskPriority { low, medium, high }

enum TaskTag { personal, work, other }

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  int priorityIndex; // 0: low, 1: medium, 2: high

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  int tagIndex; // 0: personal, 1: work, 2: other

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priorityIndex = 0,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.tagIndex = 0,
  });

  TaskPriority get priority => TaskPriority.values[priorityIndex];
  TaskTag get tag => TaskTag.values[tagIndex];

  String get tagLabel {
    return switch (tag) {
      TaskTag.personal => 'Kişisel',
      TaskTag.work => 'İş',
      TaskTag.other => 'Diğer',
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priorityIndex,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? tagIndex,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priorityIndex: priorityIndex ?? this.priorityIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tagIndex: tagIndex ?? this.tagIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'priorityIndex': priorityIndex,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tagIndex': tagIndex,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priorityIndex: json['priorityIndex'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tagIndex: json['tagIndex'] as int? ?? 0,
    );
  }
}
