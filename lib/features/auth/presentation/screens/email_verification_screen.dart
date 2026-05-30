import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/theme/app_colors.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final verified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (verified && mounted) {
        _timer?.cancel();
        context.go('/home');
      }
    });
  }

  Future<void> _resend() async {
    final ok = await ref.read(authNotifierProvider.notifier).resendVerificationEmail();
    if (ok && mounted) {
      setState(() => _resendCooldown = 60);
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() { _resendCooldown--; if (_resendCooldown == 0) t.cancel(); });
      });
    }
  }

  @override
  void dispose() { _timer?.cancel(); _cooldownTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.mark_email_unread_rounded, color: Colors.white, size: 48),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 32),
              Text('Verify your email', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center)
                .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.5), children: [
                  const TextSpan(text: 'We\'ve sent a verification link to\n'),
                  TextSpan(text: user?.email ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const TextSpan(text: '\nCheck your inbox and click the link to continue.'),
                ]),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onSurfaceVariant)),
                  const SizedBox(width: 12),
                  Text('Waiting for verification...', style: tt.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
              _resendCooldown > 0
                ? Text('Resend in ${_resendCooldown}s', style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
                : GradientButton(
                    label: 'Resend Email',
                    onPressed: _resend,
                    icon: Icons.send_rounded,
                  ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign out'),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
