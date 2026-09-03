import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  bool isCompleted;
  final TaskPriority priority;
  final Color categoryColor;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.categoryColor = Colors.blue,
  });

  // helper method to easily toggle completion status
  void toggelCompleted() {
    isCompleted = !isCompleted;
  }
}