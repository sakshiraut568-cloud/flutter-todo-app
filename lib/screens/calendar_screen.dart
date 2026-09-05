import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_text.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CustomText(text: 'Calendar', style: AppStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;
          final Map<String, int> dateCounts = {};
          for (var task in tasks) {
            dateCounts[task.date] = (dateCounts[task.date] ?? 0) + 1;
          }
          final sortedDates = dateCounts.keys.toList()..sort();
          
          if (sortedDates.isEmpty) {
            return const Center(child: Text('No tasks scheduled.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.primary),
                        const SizedBox(width: 16),
                        CustomText(text: date, style: AppStyles.title),
                      ]
                    ),
                    CustomText(
                      text: '${dateCounts[date]} tasks', 
                      style: AppStyles.body.copyWith(color: AppColors.textSecondary)
                    ),
                  ],
                ),
              );
            },
          );
        }
      )
    );
  }
}
