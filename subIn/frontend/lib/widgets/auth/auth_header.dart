import 'package:flutter/material.dart';

/// Shared header for the auth screens: eyebrow pill + title + subtitle.
/// Used by login and register; keeps Stitch header styling in one place.
class AuthHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(eyebrow, style: text.labelSmall),
        const SizedBox(height: 8),
        Text(title, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: text.bodyMedium),
      ],
    );
  }
}
