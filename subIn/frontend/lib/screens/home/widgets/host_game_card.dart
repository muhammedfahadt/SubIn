import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/config/app_theme.dart';

class HostGameCard extends StatelessWidget {
  const HostGameCard({super.key});

  Future<void> _openCreate(BuildContext context) async {
    final created = await context.push<bool>('/create-event');
    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lowContainer,
        borderRadius: AppTheme.radiusBorder,
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.basketball, borderRadius: AppTheme.radiusBorder),
                child: const Text('INSTANT RUN'),
              ),
              const Spacer(),
              const CircleAvatar(backgroundColor: AppTheme.lime, child: Icon(Icons.add, color: AppTheme.onLime)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Hosting a run today?', style: text.titleMedium),
          const SizedBox(height: 4),
          Text("Don't wait on listings. Drop a pitch pin to summon subs in minutes.", style: text.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openCreate(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Host an Event'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scheduling is not available yet')),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.highContainer, foregroundColor: AppTheme.primaryText),
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Schedule'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}