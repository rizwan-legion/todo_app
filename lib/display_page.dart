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

    debugPrint("Raw saved tasks: $taskStrings");

    final List<Map<String, dynamic>> loadedTasks = [];

    for (final task in taskStrings) {
      try {
        final decoded = jsonDecode(task);
        if (decoded is Map<String, dynamic>) {
          loadedTasks.add(decoded);
        }
      } catch (e) {
        debugPrint("❌ Skipping invalid task: $task");
      }
    }

    debugPrint("Decoded tasks: $loadedTasks");

    setState(() {
      tasks = loadedTasks;
    });
  }


  int get completedTasks =>
      tasks
          .where((t) => t["completed"] == true)
          .length;

  @override
  Widget build(BuildContext context) {
    final todayTasks = tasks; // later filter by date if needed
    final tomorrowTasks = tasks; // placeholder

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.purpleAccent,
            child: Icon(Icons.person, color: Colors.white),
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
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 12),

              // Search bar
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search Task Here",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Progress",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  TextButton(
                    onPressed: () {},
                    child: const Text("See All",
                        style: TextStyle(color: Colors.purpleAccent)),
                  )
                ],
              ),
              Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Daily Task",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        "${completedTasks}/${tasks.length} Task Completed",
                        style: const TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: tasks.isEmpty
                            ? 0
                            : completedTasks / tasks.length,
                        color: Colors.purpleAccent,
                        backgroundColor: Colors.white12,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Today’s Task
              _buildTaskSection("Today's Task", todayTasks),
              const SizedBox(height: 20),
              // Tomorrow’s Task
              _buildTaskSection("Tomorrow Task", tomorrowTasks),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          // ✅ wait for create page then reload
          await Navigator.pushNamed(context, "/create");
          _loadTasks();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildTaskSection(String title,
      List<Map<String, dynamic>> sectionTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            TextButton(
              onPressed: () {},
              child: const Text("See All",
                  style: TextStyle(color: Colors.purpleAccent)),
            )
          ],
        ),
        Column(
          children: sectionTasks.map((task) {
            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.calendar_today,
                    color: Colors.purpleAccent),
                title: Text(task["name"] ?? "",
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(task["description"] ?? "",
                    style: const TextStyle(color: Colors.white54)),

                // ✅ Add onTap here
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditTaskPage(
                            task: task,
                            index: tasks.indexOf(task), // pass index
                          ),
                    ),
                  );

                  // ✅ If edited or deleted, reload tasks
                  if (updated == true) {
                    _loadTasks();
                  }
                },

                trailing: IconButton(
                  icon: Icon(
                    task["completed"] == true
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: task["completed"] == true
                        ? Colors.purpleAccent
                        : Colors.white54,
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
