import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks() async {
    _setLoading(true);
    try {
      _tasks = await _apiService.fetchTasks();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTask(TaskModel task) async {
    _setLoading(true);
    try {
      await _apiService.addTask(task);
      _tasks.add(task);
      _error = null;
    } catch (e) {
      _error = e.toString();
      throw e; // Rethrow so UI can show snackbar
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTask(TaskModel task) async {
    _setLoading(true);
    try {
      await _apiService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTask(String id) async {
    _setLoading(true);
    try {
      await _apiService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaskStatus(TaskModel task) async {
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      date: task.date,
      time: task.time,
      priority: task.priority,
      category: task.category,
      completed: !task.completed,
      subtasks: task.subtasks,
    );
    
    // Optimistic UI update
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }

    try {
      await _apiService.updateTask(updatedTask);
    } catch (e) {
      // Revert if error
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
      throw e;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
