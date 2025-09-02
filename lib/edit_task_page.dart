import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> task;
  final int index;

  const EditTaskPage({super.key, required this.task, required this.index});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _priority = "Medium";
  bool _alert = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task["name"]);
    _descController = TextEditingController(text: widget.task["description"]);
    _priority = widget.task["priority"] ?? "Medium";
    _alert = widget.task["alert"] ?? false;

    // Restore times
    _startTime = _parseTime(widget.task["startTime"]);
    _endTime = _parseTime(widget.task["endTime"]);
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null) return null;
    try {
      final parts = time.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return "--:--";
    final h = t.hourOfPeriod.toString().padLeft(2, "0");
    final m = t.minute.toString().padLeft(2, "0");
    final period = t.period == DayPeriod.am ? "AM" : "PM";
    return "$h:$m $period";
  }

  Future<void> _saveTask() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList("tasks") ?? [];
    final tasks = taskStrings.map((t) => jsonDecode(t)).toList();

    tasks[widget.index] = {
      "name": _titleController.text,
      "description": _descController.text,
      "priority": _priority,
      "alert": _alert,
      "startTime":
      _startTime != null ? "${_startTime!.hour}:${_startTime!.minute}" : "",
      "endTime":
      _endTime != null ? "${_endTime!.hour}:${_endTime!.minute}" : "",
      "completed": widget.task["completed"] ?? false,
    };

    await prefs.setStringList(
        "tasks", tasks.map((t) => jsonEncode(t)).toList());

    Navigator.pop(context, true); // return success
  }

  Future<void> _deleteTask() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList("tasks") ?? [];
    final tasks = taskStrings.map((t) => jsonDecode(t)).toList();

    tasks.removeAt(widget.index);

    await prefs.setStringList(
        "tasks", tasks.map((t) => jsonEncode(t)).toList());

    Navigator.pop(context, true); // return success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          _titleController.text,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Schedule",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 10),

            // Title
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: "Task Title",
                hintStyle: const TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 10),

            // Description
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: "Task Description",
                hintStyle: const TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),

            // Time Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Start Time",
                        style: TextStyle(color: Colors.white)),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _startTime = picked);
                        }
                      },
                      icon: const Icon(Icons.access_time, color: Colors.purple),
                      label: Text(_formatTime(_startTime),
                          style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("End Time",
                        style: TextStyle(color: Colors.white)),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _endTime = picked);
                        }
                      },
                      icon: const Icon(Icons.access_time, color: Colors.purple),
                      label: Text(_formatTime(_endTime),
                          style: const TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Priority
            const Text("Priority",
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: ["High", "Medium", "Low"].map((level) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(level),
                    selected: _priority == level,
                    onSelected: (selected) {
                      if (selected) setState(() => _priority = level);
                    },
                    selectedColor: Colors.purpleAccent,
                    labelStyle: TextStyle(
                        color: _priority == level ? Colors.black : Colors
                            .white),
                    backgroundColor: Colors.grey[800],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Alert toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Get alert for this task",
                    style: TextStyle(color: Colors.white)),
                Switch(
                  value: _alert,
                  onChanged: (v) => setState(() => _alert = v),
                  activeColor: Colors.purpleAccent,
                )
              ],
            ),

            const Spacer(),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                    ),
                    onPressed: _saveTask,
                    child: const Text("Edit Task",
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _deleteTask,
                    child: const Text("Delete Task",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

}
