import 'package:flutter/material.dart';
import 'package:mini_task_habit_tracker/core/theme/app_theme.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/models/task_model.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  Color get _priorityColor {
    return switch (task.priority) {
      TaskPriority.low => AppTheme.priorityLow,
      TaskPriority.medium => AppTheme.priorityMedium,
      TaskPriority.high => AppTheme.priorityHigh,
    };
  }

  String get _priorityLabel {
    return switch (task.priority) {
      TaskPriority.low => 'Düşük',
      TaskPriority.medium => 'Orta',
      TaskPriority.high => 'Yüksek',
    };
  }

  Color get _tagColor {
    return switch (task.tag) {
      TaskTag.personal => Colors.blue,
      TaskTag.work => Colors.orange,
      TaskTag.other => Colors.purple,
    };
  }

  IconData get _tagIcon {
    return switch (task.tag) {
      TaskTag.personal => Icons.person,
      TaskTag.work => Icons.work,
      TaskTag.other => Icons.more_horiz,
    };
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text(
          '"${task.title}" görevini silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Görevi Sil'),
                content: Text(
                  '"${task.title}" görevini silmek istediğinizden emin misiniz?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                    ),
                    child: const Text('Sil'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showDeleteConfirmation(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox with animation
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? AppTheme.secondaryColor
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                              ? AppTheme.secondaryColor
                              : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Task Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withAlpha(127)
                                    : null,
                              ),
                        ),
                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(153),
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: task.isCompleted
                                    ? AppTheme.secondaryColor.withAlpha(38)
                                    : Colors.blue.withAlpha(38),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    size: 12,
                                    color: task.isCompleted
                                        ? AppTheme.secondaryColor
                                        : Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.isCompleted ? 'Tamamlandı' : 'Aktif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: task.isCompleted
                                          ? AppTheme.secondaryColor
                                          : Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Priority Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _priorityColor.withAlpha(38),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _priorityLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _priorityColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Tag Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _tagColor.withAlpha(38),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_tagIcon, size: 12, color: _tagColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    task.tagLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _tagColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Due Date
                            if (task.dueDate != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: _isOverdue(task.dueDate!)
                                    ? AppTheme.errorColor
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withAlpha(127),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'd MMM',
                                  'tr_TR',
                                ).format(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isOverdue(task.dueDate!)
                                      ? AppTheme.errorColor
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withAlpha(127),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(76),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }
}
