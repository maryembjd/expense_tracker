import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl.text = user?.displayName ?? '';
    _phoneCtrl.text = user?.phoneNumber ?? '';
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileNotifierProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    ref.listen(profileNotifierProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: AppColors.error));
        ref.read(profileNotifierProvider.notifier).clearMessages();
      }
      if (state.success != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.success!), backgroundColor: AppColors.success));
        ref.read(profileNotifierProvider.notifier).clearMessages();
        setState(() => _editing = false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: () => setState(() => _editing = !_editing),
            child: Text(_editing ? 'Cancel' : 'Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                  child: user?.photoUrl == null ? Text(
                    user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ) : null,
                ),
                if (_editing)
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.surface, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 12),
            Text(user?.displayName ?? '', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700))
              .animate().fadeIn(delay: 100.ms),
            Text(user?.email ?? '', style: tt.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
              .animate().fadeIn(delay: 150.ms),
            if (user?.emailVerified == true)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 12, color: AppColors.success),
                    SizedBox(width: 4),
                    Text('Verified', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 28),

            if (_editing) Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: Validators.name,
                  ).animate().fadeIn(),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Phone Number',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: Validators.phoneNumber,
                  ).animate().fadeIn(delay: 50.ms),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: 'Save Changes',
                    isLoading: profileState.isLoading,
                    icon: Icons.save_rounded,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      await ref.read(profileNotifierProvider.notifier).updateProfile(
                        name: _nameCtrl.text.trim(),
                        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
                      );
                    },
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ) else ...[
              _InfoSection(
                title: 'Account Information',
                tiles: [
                  _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user?.email ?? ''),
                  _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: user?.phoneNumber ?? 'Not set'),
                  _InfoTile(icon: Icons.calendar_today_rounded, label: 'Member since',
                    value: user?.createdAt != null ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}' : ''),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 12),
              _InfoSection(
                title: 'Actions',
                tiles: [
                  _InfoTile(icon: Icons.settings_rounded, label: 'Settings', onTap: () => context.push('/settings')),
                  _InfoTile(icon: Icons.lock_outline_rounded, label: 'Change Password', onTap: () => _showChangePasswordDialog(context, ref)),
                  _InfoTile(icon: Icons.logout_rounded, label: 'Sign Out', onTap: () => _signOut(context, ref), isDestructive: false),
                  _InfoTile(icon: Icons.delete_forever_rounded, label: 'Delete Account', onTap: () => _deleteAccount(context, ref), isDestructive: true),
                ],
              ).animate().fadeIn(delay: 100.ms),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    // In production: upload to Firebase Storage, get URL, call updateProfile
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (context.mounted) context.go('/login');
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete your account and all data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      final result = await ref.read(authRepositoryProvider).deleteAccount();
      result.fold((_) {}, (_) { if (context.mounted) context.go('/login'); });
    }
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                AppTextField(label: 'Current Password', controller: currentCtrl, obscureText: true, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 12),
                AppTextField(label: 'New Password', controller: newCtrl, obscureText: true, validator: Validators.password),
                const SizedBox(height: 20),
                GradientButton(label: 'Update Password', icon: Icons.lock_reset_rounded,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await ref.read(profileNotifierProvider.notifier).updatePassword(current: currentCtrl.text, next: newCtrl.text);
                    if (ok && ctx.mounted) Navigator.pop(ctx);
                  }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoTile> tiles;
  const _InfoSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant, width: 0.5),
          ),
          child: Column(
            children: tiles.asMap().entries.map((e) {
              final tile = e.value;
              final isLast = e.key == tiles.length - 1;
              return Column(
                children: [
                  tile,
                  if (!isLast) Divider(height: 1, color: scheme.outlineVariant),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _InfoTile({required this.icon, required this.label, this.value, this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDestructive ? AppColors.error : (onTap != null ? scheme.onSurface : scheme.onSurface);
    return ListTile(
      leading: Icon(icon, size: 20, color: isDestructive ? AppColors.error : scheme.onSurfaceVariant),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      trailing: value != null ? Text(value!, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)) : (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 18) : null),
      onTap: onTap,
    );
  }
}
