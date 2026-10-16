import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/screens/landing/widgets/game_row.dart';
import 'package:sub_in/screens/landing/widgets/radar_card.dart';
import 'package:sub_in/widgets/auth/social_auth_buttons.dart';

/// Stitch landing page (visual source of truth).
/// New entry screen for logged-out users: brand + live radar preview,
/// tagline, Create-account / Login CTAs wired to existing routes.
/// UI-only — no auth logic duplicated here.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.appBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'SubIn',
                    style: text.titleLarge?.copyWith(color: AppTheme.lime),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lowContainer,
                      borderRadius: AppTheme.radiusBorder,
                      border: Border.all(color: AppTheme.outline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.liveEmerald,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('14 games live', style: text.labelSmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const RadarCard(),
              const SizedBox(height: 12),
              const GameRow(
                icon: Icons.sports_soccer,
                title: 'Pickup Soccer — Zilker Park',
                subtitle: '0.4 mi • 5/10 • Tonight 6:30 PM',
              ),
              const SizedBox(height: 8),
              const GameRow(
                icon: Icons.sports_basketball,
                title: 'Hoops Night — Riverside Court',
                subtitle: '1.1 mi • 8/10 • Tomorrow 7 PM',
              ),
              const SizedBox(height: 20),
              Text(
                'Stop watching.\nSub into the game.',
                style: text.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Find nearby games, request to join, host events, '
                'and coordinate with chat.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/register'),
                child: const Text('Create account'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR CONTINUE WITH', style: text.labelSmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 14),
              const SocialAuthButtons(),
              const SizedBox(height: 16),
              Text(
                'By continuing you agree to the Pitch Conduct Code.',
                textAlign: TextAlign.center,
                style: text.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
