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

  /// Save task in SharedPreferences
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
      SnackBar(content: Text("Task '$task' saved successfully ✅")),
    );

    _nameController.clear();
    _descController.clear();
    setState(() {
      startTime = null;
      endTime = null;
      selectedPriority = null;
      alertEnabled = false;
    });

    Navigator.pop(context, true); // 👈 go back & trigger reload
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
              const Text("Schedule",
                  style: TextStyle(color: Colors.white, fontSize: 16)),

              const SizedBox(height: 8),
              // Task Name
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Name",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Task Description
              TextField(
                controller: _descController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.purpleAccent),
                            const SizedBox(width: 8),
                            Text(
                              startTime == null
                                  ? "Start Time"
                                  : startTime!.format(context),
                              style: const TextStyle(color: Colors.white),
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
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.purpleAccent),
                            const SizedBox(width: 8),
                            Text(
                              endTime == null
                                  ? "End Time"
                                  : endTime!.format(context),
                              style: const TextStyle(color: Colors.white),
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
              const Text("Priority",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: ["High", "Medium", "Low"].map((priority) {
                  final bool isSelected = selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                          isSelected ? Colors.purpleAccent : Colors.black,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.purpleAccent
                                : Colors.white30,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedPriority = priority;
                          });
                        },
                        child: Text(priority,
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white)),
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
                  const Text("Get alert for this task",
                      style: TextStyle(color: Colors.white)),
                  Switch(
                    activeColor: Colors.purpleAccent,
                    value: alertEnabled,
                    onChanged: (value) {
                      setState(() {
                        alertEnabled = value;
                      });
                    },
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
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveTask,
                  child: const Text("Create Task",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
