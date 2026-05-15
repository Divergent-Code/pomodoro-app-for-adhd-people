
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_app/services/lock_screen_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  LockScreenState createState() => LockScreenState();
}

class LockScreenState extends State<LockScreen> {
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lockScreenService = Provider.of<LockScreenService>(context);

    return Scaffold(
      body: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BREAK TIME - LOCKED',
                style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text(
                '15:00', // This should be replaced with the actual timer
                style: TextStyle(fontSize: 72, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text(
                'Take a breath\nStand up & stretch\nDrink water\nLook 20ft away',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Enter unlock code',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (lockScreenService.verifyUnlockCode(_codeController.text)) {
                    // The service will notify listeners and the UI will update
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect code')),
                    );
                  }
                },
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
