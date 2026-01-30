import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mini_task_habit_tracker/core/router/app_router.dart';
import 'package:mini_task_habit_tracker/core/theme/app_theme.dart';
import 'package:mini_task_habit_tracker/features/tasks/data/models/task_model.dart';
import 'package:mini_task_habit_tracker/features/habits/data/models/habit_model.dart';
import 'package:mini_task_habit_tracker/features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(HabitModelAdapter());

  // Initialize Turkish date formatting
  await initializeDateFormatting('tr_TR', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Mini Task & Habit Tracker',
      debugShowCheckedModeBanner: false,

      // Turkish localization
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
