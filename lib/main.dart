import 'package:flutter/material.dart';
import 'create_task_page.dart';
import 'display_page.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purpleAccent,
          brightness: Brightness.light, // Light mode
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purpleAccent,
          brightness: Brightness.dark, // Dark mode
        ),
      ),
      themeMode: ThemeMode.system, // 👈 Automatically switch based on system setting
      initialRoute: "/",
      routes: {
        "/": (context) => const DisplayPage(),
        "/create": (context) => const CreateTaskPage(),
      },
    );
  }
}
