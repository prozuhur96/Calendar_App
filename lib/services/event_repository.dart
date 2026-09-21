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
}

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
}

class EventRepository extends ChangeNotifier {
  final Map<DateTime, List<Event>> _events = {};
  final List<ReminderItem> _reminders = [];

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Event> getEventsForDay(DateTime date) {
    final key = normalizeDate(date);
    return _events[key] ?? [];
  }

  void addEvent(DateTime date, Event event) {
    final key = normalizeDate(date);
    if (_events[key] != null) {
      _events[key]!.add(event);
    } else {
      _events[key] = [event];
    }
    notifyListeners();
  }

  void deleteEvent(DateTime date, String eventId) {
    final key = normalizeDate(date);
    if (_events[key] != null) {
      _events[key]!.removeWhere((e) => e.id == eventId);
      notifyListeners();
    }
  }

  List<ReminderItem> get reminders => List.unmodifiable(_reminders);

  void addReminder(ReminderItem reminder) {
    _reminders.add(reminder);
    final calendarEvent = Event(
      id: 'rem_${reminder.id}',
      title: '🔔 ${reminder.title}',
      description: reminder.note,
      startTime: reminder.dueDate,
      endTime: reminder.dueDate.add(const Duration(minutes: 30)),
      categoryColor: const Color(0xFF581C87),
    );
    addEvent(reminder.dueDate, calendarEvent);
    notifyListeners();
  }

  void toggleReminder(String id, bool isCompleted) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isCompleted = isCompleted;
      notifyListeners();
    }
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}