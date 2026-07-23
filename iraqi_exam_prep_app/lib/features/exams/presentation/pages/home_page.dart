import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_cubit.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../../core/widgets/modern_section.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الاستعداد للاختبار الوطني',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            // Theme Toggle
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                final isDarkMode = state.themeMode == ThemeMode.dark;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.10)
                        : Colors.black.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: anim,
                        child: child,
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        key: ValueKey(isDarkMode),
                        color:
                            isDarkMode ? AppColors.warning : AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    tooltip: isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
                  ),
                );
              },
            ),
            const SizedBox(width: 8),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: InkWell(
                onTap: () => context.read<AuthBloc>().add(LogoutEvent()),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.22),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          size: 16, color: AppColors.error),
                      SizedBox(width: 6),
                      Text(
                        'خروج',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor,
                cs.primary.withOpacity(isDark ? 0.08 : 0.06),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome / Profile
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is! AuthAuthenticated) return const SizedBox();

                      return ModernSection(
                        title: 'مرحباً',
                        icon: Icons.waving_hand_rounded,
                        color: cs.primary,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'أهلاً بعودتك،',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    state.user.name,
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  if (state.user.isPremium)
                                    _StatusPill(
                                      icon: Icons.verified_rounded,
                                      label: 'مشترك مميز',
                                      color: AppColors.success,
                                      isDark: isDark,
                                    )
                                  else
                                    _StatusPill(
                                      icon: Icons.lock_outline_rounded,
                                      label: 'حساب مجاني',
                                      color: AppColors.warning,
                                      isDark: isDark,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(isDark ? 0.18 : 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: cs.primary.withOpacity(isDark ? 0.28 : 0.18),
                                ),
                              ),
                              child: Icon(
                                state.user.isPremium
                                    ? Icons.workspace_premium_rounded
                                    : Icons.person_rounded,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Admin Tools
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated &&
                          state.user.role.toUpperCase() == 'ADMIN') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ModernSection(
                              title: 'أدوات المشرف',
                              icon: Icons.admin_panel_settings_rounded,
                              color: AppColors.warning,
                              child: Column(
                                children: [
                                  _ModernListTile(
                                    icon: Icons.app_registration_rounded,
                                    iconColor: cs.primary,
                                    title: 'إضافة أسئلة الامتحانات',
                                    subtitle: 'إدارة الأسئلة لجميع المواد وتحديثها',
                                    onTap: () => context.push('/admin/questions'),
                                  ),
                                  const SizedBox(height: 10),
                                  _ModernListTile(
                                    icon: Icons.vpn_key_rounded,
                                    iconColor: AppColors.primary,
                                    title: 'إدارة أكواد التفعيل',
                                    subtitle:
                                        'توليد أكواد جديدة وعرض الأكواد الموجودة',
                                    onTap: () => context.push('/admin/codes'),
                                  ),
                                  const SizedBox(height: 10),
                                  _ModernListTile(
                                    icon: Icons.notifications_active_rounded,
                                    iconColor: AppColors.success,
                                    title: 'إرسال إشعارات',
                                    subtitle:
                                        'إرسال تحديثات وتنبيهات لجميع المستخدمين',
                                    onTap: () => context.push('/admin/notifications'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Subjects Title
                  Text(
                    'اختر المادة التي ترغب بالاختبار فيها',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subjects Cards
                  _buildSubjectCard(
                    context,
                    subject: AppConstants.arabicSubject,
                    title: 'اللغة العربية',
                    subtitle: 'مجاني - محاولة واحدة',
                    icon: Icons.language_rounded,
                    color: AppColors.arabicColor,
                    isFree: true,
                  ),
                  const SizedBox(height: 12),
                  _buildSubjectCard(
                    context,
                    subject: AppConstants.englishSubject,
                    title: 'اللغة الإنجليزية',
                    subtitle: 'يتطلب اشتراكاً مميزاً',
                    icon: Icons.translate_rounded,
                    color: AppColors.englishColor,
                    isFree: false,
                  ),
                  const SizedBox(height: 12),
                  _buildSubjectCard(
                    context,
                    subject: AppConstants.computerSubject,
                    title: 'مهارات الحاسوب',
                    subtitle: 'يتطلب اشتراكاً مميزاً',
                    icon: Icons.computer_rounded,
                    color: AppColors.computerColor,
                    isFree: false,
                  ),

                  const SizedBox(height: 18),

                  // National Exam Registration
                  ModernSection(
                    title: 'التسجيل الرسمي',
                    icon: Icons.how_to_reg_rounded,
                    color: AppColors.info,
                    child: _ModernListTile(
                      icon: Icons.how_to_reg_rounded,
                      iconColor: AppColors.info,
                      title: 'التسجيل للامتحان الوطني',
                      subtitle:
                          'تعرف على خطوات التسجيل الرسمي والمستندات المطلوبة',
                      onTap: () => context.push('/national-exam'),
                      trailing: Icons.arrow_forward_ios_rounded,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // About App
                  ModernSection(
                    title: 'حول التطبيق',
                    icon: Icons.info_outline_rounded,
                    color: AppColors.textSecondary,
                    child: _ModernListTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: AppColors.textSecondary,
                      title: 'سياسة الخصوصية',
                      subtitle: 'معلومات حول كيفية حماية بياناتك',
                      onTap: () => context.push('/privacy-policy'),
                      trailing: Icons.arrow_forward_ios_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context, {
    required String subject,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isFree,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool hasAccess = isFree;
        bool isPremiumUser = false;

        if (authState is AuthAuthenticated) {
          isPremiumUser = authState.user.isPremium;
          hasAccess = isFree ||
              authState.user.isPremium ||
              authState.user.unlockedSubjects.contains(subject);
        }

        final statusColor = hasAccess ? AppColors.success : AppColors.warning;
        final statusIcon = hasAccess ? Icons.check_circle_rounded : Icons.lock_rounded;
        final statusLabel = hasAccess ? 'متاح' : 'مقفل';

        return InkWell(
          onTap: () {
            if (hasAccess) {
              context.push('/exam/$subject');
            } else {
              context.push('/subscription', extra: subject);
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: hasAccess
                    ? statusColor.withOpacity(isDark ? 0.22 : 0.16)
                    : (isDark ? AppColors.borderDark : AppColors.border),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Icon block
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withOpacity(isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: color.withOpacity(isDark ? 0.28 : 0.18),
                      ),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 14),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Access pill
                        Row(
                          children: [
                            _StatusPill(
                              icon: statusIcon,
                              label: statusLabel,
                              color: statusColor,
                              isDark: isDark,
                              dense: true,
                            ),
                            const SizedBox(width: 8),
                            if (!hasAccess && isPremiumUser == false)
                              _StatusPill(
                                icon: Icons.workspace_premium_rounded,
                                label: 'ترقية',
                                color: cs.primary,
                                isDark: isDark,
                                dense: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -------------------- Reusable widgets (same design language) --------------------

class _ModernListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailing;

  const _ModernListTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing = Icons.arrow_forward_ios_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              trailing,
              size: 18,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final bool dense;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 12,
        vertical: dense ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.34 : 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: dense ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
