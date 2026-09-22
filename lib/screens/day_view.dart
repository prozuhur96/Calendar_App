// lib/screens/day_view.dart

import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_repository.dart';

class ReminderItem {
  final String id;
  final String title;
  final String note;
  final DateTime dueDate;
  bool isCompleted;

  ReminderItem({
    required this.id,
    required this.title,
    required this.note,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class DayViewScreen extends StatefulWidget {
  final EventRepository repository;

  const DayViewScreen({super.key, required this.repository});

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  DateTime _selectedDate = DateTime.now();

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _selectDate(BuildContext context) async {
    final theme = widget.repository.currentTheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: theme.primaryColor,
              surface: theme.darkHeaderColor,
              onSurface: theme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddDialog(BuildContext context) {
    final theme = widget.repository.currentTheme;
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    bool isReminder = false;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.darkHeaderColor,
              title: Text(
                'Add Item for ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                style: TextStyle(color: theme.textColor, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Event'),
                          selected: !isReminder,
                          selectedColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: !isReminder ? theme.onPrimaryColor : theme.textColor,
                          ),
                          onSelected: (val) {
                            if (val) setDialogState(() => isReminder = false);
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Reminder'),
                          selected: isReminder,
                          selectedColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: isReminder ? theme.onPrimaryColor : theme.textColor,
                          ),
                          onSelected: (val) {
                            if (val) setDialogState(() => isReminder = true);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: titleController,
                      style: TextStyle(color: theme.textColor),
                      decoration: InputDecoration(
                        labelText: isReminder ? 'Reminder Title' : 'Event Title',
                        labelStyle: TextStyle(color: theme.subtextColor),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.subtextColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: noteController,
                      style: TextStyle(color: theme.textColor),
                      decoration: InputDecoration(
                        labelText: isReminder ? 'Note (optional)' : 'Description (optional)',
                        labelStyle: TextStyle(color: theme.subtextColor),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.subtextColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Time: ${selectedTime.format(context)}',
                        style: TextStyle(color: theme.textColor, fontSize: 14),
                      ),
                      trailing: Icon(Icons.access_time, color: theme.primaryColor),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setDialogState(() => selectedTime = time);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: theme.subtextColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.onPrimaryColor,
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final dateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    if (isReminder) {
                      final newReminder = ReminderItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        note: noteController.text.trim(),
                        dueDate: dateTime,
                        isCompleted: false,
                      );
                      
                      // Handles both custom object types or dynamic repository addition
                      try {
                        (widget.repository as dynamic).addReminder(newReminder);
                      } catch (_) {
                        widget.repository.addEvent(
                          _selectedDate,
                          Event(
                            id: newReminder.id,
                            title: '[Reminder] ${newReminder.title}',
                            description: newReminder.note,
                            startTime: newReminder.dueDate,
                            endTime: newReminder.dueDate.add(const Duration(minutes: 30)),
                            categoryColor: theme.primaryColor,
                          ),
                        );
                      }
                    } else {
                      final newEvent = Event(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        description: noteController.text.trim(),
                        startTime: dateTime,
                        endTime: dateTime.add(const Duration(hours: 1)),
                        categoryColor: theme.primaryColor,
                      );
                      widget.repository.addEvent(_selectedDate, newEvent);
                    }

                    Navigator.pop(context);
                  },
                  child: Text(isReminder ? 'Save Reminder' : 'Save Event'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final theme = widget.repository.currentTheme;
        final dayEvents = widget.repository.getEventsForDay(_selectedDate);

        return Scaffold(
          backgroundColor: theme.isLight ? Colors.white : const Color(0xFF121212),
          floatingActionButton: FloatingActionButton(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.onPrimaryColor,
            onPressed: () => _showAddDialog(context),
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Date Header
                Container(
                  color: theme.darkHeaderColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: theme.textColor),
                        onPressed: _previousDay,
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: theme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: theme.textColor),
                        onPressed: _nextDay,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // Timeline View
                Expanded(
                  child: ListView.builder(
                    itemCount: 24,
                    itemBuilder: (context, hour) {
                      final hourEvents = dayEvents.where((e) => e.startTime.hour == hour).toList();
                      final hourLabel = '${hour.toString().padLeft(2, '0')}:00';

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.isLight ? Colors.black12 : Colors.white12,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              padding: const EdgeInsets.only(top: 8, left: 8),
                              child: Text(
                                hourLabel,
                                style: TextStyle(
                                  color: theme.subtextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(minHeight: 50),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...hourEvents.map((event) => Container(
                                          margin: const EdgeInsets.only(bottom: 4),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border(
                                              left: BorderSide(color: theme.primaryColor, width: 4),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      event.title,
                                                      style: TextStyle(
                                                        color: theme.textColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    if (event.description.isNotEmpty)
                                                      Text(
                                                        event.description,
                                                        style: TextStyle(
                                                          color: theme.subtextColor,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline,
                                                    color: Colors.redAccent, size: 16),
                                                onPressed: () {
                                                  widget.repository.deleteEvent(_selectedDate, event.id);
                                                },
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}