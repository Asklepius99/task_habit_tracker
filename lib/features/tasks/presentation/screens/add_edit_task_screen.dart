import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mini_task_habit_tracker/core/theme/app_theme.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/models/task_model.dart';
import 'package:mini_task_habit_tracker/features/tasks/presentation/providers/task_providers.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const AddEditTaskScreen({super.key, this.taskId});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  int _priorityIndex = 0;
  int _tagIndex = 0;
  bool _isLoading = false;
  TaskModel? _existingTask;

  bool get isEditMode => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingTask();
      });
    }
  }

  void _loadExistingTask() {
    try {
      final task = ref.read(singleTaskProvider(widget.taskId!));
      if (task != null) {
        setState(() {
          _existingTask = task;
          _titleController.text = task.title;
          _descriptionController.text = task.description ?? '';
          _dueDate = task.dueDate;
          _priorityIndex = task.priorityIndex;
          _tagIndex = task.tagIndex;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Görev bulunamadı')));
      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (isEditMode && _existingTask != null) {
        final updatedTask = _existingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueDate: _dueDate,
          priorityIndex: _priorityIndex,
          tagIndex: _tagIndex,
          updatedAt: DateTime.now(),
        );
        await ref.read(taskListProvider.notifier).updateTask(updatedTask);
      } else {
        await ref
            .read(taskListProvider.notifier)
            .addTask(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              dueDate: _dueDate,
              priorityIndex: _priorityIndex,
              tagIndex: _tagIndex,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode ? 'Görev güncellendi!' : 'Görev oluşturuldu!',
            ),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Görevi Düzenle' : 'Görev Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor,
              ),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title Field - Turkish character support
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı',
                hintText: 'Görev başlığını girin',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              enableSuggestions: true,
              autocorrect: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir başlık girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Description Field - Turkish character support
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (isteğe bağlı)',
                hintText: 'Görev açıklamasını girin',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              enableSuggestions: true,
              autocorrect: true,
            ),
            const SizedBox(height: 20),

            // Due Date Picker
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withAlpha(127),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bitiş Tarihi',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(153),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dueDate != null
                                ? DateFormat(
                                    'EEEE, d MMM yyyy',
                                    'tr_TR',
                                  ).format(_dueDate!)
                                : 'Bitiş tarihi belirlenmedi',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    if (_dueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dueDate = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tag Selector
            Text(
              'Etiket',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTagChip(0, 'Kişisel', Icons.person, Colors.blue),
                const SizedBox(width: 12),
                _buildTagChip(1, 'İş', Icons.work, Colors.orange),
                const SizedBox(width: 12),
                _buildTagChip(2, 'Diğer', Icons.more_horiz, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),

            // Priority Selector
            Text(
              'Öncelik',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPriorityChip(0, 'Düşük', AppTheme.priorityLow),
                const SizedBox(width: 12),
                _buildPriorityChip(1, 'Orta', AppTheme.priorityMedium),
                const SizedBox(width: 12),
                _buildPriorityChip(2, 'Yüksek', AppTheme.priorityHigh),
              ],
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEditMode ? 'Görevi Güncelle' : 'Görev Oluştur'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(int index, String label, IconData icon, Color color) {
    final isSelected = _tagIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tagIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(50) : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? color
                  : Theme.of(context).colorScheme.outline.withAlpha(76),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurface.withAlpha(127),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(int index, String label, Color color) {
    final isSelected = _priorityIndex == index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: () => setState(() => _priorityIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(50) : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.outline.withAlpha(76),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface.withAlpha(127),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? color
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: const Text('Bu görevi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await ref
                  .read(taskListProvider.notifier)
                  .deleteTask(widget.taskId!);
              if (mounted) {
                navigator.pop();
              }
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
}
