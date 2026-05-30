import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }
    final notifier = ref.read(authNotifierProvider.notifier);
    final ok = await notifier.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      name: _nameCtrl.text.trim(),
    );
    if (ok && mounted) context.go('/verify-email');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    ref.listen(authNotifierProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: AppColors.error),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Create account', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700))
                  .animate().fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 6),
                Text('Start tracking your expenses today', style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
                  .animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),

                AppTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.name,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Password',
                  controller: _passCtrl,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Confirm Password',
                  controller: _confirmPassCtrl,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          children: [
                            Text('I agree to the ', style: tt.bodySmall),
                            GestureDetector(
                              child: Text('Terms of Service', style: tt.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ),
                            Text(' and ', style: tt.bodySmall),
                            GestureDetector(
                              child: Text('Privacy Policy', style: tt.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),
                GradientButton(
                  label: 'Create Account',
                  onPressed: authState.isLoading ? null : _submit,
                  isLoading: authState.isLoading,
                  icon: Icons.person_add_rounded,
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
