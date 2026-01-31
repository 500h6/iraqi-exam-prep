import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class NationalExamPage extends StatelessWidget {
  const NationalExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التسجيل في الامتحان الوطني'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
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
                        vertical: verticalSpacing * 1.2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Card
                          _buildHeader(context, screenWidth),
                          SizedBox(height: verticalSpacing * 1.5),

                          // Info Sections
                          _buildModernSection(
                            context,
                            screenWidth: screenWidth,
                            title: 'عن الامتحان الوطني',
                            icon: Icons.info_rounded,
                            color: AppColors.primary,
                            content: Column(
                              children: [
                                Text(
                                  'الامتحان الوطني الموحد هو شرط أساسي للتقديم للدراسات العليا (الماجستير والدكتوراه) في الجامعات العراقية.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        height: 1.6,
                                        fontSize: _getBodyFontSize(screenWidth),
                                      ),
                                ),
                                SizedBox(height: verticalSpacing),
                                _buildSubjectsRow(context, screenWidth),
                              ],
                            ),
                          ),
                          SizedBox(height: verticalSpacing),

                          _buildModernSection(
                            context,
                            screenWidth: screenWidth,
                            title: 'المتطلبات الأساسية',
                            icon: Icons.assignment_turned_in_rounded,
                            color: AppColors.warning,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequirementRow(
                                  context,
                                  'الاسم الرباعي الكامل كما في البطاقة الشخصية',
                                  screenWidth,
                                ),
                                _buildRequirementRow(
                                  context,
                                  'اسم الأم الثلاثي',
                                  screenWidth,
                                ),
                                _buildRequirementRow(
                                  context,
                                  'رقم البطاقة الوطنية الموحدة',
                                  screenWidth,
                                ),
                                _buildRequirementRow(
                                  context,
                                  'رقم هاتف مفعل للإشعارات',
                                  screenWidth,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: verticalSpacing),

                          _buildModernSection(
                            context,
                            screenWidth: screenWidth,
                            title: 'آلية الحجز والتسجيل',
                            icon: Icons.ads_click_rounded,
                            color: AppColors.success,
                            content: Text(
                              'عملية التسجيل تتم بكل سهولة؛ ما عليك سوى الضغط على الزر أدناه لإرسال بياناتك عبر تليكرام، وسيقوم فريقنا المختص بإتمام كافة إجراءات الحجز وتزويدك بالوصل الرسمي وموعد الامتحان.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    height: 1.8,
                                    fontSize:
                                        _getBodyMediumFontSize(screenWidth),
                                  ),
                            ),
                          ),
                          SizedBox(height: verticalSpacing * 1.8),

                          // Premium CTA Button
                          _buildTelegramButton(context, screenWidth),
                          SizedBox(height: verticalSpacing),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding * 0.3,
                            ),
                            child: Text(
                              'ملاحظة: سيتم الرد على طلباتكم بأقرب وقت',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontStyle: FontStyle.italic,
                                    fontSize: _getBodySmallFontSize(screenWidth),
                                  ),
                              textAlign: TextAlign.center,
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
    if (screenWidth < 600) return 16;
    if (screenWidth < 900) return 17;
    return 18;
  }

  double _getBodyMediumFontSize(double screenWidth) {
    if (screenWidth < 360) return 13;
    if (screenWidth < 600) return 15;
    if (screenWidth < 900) return 16;
    return 17;
  }

  double _getBodySmallFontSize(double screenWidth) {
    if (screenWidth < 360) return 11;
    if (screenWidth < 600) return 13;
    if (screenWidth < 900) return 14;
    return 15;
  }

  double _getTitleFontSize(double screenWidth) {
    if (screenWidth < 360) return 16;
    if (screenWidth < 600) return 18;
    if (screenWidth < 900) return 19;
    return 20;
  }

  double _getBorderRadius(double screenWidth, {double base = 24}) {
    if (screenWidth < 360) return base * 0.67;
    if (screenWidth < 600) return base;
    return base * 1.1;
  }

  // -------------------- Header --------------------

  Widget _buildHeader(BuildContext context, double screenWidth) {
    final iconSize = _getIconSize(screenWidth);
    final headerFontSize = _getHeaderFontSize(screenWidth);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(iconSize * 0.33),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(isDark ? 0.16 : 0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(isDark ? 0.28 : 0.20),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.verified_user_rounded,
            size: iconSize,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: screenWidth < 360 ? 16 : 24),
        Text(
          'بوابتك للدراسات العليا',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenWidth < 360 ? 8 : 10),
        Container(
          height: 3,
          width: screenWidth < 360 ? 44 : 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // -------------------- Modern Section --------------------

  Widget _buildModernSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
    required double screenWidth,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = _getBorderRadius(screenWidth);
    final titleFontSize = _getTitleFontSize(screenWidth);
    final padding = screenWidth < 360 ? 16.0 : (screenWidth < 600 ? 20.0 : 24.0);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: screenWidth < 360 ? 10 : 15,
            offset: Offset(0, screenWidth < 360 ? 4 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              padding,
              padding,
              padding,
              padding * 0.6,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: screenWidth < 360 ? 22 : 26,
                ),
                SizedBox(width: screenWidth < 360 ? 10 : 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: color.withOpacity(0.1), height: 1),
          Padding(
            padding: EdgeInsets.all(padding),
            child: content,
          ),
        ],
      ),
    );
  }

  // -------------------- Subjects Row --------------------

  Widget _buildSubjectsRow(BuildContext context, double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final spacing = screenWidth < 360 ? 12.0 : 16.0;
        
        // Calculate if items should wrap
        final itemMinWidth = screenWidth < 360 ? 80.0 : 100.0;
        final itemsPerRow = (availableWidth / itemMinWidth).floor().clamp(1, 3);
        final shouldWrap = itemsPerRow < 3;

        if (shouldWrap) {
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: [
              _buildCompactItem(
                context,
                'العربية',
                Icons.language,
                AppColors.arabicColor,
                screenWidth,
              ),
              _buildCompactItem(
                context,
                'الإنجليزية',
                Icons.translate,
                AppColors.englishColor,
                screenWidth,
              ),
              _buildCompactItem(
                context,
                'الحاسوب',
                Icons.computer,
                AppColors.computerColor,
                screenWidth,
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: _buildCompactItem(
                context,
                'العربية',
                Icons.language,
                AppColors.arabicColor,
                screenWidth,
              ),
            ),
            SizedBox(width: spacing),
            Flexible(
              child: _buildCompactItem(
                context,
                'الإنجليزية',
                Icons.translate,
                AppColors.englishColor,
                screenWidth,
              ),
            ),
            SizedBox(width: spacing),
            Flexible(
              child: _buildCompactItem(
                context,
                'الحاسوب',
                Icons.computer,
                AppColors.computerColor,
                screenWidth,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    double screenWidth,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = _getBorderRadius(screenWidth, base: 16);
    final bodySmallFontSize = _getBodySmallFontSize(screenWidth);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth < 360 ? 12 : 14),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.16 : 0.10),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            icon,
            color: color,
            size: screenWidth < 360 ? 22 : 26,
          ),
        ),
        SizedBox(height: screenWidth < 360 ? 8 : 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: bodySmallFontSize,
                color: isDark ? Colors.white : Colors.black,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // -------------------- Requirement Row --------------------

  Widget _buildRequirementRow(
    BuildContext context,
    String text,
    double screenWidth,
  ) {
    final bodyMediumFontSize = _getBodyMediumFontSize(screenWidth);

    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth < 360 ? 12 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: screenWidth < 360 ? 18 : 20,
            ),
          ),
          SizedBox(width: screenWidth < 360 ? 10 : 14),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: bodyMediumFontSize,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Telegram Button --------------------

  Widget _buildTelegramButton(BuildContext context, double screenWidth) {
    final borderRadius = _getBorderRadius(screenWidth, base: 18);
    final buttonHeight = screenWidth < 360 ? 56.0 : (screenWidth < 600 ? 60.0 : 64.0);
    final buttonFontSize = screenWidth < 360 ? 15.0 : (screenWidth < 600 ? 18.0 : 19.0);
    final iconSize = screenWidth < 360 ? 24.0 : (screenWidth < 600 ? 28.0 : 30.0);

    return Container(
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0088CC).withOpacity(0.3),
            blurRadius: screenWidth < 360 ? 12 : 16,
            offset: Offset(0, screenWidth < 360 ? 6 : 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF0088CC), Color(0xFF24A1DE)],
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _launchTelegram(context),
        icon: Icon(Icons.telegram, size: iconSize),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'التسجيل الفوري عبر تليكرام',
            style: TextStyle(
              fontSize: buttonFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 360 ? 16 : (screenWidth < 600 ? 24 : 32),
            vertical: screenWidth < 360 ? 12 : 16,
          ),
        ),
      ),
    );
  }

  Future<void> _launchTelegram(BuildContext context) async {
    // Clean Code: Use the centralized service for external links management
    // This ensures consistent behavior (opening native app first) and error handling
    await ExternalLinkService.launchTelegram(
      AppConstants.telegramUsername,
      context: context,
    );
  }
}