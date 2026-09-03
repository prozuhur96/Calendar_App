import 'package:flutter/material.dart';
import '../models/event.dart';

class MonthViewScreen extends StatelessWidget {
  const MonthViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // sample mock
    final List<Event> sampleEvents = [
      Event(
        id: '1',
        title: 'Mobile Dev Lecture',
        description: 'Covering Flutter layout and widgets',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 4)),
        categoryColor: Colors.blue,
      ),
      Event(
        id: '2',
        title: 'Project Submission',
        description: 'Push Phase 2 data models to GitHub',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
        categoryColor: Colors.purple,
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: sampleEvents.length,
                itemBuilder: (context, index) {
                  final event = sampleEvents[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: event.categoryColor,
                        radius: 8,
                      ),
                      title: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(event.description),
                      trailing: Text(
                        '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}',
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