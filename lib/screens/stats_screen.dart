
import 'package:flutter/material.dart';
import 'package:pomodoro_app/services/distraction_service.dart';
import 'package:pomodoro_app/services/task_service.dart';
import 'package:pomodoro_app/services/timer_service.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    final taskService = Provider.of<TaskService>(context);
    final distractionService = Provider.of<DistractionService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pomodoro Stats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Completed Pomodoros: ${timerService.completedPomodoros}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            const Text(
              'Task Stats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Completed Tasks: ${taskService.tasks.where((task) => task.isCompleted).length}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Pending Tasks: ${taskService.tasks.where((task) => !task.isCompleted).length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            const Text(
              'Distraction Stats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Distractions: ${distractionService.distractions.length}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
