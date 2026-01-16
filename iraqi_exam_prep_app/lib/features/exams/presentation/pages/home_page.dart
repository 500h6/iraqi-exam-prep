import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/theme/bloc/theme_cubit.dart';
import '../../../../core/theme/bloc/theme_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        // Background color handled by theme
        appBar: AppBar(
          title: const Text(
            'الاستعداد للاختبار الوطني',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          actions: [
            // Theme Toggle
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                final isDark = state.themeMode == ThemeMode.dark;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
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
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        key: ValueKey(isDark),
                        color: isDark ? AppColors.warning : AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
                  ),
                );
              },
            ),

            const SizedBox(width: 8),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: InkWell(
                onTap: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Section
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهلاً بعودتك،',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          state.user.name,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        if (state.user.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'مشترك مميز',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated &&
                      state.user.role.toUpperCase() == 'ADMIN') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أدوات المشرف',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.app_registration),
                            title: const Text('إضافة أسئلة الامتحانات'),
                            subtitle: const Text(
                              'إدارة الأسئلة لجميع المواد وتحديثها',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () => context.push('/admin/questions'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.vpn_key, color: AppColors.primary),
                            title: const Text('إدارة أكواد التفعيل'),
                            subtitle: const Text(
                              'توليد أكواد جديدة وعرض الأكواد الموجودة',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () => context.push('/admin/codes'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Subjects Section
              Text(
                'اختر المادة التي ترغب بالاختبار فيها',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildSubjectCard(
                context,
                subject: AppConstants.arabicSubject,
                title: 'اللغة العربية',
                subtitle: 'مجاني - محاولة واحدة',
                icon: Icons.language,
                color: AppColors.arabicColor,
                isFree: true,
              ),
              const SizedBox(height: 16),
              _buildSubjectCard(
                context,
                subject: AppConstants.englishSubject,
                title: 'اللغة الإنجليزية',
                subtitle: 'يتطلب اشتراكاً مميزاً',
                icon: Icons.translate,
                color: AppColors.englishColor,
                isFree: false,
              ),
              const SizedBox(height: 16),
              _buildSubjectCard(
                context,
                subject: AppConstants.computerSubject,
                title: 'مهارات الحاسوب',
                subtitle: 'يتطلب اشتراكاً مميزاً',
                icon: Icons.computer,
                color: AppColors.computerColor,
                isFree: false,
              ),
              const SizedBox(height: 32),
              // National Exam Registration
              Card(
                child: InkWell(
                  onTap: () => context.push('/national-exam'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.how_to_reg,
                            color: AppColors.info,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التسجيل للامتحان الوطني',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'تعرف على خطوات التسجيل الرسمي والمستندات المطلوبة',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        bool hasAccess = isFree;
        if (authState is AuthAuthenticated) {
          hasAccess = isFree ||
              authState.user.isPremium ||
              authState.user.unlockedSubjects.contains(subject);
        }

        return Card(
          child: InkWell(
            onTap: () {
              if (hasAccess) {
                context.push('/exam/$subject');
              } else {
                context.push('/subscription', extra: subject);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              hasAccess ? Icons.check_circle : Icons.lock,
                              size: 16,
                              color: hasAccess
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
