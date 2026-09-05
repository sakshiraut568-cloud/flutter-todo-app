import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_text.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CustomText(text: 'Statistics', style: AppStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final total = provider.tasks.length;
          final completed = provider.tasks.where((t) => t.completed).length;
          final pending = total - completed;
          final high = provider.tasks.where((t) => t.priority.toLowerCase() == 'high').length;
          final medium = provider.tasks.where((t) => t.priority.toLowerCase() == 'medium').length;
          final low = provider.tasks.where((t) => t.priority.toLowerCase() == 'low').length;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildStatCard('Total Tasks', total.toString(), Colors.blue),
                const SizedBox(height: 16),
                _buildStatCard('Completed', completed.toString(), Colors.green),
                const SizedBox(height: 16),
                _buildStatCard('Pending', pending.toString(), Colors.orange),
                const SizedBox(height: 16),
                _buildStatCard('High Priority', high.toString(), Colors.red),
                const SizedBox(height: 16),
                _buildStatCard('Medium Priority', medium.toString(), Colors.orange),
                const SizedBox(height: 16),
                _buildStatCard('Low Priority', low.toString(), Colors.green),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: title, style: AppStyles.title),
          CustomText(text: count, style: AppStyles.heading1.copyWith(color: color)),
        ],
      ),
    );
  }
}
