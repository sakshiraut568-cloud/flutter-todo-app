import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_text.dart';
import 'edit_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  void _markAsCompleted() async {
    final provider = context.read<TaskProvider>();
    try {
      await provider.toggleTaskStatus(_task);
      setState(() => _task.completed = !_task.completed);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<TaskProvider>().deleteTask(_task.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted successfully!')));
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleSubTask(int index) async {
    setState(() {
      _task.subtasks[index].isCompleted = !_task.subtasks[index].isCompleted;
    });
    try {
      await context.read<TaskProvider>().updateTask(_task);
    } catch (e) {
      setState(() {
        _task.subtasks[index].isCompleted = !_task.subtasks[index].isCompleted;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    Color iconBg;
    IconData iconData;

    switch (_task.category.toLowerCase()) {
      case 'personal':
        iconColor = AppColors.personalIcon;
        iconBg = AppColors.personalBg;
        iconData = Icons.person;
        break;
      case 'shopping':
        iconColor = AppColors.shoppingIcon;
        iconBg = AppColors.shoppingBg;
        iconData = Icons.shopping_bag;
        break;
      case 'health':
        iconColor = AppColors.healthIcon;
        iconBg = AppColors.healthBg;
        iconData = Icons.favorite;
        break;
      case 'work':
      default:
        iconColor = AppColors.workIcon;
        iconBg = AppColors.workBg;
        iconData = Icons.work;
    }

    final isLoading = context.watch<TaskProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () async {
              final updatedTask = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskScreen(task: _task),
                ),
              );
              if (updatedTask != null && updatedTask is TaskModel) {
                setState(() => _task = updatedTask);
              }
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomText(text: _task.title, style: AppStyles.heading2, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            CustomText(
                              text: '${_task.date} • ${_task.time}',
                              style: AppStyles.subtitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPriorityBadge(),
                        const SizedBox(height: 32),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomText(text: 'Description', style: AppStyles.title),
                              const SizedBox(height: 8),
                              CustomText(
                                text: _task.description,
                                style: AppStyles.body.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 24),
                              if (_task.subtasks.isNotEmpty) ...[
                                const CustomText(text: 'Subtasks', style: AppStyles.title),
                                const SizedBox(height: 16),
                                ...List.generate(_task.subtasks.length, (index) => _buildSubTaskItem(index)),
                                const SizedBox(height: 32),
                              ]
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _markAsCompleted,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : CustomText(
                                    text: _task.completed ? 'Mark as Pending' : 'Mark as Completed',
                                    style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: isLoading ? null : _deleteTask,
                          child: const CustomText(
                            text: 'Delete Task',
                            style: TextStyle(color: AppColors.highPriority, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.background,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 40, color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    final priority = _task.priority.toLowerCase();
    if (priority == 'high') color = AppColors.highPriority;
    else if (priority == 'medium') color = AppColors.mediumPriority;
    else color = AppColors.lowPriority;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: '${_task.priority} Priority',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubTaskItem(int index) {
    final subtask = _task.subtasks[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSubTask(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: subtask.isCompleted ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
                  width: 2,
                ),
                color: subtask.isCompleted ? AppColors.primary : Colors.transparent,
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              text: subtask.title,
              style: AppStyles.body.copyWith(
                decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                color: subtask.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.menu, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}
