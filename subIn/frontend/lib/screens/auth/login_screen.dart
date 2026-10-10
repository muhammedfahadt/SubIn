import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sub_in/config/app_theme.dart';
import 'package:sub_in/providers/auth_provider.dart';
import 'package:sub_in/widgets/auth/auth_header.dart';
import 'package:sub_in/widgets/auth/social_auth_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'admin@test.com');
    _passwordController = TextEditingController(text: 'password');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final text = Theme.of(context).textTheme;

    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (previous, next) {
      if (next.hasValue && next.value!.isLoggedIn) {
        context.go('/home');
      } else if (next.hasError) {
        final raw = next.error.toString();
        final message = raw.startsWith('Exception: ')
            ? raw.substring('Exception: '.length)
            : raw;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.appBackground,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/landing'),
        ),
        title: const Text('SUBIN Select Sports'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.location_on, color: AppTheme.lime),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                eyebrow: '14 LIVE RUNS NEARBY',
                title: 'Log in to SubIn',
                subtitle:
                    'Jump back into local pickup games, squad chats, and active runs.',
              ),
              const SizedBox(height: 16),
              Text('Email or Athlete Phone', style: text.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.alternate_email),
                  suffixIcon: IconButton(
                    tooltip: 'Clear email',
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: _emailController.clear,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Password', style: text.titleSmall)),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset is not available yet'),
                        ),
                      );
                    },
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip:
                        _obscurePassword ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(
                      () => _rememberMe = value ?? false,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Remember me on this phone',
                      style: text.bodyMedium,
                    ),
                  ),
                  Text('SSL Secured', style: text.labelSmall),
                ],
              ),
              const SizedBox(height: 16),
              authState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).login(
                              _emailController.text,
                              _passwordController.text,
                            );
                      },
                      child: const Text('Log In'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New to the roster? ', style: text.bodyMedium),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('Create Account'),
                  ),
                ],
              ),
              Text(
                "By logging in, you agree to SubIn's Pitch Conduct Code & Fair Play Rules.",
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
