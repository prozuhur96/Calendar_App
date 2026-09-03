import 'package:flutter/material.dart';
import '../models/task.dart';

class RemindersViewScreen extends StatefulWidget {
  const RemindersViewScreen({super.key});

  @override
  State<RemindersViewScreen> createState() => _RemindersViewScreenState();
}

class _RemindersViewScreenState extends State<RemindersViewScreen> {
  // Sample mock tasks using your Task model
  final List<Task> sampleTasks = [
    Task(
      id: '1',
      title: 'Setup GitHub repository',
      isCompleted: true,
      priority: TaskPriority.high,
    ),
    Task(
      id: '2',
      title: 'Build Event and Task data models',
      isCompleted: false,
      priority: TaskPriority.high,
    ),
    Task(
      id: '3',
      title: 'Implement Interactive Calendar Grid',
      isCompleted: false,
      priority: TaskPriority.medium,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleTasks.length,
        itemBuilder: (context, index) {
          final task = sampleTasks[index];
          return Card(
            child: CheckboxListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text('Priority: ${task.priority.name.toUpperCase()}'),
              value: task.isCompleted,
              onChanged: (bool? value) {
                setState(() {
                  task.toggelCompleted();
                });
              },
            ),
          );
        },
      ),
    );
  }
}