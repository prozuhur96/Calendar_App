# Calendar_App

## DESCRIPTION
A cross-platform mobile application built with Flutter and Dart to help users organize their time, habits, and daily schedules in one place. Designed to give users full control through intuitive event tracking, customizable categories, and focused scheduling views.

## KEY FEATURES
* **Focused Calendar Views:**
  * **Month View:** Clean, traditional calendar grid displaying holidays, birthdays, and special occasions.
  * **Day View:** Deep-dive daily planner with flexible layout options (time-slotted schedules or freeform checklists).
* **Home Shell Navigation:** Centralized navigation interface hosting the core calendar and reminder views.
* **Detailed Event Management:** Centralized `EventRepository` to handle creating, reading, and managing events with start/end times, descriptions, and color-coded categories.
* **Dedicated Reminders & Important Tasks:** A standalone space for high-priority tasks, deadline tracking, and critical notes so key details never get lost.
* **Habits & Time-Blocking:** Integrated habit completion tools and visual block scheduling alongside regular tasks.
* **Smart Utilities & Data:** Offline-first local storage, category time analytics, weather overlays, and cloud synchronization.

## TECH STACK
* **Framework:** Flutter
* **Language:** Dart
* **Development Environment:** Visual Studio Code
* **Version Control:** Git & GitHub

## INSTALLATION / GETTING STARTED

### Prerequisites
* Flutter SDK installed on your machine
* VS Code or Android Studio with Flutter/Dart extensions
* Git installed

### Setup & Run
1. Clone the repository:
   ```bash
   git clone [https://github.com/prozuhur96/Calendar_App.git](https://github.com/prozuhur96/Calendar_App.git)

2. Get dependencies:
    `flutter pub get`

3. Run the app:
    `flutter run -d chrome`


## PROJECT STRUCTURE

```lib/
├── main.dart             # App entry point, MaterialApp initialization, & routing
├── core/                 # Shared utilities, constants, theme, & helper classes
│   ├── constants/
│   └── theme/
├── models/               # Data structures (Event, Category, Habit)
├── repositories/         # Data management (EventRepository)
├── screens/              # UI pages / main screens
│   ├── home_shell.dart   # Main app shell & bottom navigation layout
│   ├── month_view.dart   # Month grid layout
│   ├── day_view.dart     # Detailed daily schedule
│   └── reminders_view.dart # Reminders & task tracking
├── widgets/              # Reusable UI components (custom cards, dialogs, buttons)
└── services/             # Local storage, APIs, & state management logic
```


## ROADMAP

- [x] Initial Flutter project setup & Git repository initialization
- [x] Define application scope and UI/UX requirements
- [x] Set up app entry (main.dart) and core layout shell (`home_shell.dart`)
- [x] Implement initial MonthView, DayView, and RemindersView structures
- [x] Set up EventRepository for event data handling
- [ ] Connect local storage for full offline data persistence
- [ ] Add Habits & Time-Blocking tools
- [ ] Add Category Analytics & Weather integrations (Post-MVP)

## LICENSE

Distributed under the MIT License. See `LICENSE` for more information.
