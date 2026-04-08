import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          _SectionHeader(title: AppStrings.language),
          RadioListTile<String>(
            value: 'en',
            groupValue: localeProvider.locale.languageCode,
            title: const Text(AppStrings.english),
            secondary: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
            onChanged: (v) => localeProvider.setLocale(v!),
          ),
          RadioListTile<String>(
            value: 'ar',
            groupValue: localeProvider.locale.languageCode,
            title: const Text(AppStrings.arabic),
            secondary: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
            onChanged: (v) => localeProvider.setLocale(v!),
          ),
          const Divider(),
          _SectionHeader(title: AppStrings.theme),
          SwitchListTile(
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
            title: const Text(AppStrings.darkMode),
            secondary: Icon(
              themeProvider.isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: AppColors.primary,
            ),
          ),
          const Divider(),
          _SectionHeader(title: 'Account'),
          Consumer<AuthProvider>(
            builder: (_, auth, __) {
              if (!auth.isAuthenticated) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(AppStrings.logout,
                    style: TextStyle(color: AppColors.error)),
                onTap: () => auth.logout(),
              );
            },
          ),
          const Divider(),
          _SectionHeader(title: AppStrings.about),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined,
                color: AppColors.textSecondary),
            title: const Text(AppStrings.privacyPolicy),
            trailing: const Icon(Icons.open_in_new,
                size: 16, color: AppColors.textHint),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined,
                color: AppColors.textSecondary),
            title: const Text(AppStrings.termsOfService),
            trailing: const Icon(Icons.open_in_new,
                size: 16, color: AppColors.textHint),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline,
                color: AppColors.textSecondary),
            title: const Text(AppStrings.appName),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
