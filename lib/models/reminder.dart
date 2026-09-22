// lib/models/reminder.dart

class ReminderItem {
  final String id;
  String title;
  String note;
  DateTime dueDate;
  bool isCompleted;
  String priority;

  ReminderItem({
    required this.id,
    required this.title,
    this.note = '',
    required this.dueDate,
    this.isCompleted = false,
    this.priority = 'Medium',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority,
    };
  }

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] as String,
      title: json['title'] as String,
      note: (json['note'] as String?) ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      priority: (json['priority'] as String?) ?? 'Medium',
    );
  }
}