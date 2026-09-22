// lib/models/event.dart

import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Color categoryColor;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.categoryColor = const Color(0xFF3B0764),
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'categoryColorValue': categoryColor.toARGB32(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      categoryColor: Color(json['categoryColorValue'] as int? ?? 0xFF3B0764),
    );
  }
}