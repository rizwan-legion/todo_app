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

  List<Map<String, dynamic>> todayTasks = [];
  List<Map<String, dynamic>> tomorrowTasks = [];
  Map<String, List<Map<String, dynamic>>> futureTasks = {};

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  List<Map<String, dynamic>> _filterTasks(List<Map<String, dynamic>> taskList) {
    if (searchQuery.isEmpty) return taskList;
    return taskList.where((task) {
      final name = (task["name"] ?? "").toLowerCase();
      final desc = (task["description"] ?? "").toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || desc.contains(query);
    }).toList();
  }
  DateTime _parseDate(String dateString) {
    try {
      final parts = dateString.split("/");
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (_) {}
    return DateTime.now();
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final tTasks = <Map<String, dynamic>>[];
    final tmTasks = <Map<String, dynamic>>[];
    final futTasks = <String, List<Map<String, dynamic>>>{};

    for (var task in loadedTasks) {
      final taskDate = _parseDate(task["date"] ?? "");
      final onlyDate = DateTime(taskDate.year, taskDate.month, taskDate.day);

      if (onlyDate == today) {
        tTasks.add(task);
      } else if (onlyDate == tomorrow) {
        tmTasks.add(task);
      } else if (onlyDate.isAfter(tomorrow)) {
        final key = "${onlyDate.day}/${onlyDate.month}/${onlyDate.year}";
        futTasks.putIfAbsent(key, () => []).add(task);
      }
    }

    setState(() {
      tasks = loadedTasks;
      todayTasks = tTasks;
      tomorrowTasks = tmTasks;
      futureTasks = futTasks;
    });
  }

  int get completedTasks =>
      tasks
          .where((t) => t["completed"] == true)
          .length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ Move logic outside of widgets
    int todayCompleted =
        todayTasks.where((t) => t["completed"] == true).length;
    int todayTotal = todayTasks.length;
    double todayProgress =
    todayTotal == 0 ? 0 : todayCompleted / todayTotal;

    // Build progress message
    String progressMessage;
    if (todayTotal == 0) {
      progressMessage = "No tasks for today 🎉";
    } else if (todayProgress == 1.0) {
      progressMessage = "All tasks completed ✅ Great job!";
    } else if (todayProgress >= 0.7) {
      progressMessage = "Almost there 🎯 Keep pushing!";
    } else if (todayProgress >= 0.4) {
      progressMessage = "Good progress 👍 Stay consistent!";
    } else {
      progressMessage = "Let's get started 🚀";
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,






      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task count
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "You have got ${todayTasks.length} tasks today to complete ✏️",
                      style: TextStyle(
                        color: theme.colorScheme.onBackground,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search bar
              // Search bar
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;   // ✅ Update query
                  });
                },
                style: const TextStyle(color: Colors.white), // ✅ text color
                decoration: InputDecoration(
                  hintText: "Search Task Here",
                  hintStyle: const TextStyle(color: Colors.white54), // ✅ faded white
                  filled: true,
                  fillColor: const Color(0xFF1C1C1C),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  border: InputBorder.none, // ❌ removes outline
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // ✅ padding for better look
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Today Progress Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Progress",
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
                  color: const Color(0xFF2C2C2C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sentence + Percentage row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$todayCompleted of $todayTotal tasks completed",
                            style: TextStyle(
                              color:
                              theme.colorScheme.onSurface.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            todayTotal == 0
                                ? "0%"
                                : "${(todayProgress * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      LinearProgressIndicator(
                        value: todayProgress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.primary,
                        backgroundColor:
                        theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                      const SizedBox(height: 12),
                      // Motivational message
                      Text(
                        progressMessage,
                        style: TextStyle(
                          color:
                          theme.colorScheme.onSurface.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Today’s Task
              // Today’s Task
              _buildTaskSection("Today's Task", _filterTasks(todayTasks), theme),
              const SizedBox(height: 20),

// Tomorrow’s Task
              _buildTaskSection("Tomorrow's Task", _filterTasks(tomorrowTasks), theme),
              const SizedBox(height: 20),

// Future Tasks
              ...futureTasks.entries.map((entry) {
                return Column(
                  children: [
                    _buildTaskSection(entry.key, _filterTasks(entry.value), theme),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),

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


  Widget _buildTaskSection(String title,
      List<Map<String, dynamic>> sectionTasks, ThemeData theme) {
    if (sectionTasks.isEmpty) return const SizedBox.shrink();

    // Priority color mapping
    Color _getPriorityColor(String? priority) {
      switch (priority) {
        case "High":
          return Colors.red.shade200; // 🔴 High Priority
        case "Medium":
          return Colors.blue.shade200; // 🔵 Medium Priority
        case "Low":
          return Color(0xFFE1BEE7); // 🟣 Low Priority
        default:
          return Colors.grey; // fallback
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    color: theme.colorScheme.onBackground, fontSize: 16)),
            TextButton(
              onPressed: () {},
              child: Text("See All",
                  style: TextStyle(color: theme.colorScheme.primary)),
            )
          ],
        ),
        Column(
          children: sectionTasks.map((task) {
            final priorityColor = _getPriorityColor(task["priority"]);

            return Card(
              color: const Color(0xFF212121),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Left colored stripe
                  Container(
                    width: 10,
                    height: 80, // match ListTile height
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.calendar_today,
                          color: theme.colorScheme.primary),
                      title: Text(task["name"] ?? "",
                          style:
                          TextStyle(color: theme.colorScheme.onBackground)),
                      subtitle: Text(task["description"] ?? "",
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.7))),
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditTaskPage(
                                  task: task,
                                  index: tasks.indexOf(task),
                                ),
                          ),
                        );
                        if (updated == true) _loadTasks();
                      },
                      trailing: IconButton(
                        icon: Icon(
                          task["completed"] == true
                              ? Icons.check_circle
                              : Icons.circle_outlined,
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
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}