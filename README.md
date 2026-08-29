# Calendar_App

## DESCRIPTION
A cross-platform mobile application built with Flutter and Dart to help users organize their time, habits, and daily schedules in one place. Designed to give users full control through intuitive event tracking, customizable categories, and layered scheduling views.

## KEY FEATURES
* **Layered Calendar Views:**
    * **Month View:** Clean, traditional calendar grid focusing strictly on holidays, birthdays and special occasions.
    * **Week View:** High-level daily focus view for main goals, major tasks and headlines for each day.
    * **Day View:** Deep-dive daily planner with flexible layout options (time-slotted schedules or freeform checklists).
* **Detailed Event Management:** Create items with start/end times, descriptions, color-coded categories and recurring rules.
* **Dedicated Reminders & Important Tasks:** A standalone space for high-priority tasks, deadline tracking and critical notes so key details never get lost.
* **Habits & Time-Blocking:** Integrated habit completion tools and visual block scheduling alongside regular tasks.
* **Smart Utilities & Data:** Offline-first local storage, category time analytics, weather overlays and cloud synchronization.

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
1. **Clone the repository:**
   `https://github.com/prozuhur96/Calendar_App.git`

## PROJECT STRUCTURE

```text
lib/
├── main.dart             # App entry point & initialization
├── core/                 # Shared utilities, constants, theme, & helper classes
│   ├── constants/
│   └── theme/
├── models/               # Data structures (Event, Category, Habit)
├── screens/              # UI pages / screens
│   ├── month_view.dart
│   ├── week_view.dart
│   ├── day_view.dart
│   └── reminders_view.dart
├── widgets/              # Reusable UI components (custom cards, dialogs, buttons)
└── services/             # Local storage, APIs, & state management logic
```

## ROADMAP

- [x] Initial Flutter project setup & Git repository initialization
- [x] Define application scope and UI/UX requirements
- [ ] Implement Month View (calendar grid displaying holidays & special occasions)
- [ ] Implement Week View (high-level daily focus & goal management)
- [ ] Implement Day View (detailed schedule & daily planner layouts)
- [ ] Build Dedicated Reminders & Important Tasks feature
- [ ] Integrate local storage for offline data persistence
- [ ] Add Habits & Time-Blocking tools
- [ ] Add Category Analytics & Weather integrations (Post-MVP)

## LICENSE

Distributed under the MIT License. See `LICENSE` for more information.
