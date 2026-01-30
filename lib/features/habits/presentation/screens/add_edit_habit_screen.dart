import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_task_habit_tracker/core/theme/app_theme.dart';
import 'package:mini_task_habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:mini_task_habit_tracker/features/habits/presentation/providers/habit_providers.dart';

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final String? habitId;

  const AddEditHabitScreen({super.key, this.habitId});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customDaysController = TextEditingController();
  int _targetDays = 21;
  bool _isLoading = false;
  bool _useCustomDays = false;
  HabitModel? _existingHabit;

  bool get isEditMode => widget.habitId != null;

  final List<int> _targetOptions = [7, 21, 30, 66];

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingHabit();
      });
    }
  }

  void _loadExistingHabit() {
    try {
      final habit = ref.read(singleHabitProvider(widget.habitId!));
      if (habit != null) {
        setState(() {
          _existingHabit = habit;
          _nameController.text = habit.name;
          _targetDays = habit.targetDays;
          if (!_targetOptions.contains(habit.targetDays)) {
            _useCustomDays = true;
            _customDaysController.text = habit.targetDays.toString();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Alışkanlık bulunamadı')));
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customDaysController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    int finalTargetDays = _targetDays;
    if (_useCustomDays && _customDaysController.text.isNotEmpty) {
      finalTargetDays = int.tryParse(_customDaysController.text) ?? 21;
      if (finalTargetDays < 1) finalTargetDays = 1;
      if (finalTargetDays > 365) finalTargetDays = 365;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isEditMode && _existingHabit != null) {
        final updatedHabit = _existingHabit!.copyWith(
          name: _nameController.text.trim(),
          targetDays: finalTargetDays,
          updatedAt: DateTime.now(),
        );
        await ref.read(habitListProvider.notifier).updateHabit(updatedHabit);
      } else {
        await ref
            .read(habitListProvider.notifier)
            .addHabit(
              name: _nameController.text.trim(),
              targetDays: finalTargetDays,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Alışkanlık güncellendi!'
                  : 'Alışkanlık oluşturuldu!',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Alışkanlığı Düzenle' : 'Alışkanlık Ekle'),
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
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Alışkanlık Adı',
                hintText: 'Örn: Spor yap, Kitap oku',
                prefixIcon: Icon(Icons.emoji_events_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir alışkanlık adı girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Target Days Selector
            Text(
              'Hedef Gün Sayısı',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu alışkanlığı kaç gün üst üste sürdürmek istiyorsunuz?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 16),

            // Preset options
            Row(
              children: _targetOptions.map((days) {
                final isSelected = !_useCustomDays && _targetDays == days;
                final label = switch (days) {
                  7 => 'Başlangıç',
                  21 => 'Klasik',
                  30 => 'Meydan Okuma',
                  66 => 'Uzun Vadeli',
                  _ => '$days gün',
                };
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: days != _targetOptions.last ? 8 : 0,
                    ),
                    child: InkWell(
                      onTap: () => setState(() {
                        _targetDays = days;
                        _useCustomDays = false;
                        _customDaysController.clear();
                      }),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.primaryDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected
                              ? null
                              : (isDark ? Colors.grey[800] : Colors.grey[200]),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[400]!,
                                ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$days',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white.withAlpha(200)
                                    : (isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700]),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom days input
            GestureDetector(
              onTap: () => setState(() {
                _useCustomDays = true;
              }),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _useCustomDays
                      ? AppTheme.secondaryColor
                      : (isDark ? Colors.grey[800] : Colors.grey[200]),
                  border: _useCustomDays
                      ? null
                      : Border.all(
                          color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _useCustomDays ? Icons.check_circle : Icons.edit,
                      color: _useCustomDays
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Özel:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: _useCustomDays
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sayı giriş kutusu
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _customDaysController,
                            decoration: InputDecoration(
                              hintText: '1-365',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            onTap: () => setState(() {
                              _useCustomDays = true;
                            }),
                            onChanged: (value) {
                              setState(() {
                                _useCustomDays = true;
                              });
                              if (value.isNotEmpty) {
                                final days = int.tryParse(value);
                                if (days != null && days > 0) {
                                  _targetDays = days.clamp(1, 365);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'gün',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _useCustomDays
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryColor.withAlpha(40)
                    : AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Yeni bir alışkanlık oluşturmak yaklaşık 21 gün sürer.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveHabit,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditMode
                            ? 'Alışkanlığı Güncelle'
                            : 'Alışkanlık Oluştur',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alışkanlığı Sil'),
        content: const Text(
          'Bu alışkanlığı silmek istediğinizden emin misiniz?',
        ),
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
                  .read(habitListProvider.notifier)
                  .deleteHabit(widget.habitId!);
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
