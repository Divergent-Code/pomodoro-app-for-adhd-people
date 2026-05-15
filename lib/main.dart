import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/navigator_key.dart';
import 'package:pomodoro_app/screens/lock_screen.dart';
import 'package:pomodoro_app/screens/settings_screen.dart';
import 'package:pomodoro_app/services/lock_screen_service.dart';
import 'screens/pomodoro_screen.dart';
import 'services/timer_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TimerService>(create: (_) => TimerService()),
        ChangeNotifierProvider<LockScreenService>(create: (_) => LockScreenService()),
      ],
      child: Consumer<LockScreenService>(
        builder: (context, lockScreenService, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            home: lockScreenService.isLocked ? const LockScreen() : PomodoroScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
