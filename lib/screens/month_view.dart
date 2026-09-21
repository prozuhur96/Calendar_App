import 'package:flutter/material.dart';
import '../services/event_repository.dart';

class MonthViewScreen extends StatefulWidget {
  final EventRepository repository;

  const MonthViewScreen({super.key, required this.repository});

  @override
  State<MonthViewScreen> createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // Dark Purple Theme Palette
  static const Color darkBg = Color(0xFF1E1035);
  static const Color headerPurple = Color(0xFF2D124D);
  static const Color cellBg = Color(0xFF3B1A66);
  static const Color selectedCellBg = Color(0xFF6B21A8);
  static const Color accentPurple = Color(0xFFA855F7);

  // Sunday to Saturday order
  final List<String> _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: headerPurple,
        title: const Text('Add Event', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentPurple)),
              ),
            ),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentPurple)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final newEvent = Event(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  startTime: _selectedDay,
                  endTime: _selectedDay.add(const Duration(hours: 1)),
                );
                widget.repository.addEvent(_selectedDay, newEvent);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  List<DateTime> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    // Sunday = 0 padding, Monday = 1 padding, etc.
    final leadingPadding = firstDayOfMonth.weekday % 7;

    final List<DateTime> days = [];
    final previousMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    final daysInPrevMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;

    for (int i = leadingPadding - 1; i >= 0; i--) {
      days.add(DateTime(previousMonth.year, previousMonth.month, daysInPrevMonth - i));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }

    final remainingCells = 42 - days.length;
    for (int i = 1; i <= remainingCells; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month + 1, i));
    }

    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _buildCalendarDays();
    final selectedEvents = widget.repository.getEventsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: darkBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Month Header Navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: headerPurple,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                      });
                    },
                  ),
                  Text(
                    '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                      });
                    },
                  ),
                ],
              ),
            ),

            // Sun - Sat Header Row
            Container(
              color: darkBg,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: _weekdays
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            // Month Grid with Smaller Block Height
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.45, // Higher ratio makes date cells shorter
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: calendarDays.length,
              itemBuilder: (context, index) {
                final day = calendarDays[index];
                final isCurrentMonth = day.month == _focusedMonth.month;
                final isSelected = _isSameDay(day, _selectedDay);
                final dayEvents = widget.repository.getEventsForDay(day);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = day;
                      if (!isCurrentMonth) {
                        _focusedMonth = DateTime(day.year, day.month);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? selectedCellBg
                          : isCurrentMonth
                              ? cellBg
                              : cellBg.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: isSelected ? accentPurple : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : isCurrentMonth
                                    ? Colors.white70
                                    : Colors.white24,
                          ),
                        ),
                        if (dayEvents.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: dayEvents.take(3).map((e) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1.0),
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentPurple,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Divider(color: Colors.white12, height: 12),

            // Selected Day Events List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              itemCount: selectedEvents.length,
              itemBuilder: (context, index) {
                final event = selectedEvents[index];
                return Card(
                  color: headerPurple,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 3.0),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: accentPurple,
                      radius: 5,
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                    ),
                    subtitle: Text(
                      event.description.isNotEmpty ? event.description : 'No description',
                      style: const TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                      onPressed: () {
                        widget.repository.deleteEvent(_selectedDay, event.id);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}