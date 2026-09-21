import 'package:flutter/material.dart';
import '../services/event_repository.dart';
import 'month_view.dart';
import 'day_view.dart';
import 'reminders_view.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  final EventRepository _repository = EventRepository();

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      MonthViewScreen(repository: _repository),
      DayViewScreen(repository: _repository),
      RemindersViewScreen(repository: _repository),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1035),
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF2D124D),
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _repository,
        builder: (context, child) {
          return IndexedStack(
            index: _selectedIndex,
            children: screens,
          );
        },
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF2D124D),
          indicatorColor: const Color(0xFFA855F7),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Colors.white54);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month),
              label: 'Month',
            ),
            NavigationDestination(
              icon: Icon(Icons.today),
              label: 'Day',
            ),
            NavigationDestination(
              icon: Icon(Icons.task_alt),
              label: 'Reminders',
            ),
          ],
        ),
      ),
    );
  }
}