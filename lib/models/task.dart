import 'package:flutter/foundation.dart';
import 'task_status.dart';
import 'task_priority.dart';

class Task {
  final String id;
  String title;
  String? description;
  DateTime? dueDate;
  TaskStatus status;
  TaskPriority? priority;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.status = TaskStatus.open,
    this.priority,
  });
}
