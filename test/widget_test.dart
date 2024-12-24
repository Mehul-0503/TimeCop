import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/main.dart';  // Make sure this import is correct.

void main() {
  testWidgets('Task list app smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(TimecopApp());  // Use TimecopApp() here instead of MyApp()

    // Verify that the task list is empty initially.
    expect(find.text('Timecop'), findsOneWidget);  // Checks if the app's title is displayed.
    expect(find.byIcon(Icons.add), findsOneWidget);  // Checks if the add button is present.

    // Tap the '+' icon to open the add task dialog.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the dialog appears.
    expect(find.text('Add Task'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));  // Verify if there are two text fields (name, description).

    // Enter text into the fields and add a task.
    await tester.enterText(find.byType(TextField).first, 'Test Task');
    await tester.enterText(find.byType(TextField).at(1), 'Task description');
    await tester.tap(find.text('Add'));  // Tap the add button.
    await tester.pump();  // Trigger a frame.

    // Verify that the task was added to the list.
    expect(find.text('Test Task'), findsOneWidget);  // Verify the task name appears.
    expect(find.text('Task description'), findsOneWidget);  // Verify the task description appears.
  });
}
