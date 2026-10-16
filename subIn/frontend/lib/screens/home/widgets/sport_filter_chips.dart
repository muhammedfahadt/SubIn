import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/screens/home/home_sport_filter_provider.dart';

class SportFilterChips extends ConsumerWidget {
  const SportFilterChips({super.key});

  static const _sports = [
    'All Sports',
    'Football',
    'Basketball',
    'Cricket',
    'Tennis',
    'Volleyball',
    'Baseball',
    'Hockey',
    'Other'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(homeSelectedSportProvider);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sports.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final sport = _sports[index];
          final isSelected = sport == selected;
          return ChoiceChip(
            label: Text(sport),
            selected: isSelected,
            onSelected: (_) => ref.read(homeSelectedSportProvider.notifier).state = sport,
            selectedColor: AppTheme.lime,
            labelStyle: TextStyle(color: isSelected ? AppTheme.onLime : AppTheme.primaryText),
          );
        },
      ),
    );
  }
}