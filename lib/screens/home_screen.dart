import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_text.dart';
import 'add_task_screen.dart';
import 'task_details_screen.dart';

import 'stats_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedTab = 'All'; // 'All', 'Pending', 'Completed'
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_bottomNavIndex == 1) {
      bodyContent = const CalendarScreen();
    } else if (_bottomNavIndex == 2) {
      bodyContent = const StatsScreen();
    } else if (_bottomNavIndex == 3) {
      bodyContent = const ProfileScreen();
    } else {
      bodyContent = SafeArea(child: _buildTasksView());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: bodyContent,
      floatingActionButton: _bottomNavIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTasksView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTabs(),
          const SizedBox(height: 24),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.tasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (provider.error != null && provider.tasks.isEmpty) {
                  return Center(child: CustomText(text: provider.error!, style: const TextStyle(color: Colors.red)));
                }
                
                final filteredTasks = _getFilteredTasks(provider.tasks);
                if (filteredTasks.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: provider.fetchTasks,
                  color: AppColors.primary,
                  child: _buildTasksList(filteredTasks),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomText(text: 'No tasks yet', style: AppStyles.heading2),
          const SizedBox(height: 8),
          const CustomText(text: 'Create your first task', style: AppStyles.subtitle),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> allTasks) {
    if (_selectedTab == 'Pending') {
      return allTasks.where((t) => !t.completed).toList();
    } else if (_selectedTab == 'Completed') {
      return allTasks.where((t) => t.completed).toList();
    }
    return allTasks;
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu, color: AppColors.textPrimary),
            const SizedBox(height: 24),
            const CustomText(text: 'My Tasks', style: AppStyles.heading1),
          ],
        ),
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['All', 'Pending', 'Completed'].map((tab) {
        final isSelected = _selectedTab == tab;
        return GestureDetector(
          onTap: () => setState(() => _selectedTab = tab),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText(
              text: tab,
              style: isSelected
                  ? AppStyles.subtitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                  : AppStyles.subtitle,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTasksList(List<TaskModel> tasks) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final tomorrowDate = DateTime.now().add(const Duration(days: 1));
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(tomorrowDate);

    final todayTasks = tasks.where((t) => t.date == todayStr).toList();
    final tomorrowTasks = tasks.where((t) => t.date == tomorrowStr).toList();
    // Catch-all for others
    final otherTasks = tasks.where((t) => t.date != todayStr && t.date != tomorrowStr).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (todayTasks.isNotEmpty) ...[
          const CustomText(text: 'Today', style: AppStyles.title),
          const SizedBox(height: 16),
          ...todayTasks.map((t) => _buildTaskItem(t, 'Today')).toList(),
        ],
        if (tomorrowTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          const CustomText(text: 'Tomorrow', style: AppStyles.title),
          const SizedBox(height: 16),
          ...tomorrowTasks.map((t) => _buildTaskItem(t, 'Tomorrow')).toList(),
        ],
        if (otherTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          const CustomText(text: 'Other Days', style: AppStyles.title),
          const SizedBox(height: 16),
          ...otherTasks.map((t) => _buildTaskItem(t, t.date)).toList(),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTaskItem(TaskModel task, String dayPrefix) {
    Color iconColor;
    Color iconBg;
    IconData iconData;

    switch (task.category.toLowerCase()) {
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                context.read<TaskProvider>().toggleTaskStatus(task).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.completed ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
                    width: 2,
                  ),
                  color: task.completed ? AppColors.primary : Colors.transparent,
                ),
                child: task.completed
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: task.title,
                    style: AppStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: task.completed ? TextDecoration.lineThrough : null,
                      color: task.completed ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: '$dayPrefix, ${task.time}',
                    style: AppStyles.caption,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.check_circle_outline, 'Tasks'),
              _buildNavItem(1, Icons.calendar_today_outlined, 'Calendar'),
              _buildNavItem(2, Icons.bar_chart, 'Stats'),
              _buildNavItem(3, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: label,
            style: AppStyles.caption.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}
