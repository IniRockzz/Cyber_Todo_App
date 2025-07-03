import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_status.dart';
import '../models/task_priority.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  List<Task> get openTasks =>
      _tasks.where((t) => t.status == TaskStatus.open).toList();

  List<Task> get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.complete).toList();

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].status = _tasks[index].status == TaskStatus.open
          ? TaskStatus.complete
          : TaskStatus.open;
      notifyListeners();
    }
  }

  void refresh() {
    notifyListeners();
  }
}
