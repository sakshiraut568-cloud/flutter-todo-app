import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../utils/config.dart';

class ApiService {
  Future<List<TaskModel>> fetchTasks() async {
    final response = await http.get(Uri.parse(AppConfig.baseUrl));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load tasks');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<void> addTask(TaskModel task) async {
    final response = await http.post(
      Uri.parse(AppConfig.baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 201) {
      final jsonResponse = jsonDecode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Failed to add task');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode != 200) {
      final jsonResponse = jsonDecode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Failed to update task');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      final jsonResponse = jsonDecode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Failed to delete task');
    }
  }
}
