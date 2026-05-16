
import 'package:flutter/material.dart';
import 'package:pomodoro_app/models/distraction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DistractionService extends ChangeNotifier {
  List<Distraction> _distractions = [];

  List<Distraction> get distractions => _distractions;

  void addDistraction(String description) {
    _distractions.add(Distraction(description: description, timestamp: DateTime.now()));
    _saveDistractions();
    notifyListeners();
  }

  Future<void> initialize() async {
    await _loadDistractions();
  }

  Future<void> _saveDistractions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = Distraction.encode(_distractions);
    await prefs.setString('distractions', encodedData);
  }

  Future<void> _loadDistractions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? distractionsData = prefs.getString('distractions');
    if (distractionsData != null) {
      _distractions = Distraction.decode(distractionsData);
    }
    notifyListeners();
  }
}
