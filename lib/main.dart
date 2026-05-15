import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/pomodoro_screen.dart';
import 'services/timer_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimerService>(
      create: (_) => TimerService(),
      child: MaterialApp(
        home: PomodoroScreen(),
      ),
    );
  }
}
