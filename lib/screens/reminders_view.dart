// lib/screens/reminders_view.dart

import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/event_repository.dart';

class RemindersViewScreen extends StatefulWidget {
  final EventRepository repository;

  const RemindersViewScreen({super.key, required this.repository});

  @override
  State<RemindersViewScreen> createState() => _RemindersViewScreenState();
}

class _RemindersViewScreenState extends State<RemindersViewScreen> {
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

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final theme = widget.repository.currentTheme;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.darkHeaderColor,
          title: Text('New Reminder', style: TextStyle(color: theme.textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: theme.textColor),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: theme.subtextColor),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.subtextColor)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
                  ),
                ),
                TextField(
                  controller: noteController,
                  style: TextStyle(color: theme.textColor),
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    labelStyle: TextStyle(color: theme.subtextColor),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.subtextColor)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      style: TextStyle(color: theme.subtextColor),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text('Pick Date', style: TextStyle(color: theme.primaryColor)),
                    ),
                  ],
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
                  final reminder = ReminderItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    note: noteController.text.trim(),
                    dueDate: selectedDate,
                  );
                  widget.repository.addReminder(reminder);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = widget.repository.reminders;
    final theme = widget.repository.currentTheme;

    return Scaffold(
      backgroundColor: theme.isLight ? Colors.white : const Color(0xFF121212),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.onPrimaryColor,
        onPressed: _showAddReminderDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar & Theme Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: theme.darkHeaderColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminders',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.palette_outlined, color: theme.textColor),
                    tooltip: 'App Theme Palette',
                    onPressed: _showThemePickerDialog,
                  ),
                ],
              ),
            ),

            // Reminders List
            Expanded(
              child: reminders.isEmpty
                  ? Center(
                      child: Text(
                        'No reminders yet. Tap + to add one.',
                        style: TextStyle(color: theme.subtextColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            color: theme.surfaceColor,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: theme.isLight ? Colors.black12 : Colors.white12,
                            ),
                          ),
                          child: CheckboxListTile(
                            activeColor: theme.primaryColor,
                            checkColor: theme.onPrimaryColor,
                            value: reminder.isCompleted,
                            title: Text(
                              reminder.title,
                              style: TextStyle(
                                color: theme.textColor,
                                decoration: reminder.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              '${reminder.dueDate.year}-${reminder.dueDate.month.toString().padLeft(2, '0')}-${reminder.dueDate.day.toString().padLeft(2, '0')}${reminder.note.isNotEmpty ? ' • ${reminder.note}' : ''}',
                              style: TextStyle(color: theme.subtextColor, fontSize: 12),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                widget.repository.toggleReminder(reminder.id, val);
                              }
                            },
                            secondary: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                widget.repository.deleteReminder(reminder.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}