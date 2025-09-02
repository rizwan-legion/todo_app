import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedPriority;
  bool alertEnabled = false;

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _saveTask() async {
    if (_nameController.text.isEmpty || selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter name and select priority")),
      );
      return;
    }

    final task = {
      "name": _nameController.text,
      "description": _descController.text,
      "startTime": startTime?.format(context) ?? "",
      "endTime": endTime?.format(context) ?? "",
      "priority": selectedPriority,
      "alert": alertEnabled,
      "completed": false,
    };

    final prefs = await SharedPreferences.getInstance();
    final List<String> tasks = prefs.getStringList("tasks") ?? [];
    tasks.add(jsonEncode(task));
    await prefs.setStringList("tasks", tasks);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Task '${_nameController.text}' saved successfully ✅")),
    );

    _nameController.clear();
    _descController.clear();
    setState(() {
      startTime = null;
      endTime = null;
      selectedPriority = null;
      alertEnabled = false;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.onBackground,
        elevation: 0,
        title: const Text("Create new task"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Schedule",
                style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Task Name
              TextField(
                controller: _nameController,
                style: TextStyle(color: theme.colorScheme.onBackground),
                decoration: InputDecoration(
                  hintText: "Name",
                  hintStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Task Description
              TextField(
                controller: _descController,
                maxLines: 3,
                style: TextStyle(color: theme.colorScheme.onBackground),
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5)),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              startTime == null ? "Start Time" : startTime!.format(context),
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              endTime == null ? "End Time" : endTime!.format(context),
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Priority buttons
              Text("Priority", style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: ["High", "Medium", "Low"].map((priority) {
                  final bool isSelected = selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                        onPressed: () => setState(() => selectedPriority = priority),
                        child: Text(
                          priority,
                          style: TextStyle(
                              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Alert toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Get alert for this task", style: TextStyle(color: theme.colorScheme.onBackground)),
                  Switch(
                    activeColor: theme.colorScheme.primary,
                    value: alertEnabled,
                    onChanged: (value) => setState(() => alertEnabled = value),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Create Task Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: _saveTask,
                  child: Text(
                    "Create Task",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
