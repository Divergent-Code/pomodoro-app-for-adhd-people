// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pomodoro_app/main.dart';

import 'package:pomodoro_app/screens/pomodoro_screen.dart';
import 'package:pomodoro_app/services/distraction_service.dart';
import 'package:pomodoro_app/services/lock_screen_service.dart';
import 'package:pomodoro_app/services/task_service.dart';
import 'package:pomodoro_app/services/timer_service.dart';

void main() {
  testWidgets('PomodoroScreen is rendered', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      timerService: TimerService(),
      lockScreenService: LockScreenService(),
      taskService: TaskService(),
      distractionService: DistractionService(),
    ));

    // Verify that PomodoroScreen is rendered.
    expect(find.byType(PomodoroScreen), findsOneWidget);
  });
}
