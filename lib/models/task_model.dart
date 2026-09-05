class TaskModel {
  String id;
  String title;
  String description;
  String date; // 'YYYY-MM-DD'
  String time; // 'HH:mm'
  String priority; // 'high', 'medium', 'low'
  String category; // 'work', 'personal', 'shopping', 'health'
  bool completed;
  List<SubTask> subtasks;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.priority,
    required this.category,
    this.completed = false,
    this.subtasks = const [],
  });

  // Example factory for API JSON conversion
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      priority: _capitalize(json['priority'] ?? 'Medium'),
      category: _capitalize(json['category'] ?? 'Work'),
      completed: json['completed'] ?? false,
      subtasks: (json['subtasks'] as List?)
              ?.map((e) => SubTask.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'priority': priority.toLowerCase(),
      'category': category.toLowerCase(),
      'completed': completed,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
    };
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}

class SubTask {
  String title;
  bool isCompleted;

  SubTask({
    required this.title,
    this.isCompleted = false,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
