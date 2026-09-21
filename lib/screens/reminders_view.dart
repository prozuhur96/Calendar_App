import 'package:flutter/material.dart';
import '../services/event_repository.dart';

class RemindersViewScreen extends StatefulWidget {
  final EventRepository repository;

  const RemindersViewScreen({super.key, required this.repository});

  @override
  State<RemindersViewScreen> createState() => _RemindersViewScreenState();
}

class _RemindersViewScreenState extends State<RemindersViewScreen> {
  // Dark Purple Theme Palette
  static const Color darkBg = Color(0xFF1E1035);
  static const Color headerPurple = Color(0xFF2D124D);
  static const Color accentPurple = Color(0xFFA855F7);

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: headerPurple,
        title: const Text('Add Reminder', style: TextStyle(color: Colors.white)),
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
              controller: noteController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Notes',
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
                final reminder = ReminderItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  note: noteController.text.trim(),
                  dueDate: DateTime.now(),
                );
                widget.repository.addReminder(reminder);
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
    final reminders = widget.repository.reminders;

    return Scaffold(
      backgroundColor: darkBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add_task),
      ),
      body: Column(
        children: [
          // Top Header Title Bar for Reminders
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            color: headerPurple,
            child: const Center(
              child: Text(
                'Reminders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Reminders List / Empty View
          Expanded(
            child: reminders.isEmpty
                ? const Center(
                    child: Text(
                      'No active reminders.',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final item = reminders[index];
                      return Card(
                        color: headerPurple,
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: CheckboxListTile(
                          activeColor: accentPurple,
                          checkColor: Colors.white,
                          value: item.isCompleted,
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: Colors.white,
                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.white54,
                            ),
                          ),
                          subtitle: Text(
                            item.note.isNotEmpty ? item.note : 'No notes',
                            style: const TextStyle(color: Colors.white60),
                          ),
                          onChanged: (bool? checked) {
                            widget.repository.toggleReminder(item.id, checked ?? false);
                          },
                          secondary: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              widget.repository.deleteReminder(item.id);
                            },
                          ),
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