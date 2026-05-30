import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_colors.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authNotifierProvider.notifier).sendPasswordReset(_emailCtrl.text.trim());
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 40),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text('Forgot Password?', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700))
                  .animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text('Enter your email address and we\'ll send you a link to reset your password.',
                  style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
                  .animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),
                GradientButton(
                  label: 'Send Reset Link',
                  onPressed: authState.isLoading ? null : _submit,
                  isLoading: authState.isLoading,
                  icon: Icons.send_rounded,
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 40),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text('Check your email', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700))
          .animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant), children: [
            const TextSpan(text: 'We sent a password reset link to '),
            TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 32),
        GradientButton(
          label: 'Back to Login',
          onPressed: () => context.go('/login'),
          icon: Icons.arrow_back_rounded,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}
