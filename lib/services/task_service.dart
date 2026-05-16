
import 'package:flutter/material.dart';
import 'package:pomodoro_app/models/task.dart';

class TaskService extends ChangeNotifier {
  final List<Task> _tasks = [];
  Task? _selectedTask;

  List<Task> get tasks => _tasks;
  Task? get selectedTask => _selectedTask;

  void addTask(String title) {
    _tasks.add(Task(title: title));
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    if (_selectedTask == task) {
      _selectedTask = null;
    }
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    notifyListeners();
  }

  void selectTask(Task? task) {
    _selectedTask = task;
    notifyListeners();
  }
}
