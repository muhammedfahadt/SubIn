import 'package:flutter/material.dart';
import 'package:sub_in/config/app_theme.dart';

class HomeStatsStrip extends StatelessWidget {
  const HomeStatsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatLabel(icon: Icons.near_me_outlined, label: 'Nearby'),
        _StatLabel(icon: Icons.groups_outlined, label: 'Players'),
        _StatLabel(icon: Icons.sports_outlined, label: 'Open games'),
      ],
    );
  }
}

class _StatLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.secondaryText, size: 18),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}