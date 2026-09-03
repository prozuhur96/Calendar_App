import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Color categoryColor;
  final bool isAllDay;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.categoryColor = Colors.blue,
    this.isAllDay = false,
  });
}