import 'package:flutter/material.dart';
import 'package:sub_in/config/app_theme.dart';

/// Live radar preview card for the landing screen.
/// Display-only Stitch visual — no backend, no location logic.
class RadarCard extends StatelessWidget {
  const RadarCard({super.key});

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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.highContainer,
            ),
            child: const Icon(
              Icons.radar,
              color: AppTheme.lime,
              size: 28,
              semanticLabel: 'Live radar',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live radar near you', style: text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Scanning pitches within 5 miles…',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.liveEmerald,
              borderRadius: AppTheme.radiusBorder,
            ),
            child: Text(
              'LIVE',
              style: text.labelSmall?.copyWith(
                color: AppTheme.onLime,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
