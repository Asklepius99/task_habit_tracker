import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mini_task_habit_tracker/core/theme/app_theme.dart';
import 'package:mini_task_habit_tracker/core/widgets/widgets.dart';
import 'package:mini_task_habit_tracker/features/tasks/presentation/providers/task_providers.dart';
import 'package:mini_task_habit_tracker/features/tasks/presentation/widgets/task_tile.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = switch (_tabController.index) {
        0 => TaskFilter.all,
        1 => TaskFilter.active,
        2 => TaskFilter.done,
        _ => TaskFilter.all,
      };
      ref.read(taskFilterProvider.notifier).state = filter;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getEmptyStateTitle(TaskFilter filter) {
    return switch (filter) {
      TaskFilter.all => 'Henüz görev yok',
      TaskFilter.active => 'Henüz aktif görev yok',
      TaskFilter.done => 'Henüz tamamlanmış görev yok',
    };
  }

  String _getEmptyStateSubtitle(TaskFilter filter) {
    return switch (filter) {
      TaskFilter.all => 'İlk görevinizi oluşturmak için + butonuna tıklayın',
      TaskFilter.active => 'Tüm görevlerinizi tamamladınız! 🎉',
      TaskFilter.done => 'Görevleri tamamladığınızda burada görünecek',
    };
  }

  String _getSortLabel(TaskSort sort) {
    return switch (sort) {
      TaskSort.dateDesc => 'En Yeni',
      TaskSort.dateAsc => 'En Eski',
      TaskSort.priorityHigh => 'Öncelik ↑',
      TaskSort.priorityLow => 'Öncelik ↓',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(filteredTasksProvider);
    final currentFilter = ref.watch(taskFilterProvider);
    final currentSort = ref.watch(taskSortProvider);
    final stats = ref.watch(taskStatsProvider);

    return Scaffold(
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withAlpha(180),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Görev Özeti',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.completed}/${stats.total} Tamamlandı',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular progress
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: stats.total > 0
                            ? stats.completed / stats.total
                            : 0,
                        backgroundColor: Colors.white.withAlpha(50),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 5,
                      ),
                      Text(
                        '${stats.percentage.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Görev ara...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                        .read(taskSearchQueryProvider.notifier)
                                        .state =
                                    '';
                              },
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() {});
                      ref.read(taskSearchQueryProvider.notifier).state = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Sort Dropdown
                PopupMenuButton<TaskSort>(
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sırala',
                  onSelected: (sort) {
                    ref.read(taskSortProvider.notifier).state = sort;
                  },
                  itemBuilder: (context) => TaskSort.values.map((sort) {
                    return PopupMenuItem(
                      value: sort,
                      child: Row(
                        children: [
                          if (sort == currentSort)
                            const Icon(Icons.check, size: 18)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(_getSortLabel(sort)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Filter Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(50),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurface.withAlpha(180),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Tümü'),
                Tab(text: 'Aktif'),
                Tab(text: 'Tamamlandı'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Task List
          Expanded(
            child: tasksState.when(
              loading: () =>
                  const LoadingWidget(message: 'Görevler yükleniyor...'),
              error: (error, stack) => ErrorDisplayWidget(
                message: error.toString(),
                onRetry: () => ref.read(taskListProvider.notifier).loadTasks(),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return EmptyStateWidget(
                    icon: currentFilter == TaskFilter.done
                        ? Icons.check_circle_outline
                        : Icons.task_alt,
                    title: _getEmptyStateTitle(currentFilter),
                    subtitle: _getEmptyStateSubtitle(currentFilter),
                    action: currentFilter != TaskFilter.done
                        ? ElevatedButton.icon(
                            onPressed: () => context.push('/add-task'),
                            icon: const Icon(Icons.add),
                            label: const Text('Görev Ekle'),
                          )
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(taskListProvider.notifier).loadTasks(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskTile(
                        task: task,
                        onToggle: () => ref
                            .read(taskListProvider.notifier)
                            .toggleTaskCompletion(task.id),
                        onTap: () => context.push('/edit-task/${task.id}'),
                        onDelete: () => ref
                            .read(taskListProvider.notifier)
                            .deleteTask(task.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-task'),
        icon: const Icon(Icons.add),
        label: const Text('Görev Ekle'),
      ),
    );
  }
}
