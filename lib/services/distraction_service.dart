
import 'package:flutter/material.dart';
import 'package:pomodoro_app/models/distraction.dart';

class DistractionService extends ChangeNotifier {
  final List<Distraction> _distractions = [];

  List<Distraction> get distractions => _distractions;

  void addDistraction(String description) {
    _distractions.add(Distraction(description: description, timestamp: DateTime.now()));
    notifyListeners();
  }
}
