import 'dart:convert';
import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  DateTime selectedDate = DateTime.now(); // keep only this one ✅

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? selectedPriority;
  bool alertEnabled = false;

  List<DateTime> getCurrentWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

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
      "date":
      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
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
      SnackBar(
        content: Text("Task '$tasks' saved successfully ✅"),
        duration: const Duration(seconds: 3), // 👈 stays for 3 seconds
      ),
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
    final theme = Theme.of(context);

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
                style: TextStyle(
                    color: theme.colorScheme.onBackground, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Week Selector
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                selectedDate.subtract(const Duration(days: 7));
                          });
                        },
                      ),
                      Text(
                        "${getCurrentWeek(selectedDate).first.day} "
                            "${_monthName(getCurrentWeek(selectedDate).first.month)}"
                            " - "
                            "${getCurrentWeek(selectedDate).last.day} "
                            "${_monthName(getCurrentWeek(selectedDate).last.month)}",
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                selectedDate.add(const Duration(days: 7));
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: getCurrentWeek(selectedDate).map((date) {
                      final bool isSelected = date.day == selectedDate.day &&
                          date.month == selectedDate.month &&
                          date.year == selectedDate.year;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _weekDayShort(date.weekday),
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${date.day.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onBackground,
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

              // Task Name
              // Task Name
              TextField(
                controller: _nameController,
                style: TextStyle(color: theme.colorScheme.onBackground),
                decoration: InputDecoration(
                  hintText: "Name",
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,  // ✅ light black background
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // ✅ removes outline
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
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor:AppColors.surface, // ✅ light black background
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // ✅ removes outline
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
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              startTime == null
                                  ? "Start Time"
                                  : startTime!.format(context),
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface),
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
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              endTime == null
                                  ? "End Time"
                                  : endTime!.format(context),
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface),
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
              // Priority buttons
              Text("Priority",
                  style: TextStyle(color: theme.colorScheme.onBackground, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: ["High", "Medium", "Low"].map((priority) {
                  final bool isSelected = selectedPriority == priority;

                  // Assign custom colors for each priority
                  Color priorityColor;
                  switch (priority) {
                    case "High":
                      priorityColor = Colors.red.shade200; // light red/pink
                      break;
                    case "Medium":
                      priorityColor = Colors.blue.shade200; // light blue
                      break;
                    case "Low":
                      priorityColor = const Color(0xFFE1BEE7);// light purple
                      break;
                    default:
                      priorityColor = theme.colorScheme.surface;
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected ? priorityColor : theme.colorScheme.surface,
                          side: BorderSide(
                            color: isSelected
                                ? priorityColor
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                        onPressed: () => setState(() => selectedPriority = priority),
                        child: Text(
                          priority,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.black // text visible on light color
                                : theme.colorScheme.onSurface,
                          ),
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
                  Text("Get alert for this task",
                      style: TextStyle(
                          color: theme.colorScheme.onBackground)),
                  Switch(
                    activeColor: theme.colorScheme.primary,
                    value: alertEnabled,
                    onChanged: (value) =>
                        setState(() => alertEnabled = value),
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
}
