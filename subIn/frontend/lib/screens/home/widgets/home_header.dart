import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/providers/auth_provider.dart';

class HomeHeader extends ConsumerWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onLocationTap;
  final VoidCallback onProfileTap;

  const HomeHeader({
    super.key,
    required this.onNotificationTap,
    required this.onLocationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final userName = ref.watch(authNotifierProvider.select((state) => state.value?.userName));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('SubIn', style: text.titleLarge?.copyWith(color: AppTheme.lime)),
            const Spacer(),
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationTap,
            ),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(20),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.highContainer,
                child: Icon(Icons.person_outline, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onLocationTap,
          borderRadius: AppTheme.radiusBorder,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.lowContainer,
              borderRadius: AppTheme.radiusBorder,
              border: Border.all(color: AppTheme.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, color: AppTheme.lime, size: 18),
                const SizedBox(width: 8),
                Text('Kerala, India', style: text.titleSmall),
                const SizedBox(width: 8),
                Text('\u2022 Near you', style: text.bodySmall),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          userName == null || userName.isEmpty ? 'Ready to play!' : 'Ready to play, $userName!',
          style: text.headlineSmall,
        ),
        const SizedBox(height: 4),
        Semantics(
          label: 'Athlete celebration animation',
          child: ExcludeSemantics(
            child: Lottie.asset(
              'assets/animations/Olympics.json',
              width: 160,
              height: 120,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('Finding games near you...', style: text.bodyMedium),
      ],
    );
  }
}