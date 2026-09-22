// lib/screens/month_view.dart

import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_repository.dart';

class MonthViewScreen extends StatefulWidget {
  final EventRepository repository;

  const MonthViewScreen({super.key, required this.repository});

  @override
  State<MonthViewScreen> createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;

  void _showThemePickerDialog() {
    final currentTheme = widget.repository.currentTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: currentTheme.darkHeaderColor,
        title: Text('App Theme Palette', style: TextStyle(color: currentTheme.textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: EventRepository.themeOptions.map((themeOption) {
              final isSelected = currentTheme.name == themeOption.name;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: themeOption.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: currentTheme.textColor, width: 2)
                      : Border.all(color: Colors.black12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: themeOption.primaryColor,
                    radius: 14,
                  ),
                  title: Text(
                    themeOption.name,
                    style: TextStyle(color: themeOption.textColor, fontSize: 14),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: themeOption.textColor)
                      : null,
                  onTap: () {
                    widget.repository.setTheme(themeOption);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showAddEventDialog(DateTime date) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final theme = widget.repository.currentTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.darkHeaderColor,
        title: Text(
          'Add Event (${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')})',
          style: TextStyle(color: theme.textColor, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: theme.textColor),
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  labelStyle: TextStyle(color: theme.subtextColor),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.subtextColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: theme.textColor),
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: TextStyle(color: theme.subtextColor),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.subtextColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
                ),
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
              if (titleController.text.trim().isNotEmpty) {
                final newEvent = Event(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  startTime: date,
                  endTime: date.add(const Duration(hours: 1)),
                  categoryColor: theme.primaryColor,
                );
                widget.repository.addEvent(date, newEvent);
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save Event'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.repository.currentTheme;
    final int daysInMonth = DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);
    final int firstWeekday = DateTime(_focusedDate.year, _focusedDate.month, 1).weekday % 7;

    // Fetch active events and ONLY UNCOMPLETED reminders for selected date
    final selectedDateEvents = _selectedDate != null
        ? widget.repository.getEventsForDay(_selectedDate!)
        : <Event>[];

    final selectedDateActiveReminders = _selectedDate != null
        ? widget.repository.reminders
            .where((r) => DateUtils.isSameDay(r.dueDate, _selectedDate!) && !r.isCompleted)
            .toList()
        : [];

    return Scaffold(
      backgroundColor: theme.isLight ? Colors.white : const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar & Theme Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              color: theme.darkHeaderColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: theme.textColor),
                    onPressed: () {
                      setState(() {
                        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1, 1);
                      });
                    },
                  ),
                  Text(
                    '${_focusedDate.year} - ${_focusedDate.month.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.palette_outlined, color: theme.textColor),
                        tooltip: 'App Theme Palette',
                        onPressed: _showThemePickerDialog,
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: theme.textColor),
                        onPressed: () {
                          setState(() {
                            _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1, 1);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Weekday Indicators
            Container(
              color: theme.surfaceColor,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((day) => Text(
                          day,
                          style: TextStyle(color: theme.subtextColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ))
                    .toList(),
              ),
            ),

            // Top Resizable Grid View (Rectangular cells, auto-fits screen without scrolling)
            Expanded(
              flex: _selectedDate == null ? 10 : 5,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 3.0,
                  crossAxisSpacing: 3.0,
                  childAspectRatio: _selectedDate == null ? 1.4 : 1.8,
                ),
                itemCount: daysInMonth + firstWeekday,
                itemBuilder: (context, index) {
                  if (index < firstWeekday) {
                    return const SizedBox.shrink();
                  }

                  final dayNum = index - firstWeekday + 1;
                  final dayDate = DateTime(_focusedDate.year, _focusedDate.month, dayNum);
                  final isSelected = _selectedDate != null && DateUtils.isSameDay(_selectedDate!, dayDate);
                  
                  final dayEvents = widget.repository.getEventsForDay(dayDate);
                  // Ignore completed reminders for calendar indicators
                  final activeDayReminders = widget.repository.reminders
                      .where((r) => DateUtils.isSameDay(r.dueDate, dayDate) && !r.isCompleted)
                      .toList();

                  final hasActiveItems = dayEvents.isNotEmpty || activeDayReminders.isNotEmpty;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDate = null;
                        } else {
                          _selectedDate = dayDate;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : theme.surfaceColor,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: isSelected
                              ? (theme.isLight ? Colors.black : Colors.white)
                              : Colors.black12,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              color: isSelected ? theme.onPrimaryColor : theme.textColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                          if (hasActiveItems)
                            Container(
                              margin: const EdgeInsets.only(top: 2.0),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected ? theme.onPrimaryColor : theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Dynamic Panel for Selected Date
            if (_selectedDate != null)
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.darkHeaderColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border.all(color: theme.isLight ? Colors.black12 : Colors.white12),
                  ),
                  child: Column(
                    children: [
                      // Header with Date, Add Button, and Close Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: theme.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    foregroundColor: theme.onPrimaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  onPressed: () => _showAddEventDialog(_selectedDate!),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Event', style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.close, color: theme.subtextColor, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDate = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),

                      // Synced Content: Events + Active Reminders ONLY
                      Expanded(
                        child: (selectedDateEvents.isEmpty && selectedDateActiveReminders.isEmpty)
                            ? Center(
                                child: Text(
                                  'No pending events or reminders.',
                                  style: TextStyle(color: theme.subtextColor, fontSize: 13),
                                ),
                              )
                            : ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                children: [
                                  // Events
                                  ...selectedDateEvents.map((event) => Container(
                                        margin: const EdgeInsets.only(bottom: 6),
                                        decoration: BoxDecoration(
                                          color: theme.surfaceColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          leading: Icon(Icons.event, color: theme.primaryColor, size: 18),
                                          title: Text(
                                            event.title,
                                            style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: event.description.isNotEmpty
                                              ? Text(event.description, style: TextStyle(color: theme.subtextColor, fontSize: 11))
                                              : null,
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                            onPressed: () {
                                              widget.repository.deleteEvent(_selectedDate!, event.id);
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      )),

                                  // Active Reminders (Checking the box removes it instantly)
                                  ...selectedDateActiveReminders.map((reminder) => Container(
                                        margin: const EdgeInsets.only(bottom: 6),
                                        decoration: BoxDecoration(
                                          color: theme.surfaceColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: CheckboxListTile(
                                          dense: true,
                                          activeColor: theme.primaryColor,
                                          checkColor: theme.onPrimaryColor,
                                          value: reminder.isCompleted,
                                          title: Text(
                                            reminder.title,
                                            style: TextStyle(color: theme.textColor),
                                          ),
                                          subtitle: reminder.note.isNotEmpty
                                              ? Text(reminder.note, style: TextStyle(color: theme.subtextColor, fontSize: 11))
                                              : null,
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                widget.repository.toggleReminder(reminder.id, val);
                                              });
                                            }
                                          },
                                          secondary: IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                            onPressed: () {
                                              setState(() {
                                                widget.repository.deleteReminder(reminder.id);
                                              });
                                            },
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}