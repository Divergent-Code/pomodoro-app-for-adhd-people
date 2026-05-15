import 'dart:async';
import 'package:flutter/material.dart';

class TimerService extends ChangeNotifier {
  int _minutes = 25;
  int _seconds = 0;
  bool _isRunning = false;
  late Timer _timer;

  int get minutes => _minutes;
  int get seconds => _seconds;
  bool get isRunning => _isRunning;

  void startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_minutes == 0 && _seconds == 0) {
        stopTimer();
        _minutes = 25;
        _seconds = 0;
      } else if (_seconds == 0) {
        _minutes--;
        _seconds = 59;
      } else {
        _seconds--;
      }
      notifyListeners();
    });
  }

  void stopTimer() {
    _isRunning = false;
    _timer.cancel();
    notifyListeners();
  }

  void setTimer(int minutes) {
    _minutes = minutes;
    _seconds = 0;
    if (isRunning) {
      stopTimer();
    }
    notifyListeners();
  }

  void resetTimer() {
    if (isRunning) {
      stopTimer();
    }
    _minutes = 25;
    _seconds = 0;
    notifyListeners();
  }

  void toggleTimer() {
    if (!isRunning) startTimer();
  }
}
