import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/navigator_key.dart';
import 'package:pomodoro_app/screens/lock_screen.dart';
import 'package:pomodoro_app/screens/settings_screen.dart';
import 'package:pomodoro_app/screens/distraction_log_screen.dart';
import 'package:pomodoro_app/screens/stats_screen.dart';
import 'package:pomodoro_app/screens/task_screen.dart';
import 'package:pomodoro_app/services/distraction_service.dart';
import 'package:pomodoro_app/services/lock_screen_service.dart';
import 'package:pomodoro_app/services/task_service.dart';
import 'screens/pomodoro_screen.dart';
import 'services/timer_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final timerService = TimerService();
  final lockScreenService = LockScreenService();
  final taskService = TaskService();
  final distractionService = DistractionService();

  await taskService.initialize();
  await distractionService.initialize();
  timerService.initialize();

  runApp(MyApp(
    timerService: timerService,
    lockScreenService: lockScreenService,
    taskService: taskService,
    distractionService: distractionService,
  ));
}

class MyApp extends StatelessWidget {
  final TimerService timerService;
  final LockScreenService lockScreenService;
  final TaskService taskService;
  final DistractionService distractionService;

  const MyApp({
    super.key,
    required this.timerService,
    required this.lockScreenService,
    required this.taskService,
    required this.distractionService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: timerService),
        ChangeNotifierProvider.value(value: lockScreenService),
        ChangeNotifierProvider.value(value: taskService),
        ChangeNotifierProvider.value(value: distractionService),
      ],
      child: Consumer<LockScreenService>(
        builder: (context, lockScreenService, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            home: lockScreenService.isLocked ? const LockScreen() : PomodoroScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/tasks': (context) => const TaskScreen(),
              '/distractions': (context) => const DistractionLogScreen(),
              '/stats': (context) => const StatsScreen(),
            },
          );
        },
      ),
    );
  }
}
