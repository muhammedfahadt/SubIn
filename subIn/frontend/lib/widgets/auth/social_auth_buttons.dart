import 'package:flutter/material.dart';
import 'package:sub_in/config/app_theme.dart';

/// Shared social auth buttons (Google / Apple).
/// UI-only: backend has no social login, so taps show a snackbar
/// instead of duplicating auth logic.
class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  void _unavailable(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider login is not available yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _unavailable(context, 'Google'),
            icon: const Icon(Icons.g_mobiledata, size: 24),
            label: const Text('Google'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _unavailable(context, 'Apple'),
            icon: const Icon(Icons.apple, size: 20),
            label: const Text('Apple'),
          ),
        ),
      ],
    );
  }
}
