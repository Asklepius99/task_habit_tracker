import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_task_habit_tracker/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:mini_task_habit_tracker/features/habits/presentation/screens/habits_screen.dart';

// Current tab index
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

// Theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);
    final themeMode = ref.watch(themeModeProvider);

    final screens = const [TasksScreen(), HabitsScreen()];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentIndex == 0 ? 'Görevlerim' : 'Alışkanlıklarım'),
        actions: [
          // Theme Toggle
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                key: ValueKey(themeMode),
              ),
            ),
            onPressed: () {
              final newMode = themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeModeProvider.notifier).state = newMode;
            },
            tooltip: 'Tema değiştir',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(homeTabIndexProvider.notifier).state = index;
        },
        animationDuration: const Duration(milliseconds: 400),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Görevler',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Alışkanlıklar',
          ),
        ],
      ),
    );
  }
}
