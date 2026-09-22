// lib/models/habit.dart

class Habit {
  final String id;
  String title;
  String category;
  int targetDaysPerWeek;
  List<String> completedDates; // Stored as ISO date strings 'YYYY-MM-DD'
  int colorValue;

  Habit({
    required this.id,
    required this.title,
    this.category = 'General',
    this.targetDaysPerWeek = 7,
    List<String>? completedDates,
    this.colorValue = 0xFFA855F7,
  }) : completedDates = completedDates ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'targetDaysPerWeek': targetDaysPerWeek,
      'completedDates': completedDates,
      'colorValue': colorValue,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    List<String> parsedCompletedDates = [];
    if (json['completedDates'] != null && json['completedDates'] is List) {
      parsedCompletedDates = (json['completedDates'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return Habit(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      targetDaysPerWeek: json['targetDaysPerWeek'] as int? ?? 7,
      completedDates: parsedCompletedDates,
      colorValue: json['colorValue'] as int? ?? 0xFFA855F7,
    );
  }

  bool isCompletedOn(DateTime date) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return completedDates.contains(dateStr);
  }
}