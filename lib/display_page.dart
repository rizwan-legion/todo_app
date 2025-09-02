import 'dart:convert';
import 'package:flutter/material.dart';
import 'edit_task_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList("tasks") ?? [];

    final List<Map<String, dynamic>> loadedTasks = [];

    for (final task in taskStrings) {
      try {
        final decoded = jsonDecode(task);
        if (decoded is Map<String, dynamic>) {
          loadedTasks.add(decoded);
        }
      } catch (_) {}
    }

    setState(() {
      tasks = loadedTasks;
    });
  }

  int get completedTasks =>
      tasks.where((t) => t["completed"] == true).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayTasks = tasks; // for future filtering
    final tomorrowTasks = tasks; // placeholder

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.onBackground,
        elevation: 0,
        title: const Text("Home"),
        actions: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task count
              Text(
                "You have got ${tasks.length} tasks today to complete ✏️",
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),

              // Search bar
              TextField(
                style: TextStyle(color: theme.colorScheme.onBackground),
                decoration: InputDecoration(
                  hintText: "Search Task Here",
                  hintStyle:
                  TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.search,
                      color: theme.colorScheme.onBackground.withOpacity(0.5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Progress",
                      style: TextStyle(
                          color: theme.colorScheme.onBackground, fontSize: 16)),
                  TextButton(
                    onPressed: () {},
                    child: Text("See All",
                        style: TextStyle(color: theme.colorScheme.primary)),
                  )
                ],
              ),
              Card(
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daily Task",
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$completedTasks/${tasks.length} Task Completed",
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: tasks.isEmpty ? 0 : completedTasks / tasks.length,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Today’s Task
              _buildTaskSection("Today's Task", todayTasks, theme),
              const SizedBox(height: 20),
              // Tomorrow’s Task
              _buildTaskSection("Tomorrow Task", tomorrowTasks, theme),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () async {
          await Navigator.pushNamed(context, "/create");
          _loadTasks();
        },
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildTaskSection(String title, List<Map<String, dynamic>> sectionTasks, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 16)),
            TextButton(
              onPressed: () {},
              child: Text("See All", style: TextStyle(color: theme.colorScheme.primary)),
            )
          ],
        ),
        Column(
          children: sectionTasks.map((task) {
            return Card(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                title: Text(task["name"] ?? "", style: TextStyle(color: theme.colorScheme.onBackground)),
                subtitle: Text(task["description"] ?? "",
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditTaskPage(
                        task: task,
                        index: tasks.indexOf(task),
                      ),
                    ),
                  );
                  if (updated == true) _loadTasks();
                },
                trailing: IconButton(
                  icon: Icon(
                    task["completed"] == true ? Icons.check_circle : Icons.circle_outlined,
                    color: task["completed"] == true
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: () async {
                    setState(() {
                      task["completed"] = !(task["completed"] == true);
                    });
                    final prefs = await SharedPreferences.getInstance();
                    final List<String> taskStrings =
                    tasks.map((t) => jsonEncode(t)).toList();
                    await prefs.setStringList("tasks", taskStrings);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
