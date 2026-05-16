
import 'package:flutter/material.dart';
import 'package:pomodoro_app/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService extends ChangeNotifier {
  List<Task> _tasks = [];
  Task? _selectedTask;

  List<Task> get tasks => _tasks;
  Task? get selectedTask => _selectedTask;

  void addTask(String title) {
    _tasks.add(Task(title: title));
    _saveTasks();
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    if (_selectedTask == task) {
      _selectedTask = null;
    }
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    _saveTasks();
    notifyListeners();
  }

  void selectTask(Task? task) {
    _selectedTask = task;
    notifyListeners();
  }

  Future<void> initialize() async {
    await _loadTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = Task.encode(_tasks);
    await prefs.setString('tasks', encodedData);
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksData = prefs.getString('tasks');
    if (tasksData != null) {
      _tasks = Task.decode(tasksData);
    }
    notifyListeners();
  }
}
