import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_section.dart';

class SubscriptionPage extends StatefulWidget {
  final String subject;

  const SubscriptionPage({super.key, required this.subject});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String get _subjectDisplayName {
    switch (widget.subject) {
      case AppConstants.englishSubject:
        return 'اللغة الإنجليزية';
      case AppConstants.computerSubject:
        return 'مهارات الحاسوب';
      case AppConstants.arabicSubject:
        return 'اللغة العربية';
      default:
        return 'المادة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الاشتراك المميز'),
        centerTitle: true,
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Define responsive breakpoints
                final screenWidth = constraints.maxWidth;
                final isSmallPhone = screenWidth < 360;
                final isPhone = screenWidth < 600;
                final isTablet = screenWidth >= 600 && screenWidth < 900;
                final isDesktop = screenWidth >= 900;

                // Calculate responsive values
                final horizontalPadding = _getHorizontalPadding(screenWidth);
                final verticalSpacing = _getVerticalSpacing(screenWidth);
                final maxContentWidth = isDesktop ? 800.0 : double.infinity;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalSpacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(
                              context,
                              cs: cs,
                              isDark: isDark,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              screenWidth: screenWidth,
                            ),
                            SizedBox(height: verticalSpacing),

                            _buildLockedBadge(
                              context,
                              isDark: isDark,
                              textPrimary: textPrimary,
                              screenWidth: screenWidth,
                            ),
                            SizedBox(height: verticalSpacing),

                            ModernSection(
                              title: 'مزايا الاشتراك',
                              icon: Icons.auto_awesome_rounded,
                              color: AppColors.success,
                              child: _buildBenefitsGrid(
                                context,
                                isDark: isDark,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                screenWidth: screenWidth,
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 0.8),

                            ModernSection(
                              title: 'خطوات الاشتراك',
                              icon: Icons.rocket_launch_rounded,
                              color: cs.primary,
                              child: _buildSteps(
                                context,
                                cs: cs,
                                screenWidth: screenWidth,
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 0.8),

                            ModernSection(
                              title: 'ضمانات وثقة',
                              icon: Icons.verified_user_rounded,
                              color: AppColors.success,
                              child: _buildTrustRow(
                                context,
                                isDark: isDark,
                                textPrimary: textPrimary,
                                screenWidth: screenWidth,
                              ),
                            ),

                            SizedBox(height: verticalSpacing * 1.2),

                            _buildCTAButtons(
                              context,
                              cs: cs,
                              isDark: isDark,
                              screenWidth: screenWidth,
                            ),

                            SizedBox(height: verticalSpacing * 0.6),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding * 0.5,
                              ),
                              child: Text(
                                'ملاحظة: التفعيل يتم فوراً بعد استلام رمز التفعيل.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontStyle: FontStyle.italic,
                                  fontSize: _getBodySmallFontSize(screenWidth),
                                ),
                              ),
                            ),
                            SizedBox(height: verticalSpacing),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- Responsive Helpers --------------------

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < 360) return 16;
    if (screenWidth < 600) return 20;
    if (screenWidth < 900) return 32;
    return 48;
  }

  double _getVerticalSpacing(double screenWidth) {
    if (screenWidth < 360) return 16;
    if (screenWidth < 600) return 20;
    if (screenWidth < 900) return 24;
    return 32;
  }

  double _getIconSize(double screenWidth, {double base = 60}) {
    if (screenWidth < 360) return base * 0.8;
    if (screenWidth < 600) return base;
    if (screenWidth < 900) return base * 1.1;
    return base * 1.2;
  }

  double _getHeaderFontSize(double screenWidth) {
    if (screenWidth < 360) return 22;
    if (screenWidth < 600) return 26;
    if (screenWidth < 900) return 30;
    return 34;
  }

  double _getBodyFontSize(double screenWidth) {
    if (screenWidth < 360) return 14;
    if (screenWidth < 600) return 15;
    if (screenWidth < 900) return 16;
    return 17;
  }

  double _getBodySmallFontSize(double screenWidth) {
    if (screenWidth < 360) return 12;
    if (screenWidth < 600) return 13;
    if (screenWidth < 900) return 14;
    return 15;
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 360) return 13;
    if (screenWidth < 600) return 14;
    if (screenWidth < 900) return 15;
    return 16;
  }

  double _getBorderRadius(double screenWidth, {double base = 18}) {
    if (screenWidth < 360) return base * 0.78;
    if (screenWidth < 600) return base;
    return base * 1.1;
  }

  int _getBenefitColumns(double screenWidth) {
    if (screenWidth < 360) return 2;
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 2;
    return 4;
  }

  // -------------------- Header --------------------

  Widget _buildHeader(
    BuildContext context, {
    required ColorScheme cs,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);
    final iconSize = _getIconSize(screenWidth);
    final headerFontSize = _getHeaderFontSize(screenWidth);
    final bodyFontSize = _getBodyFontSize(screenWidth);
    final borderRadius = _getBorderRadius(screenWidth);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(iconSize * 0.3),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(isDark ? 0.16 : 0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: cs.primary.withOpacity(isDark ? 0.28 : 0.20),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            size: iconSize,
            color: cs.primary,
          ),
        ),
        SizedBox(height: screenWidth < 360 ? 14 : 20),
        Text(
          'افتح كل الاختبارات',
          style: theme.textTheme.displaySmall?.copyWith(
            fontSize: headerFontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenWidth < 360 ? 8 : 10),
        Container(
          height: 3,
          width: screenWidth < 360 ? 48 : 60,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: screenWidth < 360 ? 10 : 12),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 600 ? 0 : screenWidth * 0.1,
          ),
          child: Text(
            'اختبار $_subjectDisplayName متاح للمشتركين المميزين فقط',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontSize: bodyFontSize,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // -------------------- Locked Badge --------------------

  Widget _buildLockedBadge(
    BuildContext context, {
    required bool isDark,
    required Color textPrimary,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);
    final borderRadius = _getBorderRadius(screenWidth);
    final bodyFontSize = _getBodyFontSize(screenWidth);

    return Container(
      padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.warning.withOpacity(isDark ? 0.30 : 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth < 360 ? 8 : 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(isDark ? 0.22 : 0.18),
              borderRadius: BorderRadius.circular(borderRadius * 0.7),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.warning,
              size: screenWidth < 360 ? 20 : 24,
            ),
          ),
          SizedBox(width: screenWidth < 360 ? 12 : 16),
          Expanded(
            child: Text(
              'هذا المحتوى حصري للمشتركين — اشترك الآن وابدأ بدون قيود.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.5,
                fontSize: bodyFontSize,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Benefits --------------------

  Widget _buildBenefitsGrid(
    BuildContext context, {
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required double screenWidth,
  }) {
    final items = <_BenefitItem>[
      const _BenefitItem(
        icon: Icons.all_inclusive_rounded,
        title: 'محاولات غير محدودة',
        subtitle: 'كرر الاختبارات بلا حدود',
      ),
      const _BenefitItem(
        icon: Icons.auto_awesome_rounded,
        title: 'أسئلة محدثة',
        subtitle: 'تحديثات مستمرة للأسئلة',
      ),
      const _BenefitItem(
        icon: Icons.school_rounded,
        title: 'جميع المواد',
        subtitle: 'وصول كامل لكل الاختبارات',
      ),
      const _BenefitItem(
        icon: Icons.support_agent_rounded,
        title: 'دعم فني',
        subtitle: 'مساعدة على مدار الساعة',
      ),
    ];

    final columns = _getBenefitColumns(screenWidth);
    final spacing = screenWidth < 360 ? 10.0 : 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (availableWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(items.length, (i) {
            return SizedBox(
              width: itemWidth,
              child: _buildBenefitTile(
                context,
                items[i],
                i,
                isDark: isDark,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                screenWidth: screenWidth,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBenefitTile(
    BuildContext context,
    _BenefitItem item,
    int index, {
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);
    final borderRadius = _getBorderRadius(screenWidth);
    final titleFontSize = _getTitleFontSize(screenWidth);
    final bodySmallFontSize = _getBodySmallFontSize(screenWidth);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 420 + (index * 90)),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Transform.translate(
        offset: Offset(0, 14 * (1 - v)),
        child: Opacity(opacity: v, child: child),
      ),
      child: Container(
        padding: EdgeInsets.all(screenWidth < 360 ? 12 : 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth < 360 ? 10 : 12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(isDark ? 0.16 : 0.12),
                borderRadius: BorderRadius.circular(borderRadius * 0.7),
              ),
              child: Icon(
                item.icon,
                color: AppColors.success,
                size: screenWidth < 360 ? 22 : 26,
              ),
            ),
            SizedBox(height: screenWidth < 360 ? 8 : 10),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: titleFontSize,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                fontSize: bodySmallFontSize,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Steps --------------------

  // -------------------- Steps --------------------

  Widget _buildSteps(
    BuildContext context, {
    required ColorScheme cs,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);
    final bodyFontSize = _getBodyFontSize(screenWidth);

    const steps = [
      'تواصل معنا',
      'اختر خطة الاشتراك المناسبة',
      'أتمم عملية الدفع',
      'استلم رمز التفعيل فوراً',
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: i == steps.length - 1 ? 0 : (screenWidth < 360 ? 12 : 14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth < 360 ? 28 : 32,
                height: screenWidth < 360 ? 28 : 32,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth < 360 ? 13 : 15,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth < 360 ? 12 : 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: screenWidth < 360 ? 4 : 6),
                  child: Text(
                    steps[i],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                      fontSize: bodyFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // -------------------- Trust --------------------

  Widget _buildTrustRow(
    BuildContext context, {
    required bool isDark,
    required Color textPrimary,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);
    final borderRadius = _getBorderRadius(screenWidth);
    final bodySmallFontSize = _getBodySmallFontSize(screenWidth);

    const indicators = <_TrustIndicator>[
      _TrustIndicator(Icons.verified_user_rounded, 'آمن 100%'),
      _TrustIndicator(Icons.bolt_rounded, 'تفعيل فوري'),
      _TrustIndicator(Icons.headset_mic_rounded, 'دعم 24/7'),
    ];

    return Wrap(
      spacing: screenWidth < 360 ? 12 : 16,
      runSpacing: screenWidth < 360 ? 12 : 16,
      alignment: WrapAlignment.spaceAround,
      children: indicators.map((t) {
        return SizedBox(
          width: screenWidth < 600 ? (screenWidth - 100) / 3 : 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth < 360 ? 12 : 14),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Icon(
                  t.icon,
                  color: AppColors.success,
                  size: screenWidth < 360 ? 24 : 28,
                ),
              ),
              SizedBox(height: screenWidth < 360 ? 8 : 10),
              Text(
                t.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: bodySmallFontSize,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // -------------------- CTA Buttons --------------------

  Widget _buildCTAButtons(
    BuildContext context, {
    required ColorScheme cs,
    required bool isDark,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);
    final borderRadius = _getBorderRadius(screenWidth);
    final buttonHeight = screenWidth < 360 ? 56.0 : 60.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: buttonHeight * 0.9,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/activation'),
            icon: Icon(
              Icons.vpn_key_rounded,
              size: screenWidth < 360 ? 18 : 22,
            ),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'أملك رمز تفعيل',
                style: TextStyle(
                  fontSize: screenWidth < 360 ? 15 : 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : theme.colorScheme.primary,
              side: BorderSide(
                color: cs.primary.withOpacity(isDark ? 0.55 : 0.35),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchTelegram() async {
     // Deprecated
  }
}

// -------------------- Helper models --------------------

class _BenefitItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _TrustIndicator {
  final IconData icon;
  final String label;

  const _TrustIndicator(this.icon, this.label);
}