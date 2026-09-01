import 'package:flutter/material.dart';

import 'month_view.dart';
import 'week_view.dart';
import 'day_view.dart';
import 'reminders_view.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  // List of screens corresponding to each bottom bar tab
  final List<Widget> _screens = const [
    MonthViewScreen(),
    WeekViewScreen(),
    DayViewScreen(),
    RemindersViewScreen(),
  ];

  // List of titles for the AppBar
  final List<String> _titles = const [
    'Month View',
    'Week View',
    'Day View',
    'Reminders & Tasks',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
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
            icon: Icon(Icons.calendar_view_week),
            label: 'Week',
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
    );
  }
}