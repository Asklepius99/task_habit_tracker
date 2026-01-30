import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_task_habit_tracker/core/widgets/widgets.dart';
import 'package:mini_task_habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:mini_task_habit_tracker/features/habits/presentation/widgets/habit_tile.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitListProvider);

    return Scaffold(
      body: habitsState.when(
        loading: () =>
            const LoadingWidget(message: 'Alışkanlıklar yükleniyor...'),
        error: (error, stack) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.read(habitListProvider.notifier).loadHabits(),
        ),
        data: (habits) {
          if (habits.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.emoji_events_outlined,
              title: 'Henüz alışkanlık yok',
              subtitle: 'Bugün daha iyi alışkanlıklar edinmeye başlayın!',
              action: ElevatedButton.icon(
                onPressed: () => context.push('/add-habit'),
                icon: const Icon(Icons.add),
                label: const Text('Alışkanlık Ekle'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(habitListProvider.notifier).loadHabits(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitTile(
                  habit: habit,
                  onToggle: () => ref
                      .read(habitListProvider.notifier)
                      .toggleHabitCompletion(habit.id),
                  onTap: () => context.push('/edit-habit/${habit.id}'),
                  onDelete: () => ref
                      .read(habitListProvider.notifier)
                      .deleteHabit(habit.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-habit'),
        icon: const Icon(Icons.add),
        label: const Text('Alışkanlık Ekle'),
      ),
    );
  }
}
