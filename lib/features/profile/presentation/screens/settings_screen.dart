import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = ref.watch(themeProvider);
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                trailing: Switch(
                  value: isDark,
                  onChanged: (v) async {
                    ref.read(themeProvider.notifier).state = v;
                    await ref.read(profileNotifierProvider.notifier).updateSettings(darkMode: v);
                  },
                ),
              ),
            ],
          ).animate().fadeIn(),
          const SizedBox(height: 16),

          // Currency
          _SettingsSection(
            title: 'Currency',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferred Currency', style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: user?.preferredCurrency ?? 'USD',
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.currency_exchange_rounded)),
                      items: AppConstants.currencies.map((c) => DropdownMenuItem(
                        value: c['code'],
                        child: Text('${c['code']} — ${c['name']}'),
                      )).toList(),
                      onChanged: (v) async {
                        if (v != null) await ref.read(profileNotifierProvider.notifier).updateSettings(currency: v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),

          // Notifications
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SettingsTile(
                icon: Icons.notifications_rounded,
                title: 'Push Notifications',
                subtitle: 'Budget alerts & reminders',
                trailing: Switch(
                  value: user?.notificationsEnabled ?? true,
                  onChanged: (v) async {
                    await ref.read(profileNotifierProvider.notifier).updateSettings(notifications: v);
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.alarm_rounded,
                title: 'Daily Reminder',
                subtitle: 'Remind to log daily expenses',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
              _SettingsTile(
                icon: Icons.summarize_rounded,
                title: 'Weekly Summary',
                subtitle: 'Weekly spending report',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 16),

          // Data
          _SettingsSection(
            title: 'Data & Export',
            children: [
              _SettingsTile(
                icon: Icons.file_download_outlined,
                title: 'Export Data',
                subtitle: 'Download PDF or CSV report',
                onTap: () => context.push('/export'),
              ),
              _SettingsTile(
                icon: Icons.sync_rounded,
                title: 'Sync Status',
                subtitle: 'Data is synced with cloud',
                trailing: const Icon(Icons.cloud_done_rounded, color: AppColors.success, size: 20),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),

          // About
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(icon: Icons.info_outline_rounded, title: 'App Version', trailing: Text(AppConstants.appVersion, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13))),
              _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () {}),
              _SettingsTile(icon: Icons.description_outlined, title: 'Terms of Service', onTap: () {}),
            ],
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant, width: 0.5),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(children: [e.value, if (!isLast) Divider(height: 1, color: scheme.outlineVariant)]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, size: 18, color: scheme.onSurfaceVariant) : null),
      onTap: onTap,
    );
  }
}
