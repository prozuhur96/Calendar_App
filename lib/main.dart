// lib/main.dart

import 'package:flutter/material.dart';
import 'services/event_repository.dart';
import 'screens/day_view.dart';
import 'screens/month_view.dart';
import 'screens/reminders_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalendarApp());
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  late final EventRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = EventRepository();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        final activeTheme = _repository.currentTheme;
        final isLight = activeTheme.isLight;
        final baseTheme = isLight ? ThemeData.light() : ThemeData.dark();

        return MaterialApp(
          title: 'Calendar App',
          debugShowCheckedModeBanner: false,
          theme: baseTheme.copyWith(
            scaffoldBackgroundColor: isLight ? Colors.white : const Color(0xFF121212),
            primaryColor: activeTheme.primaryColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: activeTheme.primaryColor,
              brightness: isLight ? Brightness.light : Brightness.dark,
              primary: activeTheme.primaryColor,
              onPrimary: activeTheme.onPrimaryColor,
              surface: activeTheme.surfaceColor,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: activeTheme.darkHeaderColor,
              foregroundColor: activeTheme.textColor,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: activeTheme.darkHeaderColor,
              selectedItemColor: activeTheme.primaryColor,
              unselectedItemColor: activeTheme.subtextColor,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: activeTheme.primaryColor,
              foregroundColor: activeTheme.onPrimaryColor,
            ),
            cardColor: activeTheme.surfaceColor,
            dialogTheme: DialogThemeData(
              backgroundColor: activeTheme.darkHeaderColor,
            ),
          ),
          home: MainNavigationShell(repository: _repository),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final EventRepository repository;

  const MainNavigationShell({super.key, required this.repository});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      MonthViewScreen(repository: widget.repository),
      DayViewScreen(repository: widget.repository),
      RemindersViewScreen(repository: widget.repository),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Day',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Reminders',
          ),
        ],
      ),
    );
  }
}