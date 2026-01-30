import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mini_task_habit_tracker/features/splash/presentation/screens/splash_screen.dart';
import 'package:mini_task_habit_tracker/features/home/presentation/screens/home_screen.dart';
import 'package:mini_task_habit_tracker/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:mini_task_habit_tracker/features/habits/presentation/screens/add_edit_habit_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-task',
        name: 'add-task',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddEditTaskScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/edit-task/:id',
        name: 'edit-task',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: AddEditTaskScreen(taskId: state.pathParameters['id']),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/add-habit',
        name: 'add-habit',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddEditHabitScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/edit-habit/:id',
        name: 'edit-habit',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: AddEditHabitScreen(habitId: state.pathParameters['id']),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
    ],
  );
}
