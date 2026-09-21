import 'package:flutter/material.dart';
import '../services/event_repository.dart';

class DayViewScreen extends StatefulWidget {
  final EventRepository repository;

  const DayViewScreen({super.key, required this.repository});

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  DateTime _currentDate = DateTime.now();

  // Dark Purple Theme Palette
  static const Color darkBg = Color(0xFF1E1035);
  static const Color headerPurple = Color(0xFF2D124D);
  static const Color accentPurple = Color(0xFFA855F7);

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
                  startTime: _currentDate,
                  endTime: _currentDate.add(const Duration(hours: 1)),
                );
                widget.repository.addEvent(_currentDate, newEvent);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.repository.getEventsForDay(_currentDate);

    return Scaffold(
      backgroundColor: darkBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Date Banner Header
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
                      _currentDate = _currentDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                Text(
                  '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentDate = _currentDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),

          // Hourly Timeline List
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, hour) {
                final hourEvents = events.where((e) => e.startTime.hour == hour).toList();

                return Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white12, width: 0.5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 55,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: hourEvents.map((event) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: headerPurple,
                                borderRadius: BorderRadius.circular(6.0),
                                border: const Border(
                                  left: BorderSide(color: accentPurple, width: 4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (event.description.isNotEmpty)
                                        Text(
                                          event.description,
                                          style: const TextStyle(fontSize: 11, color: Colors.white60),
                                        ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                    onPressed: () {
                                      widget.repository.deleteEvent(_currentDate, event.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
    );
  }
}