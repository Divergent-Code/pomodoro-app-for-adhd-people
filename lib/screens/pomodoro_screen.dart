import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../widgets/custom_button.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  void _showRunningAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
              "Timer is on. You can't leave until alarm goes off. Please stay focused!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop(BuildContext context, TimerService timerService) async {
    if (timerService.isRunning) {
      _showRunningAlert(context);
      return false; // Prevent the back button from closing the app
    }
    return true; // Allow the back button to close the app
  }

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () => _onWillPop(context, timerService),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Stay Focused',
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: const SweepGradient(
                colors: [
                  Color(0xffffffff),
                  Color(0xff1e9ddc),
                  Color(0xff4cd68f)
                ],
                stops: [0, 0.5, 1],
                center: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: const Color(0xFFa6a6a6).withOpacity(1),
                  offset: const Offset(0, 8),
                  blurRadius: 50,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: SweepGradient(
              colors: [Color(0xff629d96), Color(0xff77c6ee), Color(0xff59a67e)],
              stops: [0, 0.5, 1],
              center: Alignment.center,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      onPressed: () => timerService.setTimer(5),
                      text: 'Take a Break',
                    ),
                    CustomButton(
                      onPressed: () => timerService.setTimer(15),
                      text: '15 min',
                    ),
                    CustomButton(
                      onPressed: () => timerService.setTimer(30),
                      text: '30 min',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${timerService.minutes}:${timerService.seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 132, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (timerService.isRunning) {
                          _showRunningAlert(context);
                        }
                      },
                      child: AbsorbPointer(
                        absorbing: timerService.isRunning,
                        child: CustomButton(
                          onPressed: timerService.isRunning ? null : timerService.startTimer,
                          text: 'Start',
                        ),
                      ),
                    ),
                    CustomButton(
                      onPressed: timerService.resetTimer,
                      text: 'Reset',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
