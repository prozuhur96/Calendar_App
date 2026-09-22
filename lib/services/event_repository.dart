// lib/services/event_repository.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/reminder.dart';
import '../models/habit.dart';

class ThemeOption {
  final String name;
  final Color primaryColor;
  final Color darkHeaderColor;
  final Color surfaceColor;
  final bool isLight;

  const ThemeOption({
    required this.name,
    required this.primaryColor,
    required this.darkHeaderColor,
    required this.surfaceColor,
    required this.isLight,
  });

  Color get textColor => isLight ? Colors.black87 : Colors.white;
  Color get subtextColor => isLight ? Colors.black54 : Colors.white70;

  // Determines text color on top of primary colored buttons/cards
  Color get onPrimaryColor {
    return ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}

class EventRepository extends ChangeNotifier {
  static const String _eventsKey = 'app_events_v1';
  static const String _remindersKey = 'app_reminders_v1';
  static const String _habitsKey = 'app_habits_v1';
  static const String _themeColorKey = 'app_theme_color_v1';

  final Map<DateTime, List<Event>> _events = {};
  final List<ReminderItem> _reminders = [];
  final List<Habit> _habits = [];
  bool _isLoading = true;

  static const List<ThemeOption> themeOptions = [
    ThemeOption(
      name: 'Dark Mode',
      primaryColor: Color(0xFFFFFFFF),
      darkHeaderColor: Color(0xFF181818),
      surfaceColor: Color(0xFF262626),
      isLight: false,
    ),
    ThemeOption(
      name: 'Light Mode',
      primaryColor: Color(0xFF000000),
      darkHeaderColor: Color(0xFFE5E5E5),
      surfaceColor: Color(0xFFF5F5F5),
      isLight: true,
    ),
    ThemeOption(
      name: 'Deep Purple',
      primaryColor: Color(0xFFA855F7),
      darkHeaderColor: Color(0xFF2D124D),
      surfaceColor: Color(0xFF3B1A66),
      isLight: false,
    ),
    ThemeOption(
      name: 'Electric Blue',
      primaryColor: Color(0xFF3B82F6),
      darkHeaderColor: Color(0xFF1E3A8A),
      surfaceColor: Color(0xFF1E293B),
      isLight: false,
    ),
    ThemeOption(
      name: 'Emerald Green',
      primaryColor: Color(0xFF10B981),
      darkHeaderColor: Color(0xFF064E3B),
      surfaceColor: Color(0xFF065F46),
      isLight: false,
    ),
    ThemeOption(
      name: 'Sunset Amber',
      primaryColor: Color(0xFFF59E0B),
      darkHeaderColor: Color(0xFF78350F),
      surfaceColor: Color(0xFF451A03),
      isLight: false,
    ),
    ThemeOption(
      name: 'Rose Pink',
      primaryColor: Color(0xFFEC4899),
      darkHeaderColor: Color(0xFF831843),
      surfaceColor: Color(0xFF500724),
      isLight: false,
    ),
    ThemeOption(
      name: 'Cyan Blue',
      primaryColor: Color(0xFF06B6D4),
      darkHeaderColor: Color(0xFF164E63),
      surfaceColor: Color(0xFF083344),
      isLight: false,
    ),
  ];

  ThemeOption _currentTheme = themeOptions[0];
  ThemeOption get currentTheme => _currentTheme;

  bool get isLoading => _isLoading;
  List<ReminderItem> get reminders => List.unmodifiable(_reminders);
  List<Habit> get habits => List.unmodifiable(_habits);

  EventRepository() {
    loadDataFromDisk();
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<Event> getEventsForDay(DateTime date) {
    final key = normalizeDate(date);
    return List.unmodifiable(_events[key] ?? []);
  }

  // --- Persistence Handlers ---

  Future<void> loadDataFromDisk() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final String? savedThemeName = prefs.getString(_themeColorKey);
      if (savedThemeName != null) {
        _currentTheme = themeOptions.firstWhere(
          (t) => t.name == savedThemeName,
          orElse: () => themeOptions[0],
        );
      }

      final String? rawEvents = prefs.getString(_eventsKey);
      if (rawEvents != null) {
        final List<dynamic> decoded = jsonDecode(rawEvents) as List<dynamic>;
        _events.clear();
        for (var item in decoded) {
          final event = Event.fromJson(item as Map<String, dynamic>);
          final key = normalizeDate(event.startTime);
          _events.putIfAbsent(key, () => []).add(event);
        }
      }

      final String? rawReminders = prefs.getString(_remindersKey);
      if (rawReminders != null) {
        final List<dynamic> decoded = jsonDecode(rawReminders) as List<dynamic>;
        _reminders.clear();
        _reminders.addAll(
          decoded.map((r) => ReminderItem.fromJson(r as Map<String, dynamic>)),
        );
      }

      final String? rawHabits = prefs.getString(_habitsKey);
      if (rawHabits != null) {
        final List<dynamic> decoded = jsonDecode(rawHabits) as List<dynamic>;
        _habits.clear();
        _habits.addAll(
          decoded.map((h) => Habit.fromJson(h as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      debugPrint('Error loading state from disk: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveEventsToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Event> allEvents = _events.values.expand((element) => element).toList();
      final String encoded = jsonEncode(allEvents.map((Event e) => e.toJson()).toList());
      await prefs.setString(_eventsKey, encoded);
    } catch (e) {
      debugPrint('Error saving events: $e');
    }
  }

  Future<void> _saveRemindersToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_reminders.map((ReminderItem r) => r.toJson()).toList());
      await prefs.setString(_remindersKey, encoded);
    } catch (e) {
      debugPrint('Error saving reminders: $e');
    }
  }

  Future<void> _saveHabitsToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_habits.map((Habit h) => h.toJson()).toList());
      await prefs.setString(_habitsKey, encoded);
    } catch (e) {
      debugPrint('Error saving habits: $e');
    }
  }

  // --- Theme Selection Handler ---

  Future<void> setTheme(ThemeOption theme) async {
    _currentTheme = theme;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeColorKey, theme.name);
    } catch (e) {
      debugPrint('Error saving theme option: $e');
    }
  }

  // --- Event Operations ---

  Future<void> addEvent(DateTime date, Event event) async {
    final key = normalizeDate(date);
    if (_events[key] != null) {
      _events[key]!.add(event);
    } else {
      _events[key] = [event];
    }
    notifyListeners();
    await _saveEventsToDisk();
  }

  Future<void> deleteEvent(DateTime date, String eventId) async {
    final key = normalizeDate(date);
    if (_events[key] != null) {
      _events[key]!.removeWhere((e) => e.id == eventId);
      notifyListeners();
      await _saveEventsToDisk();
    }
  }

  // --- Reminder Operations ---

  Future<void> addReminder(ReminderItem reminder) async {
    _reminders.add(reminder);
    final calendarEvent = Event(
      id: 'rem_${reminder.id}',
      title: '🔔 ${reminder.title}',
      description: reminder.note,
      startTime: reminder.dueDate,
      endTime: reminder.dueDate.add(const Duration(minutes: 30)),
      categoryColor: _currentTheme.primaryColor,
    );
    await addEvent(reminder.dueDate, calendarEvent);
    await _saveRemindersToDisk();
  }

  Future<void> toggleReminder(String id, bool isCompleted) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isCompleted = isCompleted;
      notifyListeners();
      await _saveRemindersToDisk();
    }
  }

  Future<void> deleteReminder(String id) async {
    final reminderIndex = _reminders.indexWhere((r) => r.id == id);
    if (reminderIndex != -1) {
      final reminder = _reminders[reminderIndex];
      _reminders.removeAt(reminderIndex);
      await deleteEvent(reminder.dueDate, 'rem_${reminder.id}');
      await _saveRemindersToDisk();
    }
  }

  // --- Habit Operations ---

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    notifyListeners();
    await _saveHabitsToDisk();
  }

  Future<void> toggleHabitForDate(String habitId, DateTime date) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final habit = _habits[index];
      if (habit.completedDates.contains(dateStr)) {
        habit.completedDates.remove(dateStr);
      } else {
        habit.completedDates.add(dateStr);
      }
      notifyListeners();
      await _saveHabitsToDisk();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
    await _saveHabitsToDisk();
  }
}