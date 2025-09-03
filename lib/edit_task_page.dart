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
  DateTime _selectedDate = DateTime.now();

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

    // Restore date
    if (widget.task["date"] != null && widget.task["date"].isNotEmpty) {
      final parts = widget.task["date"].split("/");
      if (parts.length == 3) {
        _selectedDate = DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    }
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
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

  // -------- Calendar Helpers ----------
  List<DateTime> getCurrentWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String _weekDayShort(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }

  // -------- Save & Delete ----------
  Future<void> _saveTask() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList("tasks") ?? [];
    final tasks = taskStrings.map((t) => jsonDecode(t)).toList();

    tasks[widget.index] = {
      "name": _titleController.text,
      "description": _descController.text,
      "priority": _priority,
      "alert": _alert,
      "date": "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
      "startTime":
      _startTime != null ? "${_startTime!.hour}:${_startTime!.minute}" : "",
      "endTime":
      _endTime != null ? "${_endTime!.hour}:${_endTime!.minute}" : "",
      "completed": widget.task["completed"] ?? false,
    };

    await prefs.setStringList(
        "tasks", tasks.map((t) => jsonEncode(t)).toList());

    Navigator.pop(context, true);
  }

  Future<void> _deleteTask() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList("tasks") ?? [];
    final tasks = taskStrings.map((t) => jsonDecode(t)).toList();

    tasks.removeAt(widget.index);

    await prefs.setStringList(
        "tasks", tasks.map((t) => jsonEncode(t)).toList());

    Navigator.pop(context, true);
  }

  // -------- UI ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

            // -------- Weekly Calendar --------
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          size: 16, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.subtract(const Duration(days: 7));
                        });
                      },
                    ),
                    Text(
                      "${getCurrentWeek(_selectedDate).first.day} "
                          "${_monthName(getCurrentWeek(_selectedDate).first.month)}"
                          " - "
                          "${getCurrentWeek(_selectedDate).last.day} "
                          "${_monthName(getCurrentWeek(_selectedDate).last.month)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedDate =
                              _selectedDate.add(const Duration(days: 7));
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: getCurrentWeek(_selectedDate).map((date) {
                    final bool isSelected =
                        date.day == _selectedDate.day &&
                            date.month == _selectedDate.month &&
                            date.year == _selectedDate.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                          isSelected ? Colors.purpleAccent : Colors.black,
                          border: Border.all(
                            color: isSelected
                                ? Colors.purpleAccent
                                : Colors.white30,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _weekDayShort(date.weekday),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${date.day.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),

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
                      icon: const Icon(Icons.access_time,
                          color: Colors.purpleAccent),
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
                      icon: const Icon(Icons.access_time,
                          color: Colors.purpleAccent),
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
                        color: _priority == level
                            ? Colors.black
                            : Colors.white),
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
