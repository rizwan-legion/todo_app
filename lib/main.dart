import 'package:flutter/material.dart';
import 'create_task_page.dart';
import 'display_page.dart';
import 'theme/theme_config.dart'; // 👈 correct import

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: AppTheme.blackTheme,
      initialRoute: "/",
      routes: {
        "/": (context) => const DisplayPage(),
        "/create": (context) => const CreateTaskPage(),
      },
    );
  }
}
