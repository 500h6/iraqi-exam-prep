import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/modern_section.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      context.read<AuthBloc>().add(
            LoginWithPhoneEvent(_phoneController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final textPrimary =
        _isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor,
              cs.primary.withOpacity(_isDark ? 0.08 : 0.06),
            ],
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthOtpSent) {
              context.push('/otp', extra: state.phone);
            } else if (state is AuthUnlinked) {
              context.push('/otp', extra: state.phone);
            } else if (state is AuthError) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: AppColors.error,
                textColor: Colors.white,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Define breakpoints
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;
                      final isTablet = width > 600;
                      final isLandscape = width > height;
                      final isCompact = height < 600;

                      // Responsive padding
                      final horizontalPadding = isTablet ? 48.0 : 20.0;
                      final maxWidth = isTablet ? 500.0 : double.infinity;

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Minimal top spacing
                                    SizedBox(height: isCompact ? 8 : 12),

                                    // Compact Logo + Welcome in one section
                                    _buildHeaderSection(
                                      cs,
                                      theme,
                                      textPrimary,
                                      textSecondary,
                                      isTablet,
                                      isCompact,
                                      isLandscape,
                                    ),

                                    SizedBox(height: isCompact ? 12 : 16),

                                    // Compact Features - always show but condensed
                                    _buildFeaturesPreview(
                                      context,
                                      textPrimary,
                                      textSecondary,
                                      isTablet,
                                      isLandscape,
                                      isCompact,
                                    ),

                                    SizedBox(height: isCompact ? 16 : 20),

                                    // Phone Input Section
                                    ModernSection(
                                      title: 'رقم الهاتف',
                                      icon: Icons.phone_android_rounded,
                                      color: cs.primary,
                                      child: _buildPhoneField(
                                        context,
                                        cs: cs,
                                        textPrimary: textPrimary,
                                        textSecondary: textSecondary,
                                        isTablet: isTablet,
                                      ),
                                    ),

                                    SizedBox(height: isCompact ? 12 : 16),

                                    // Helper Text
                                    _buildHelperText(
                                      textSecondary,
                                      isTablet,
                                      isCompact,
                                    ),

                                    SizedBox(height: isCompact ? 16 : 20),

                                    // Submit Button
                                    AppButton(
                                      text: 'متابعة',
                                      icon: Icons.arrow_back_rounded,
                                      isLoading: isLoading,
                                      onPressed: isLoading
                                          ? null
                                          : () => _submit(context),
                                    ),

                                    SizedBox(height: isCompact ? 10 : 14),

                                    // Security Info - compact in landscape
                                    _buildBottomInfo(
                                      textSecondary,
                                      isTablet,
                                      isCompact,
                                    ),

                                    SizedBox(height: isCompact ? 12 : 20),
                                  ],
                                ),
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
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    ColorScheme cs,
    ThemeData theme,
    Color textPrimary,
    Color textSecondary,
    bool isTablet,
    bool isCompact,
    bool isLandscape,
  ) {
    // Compact, integrated header
    final logoSize = isTablet ? 70.0 : (isCompact ? 50.0 : 60.0);
    final iconSize = isTablet ? 35.0 : (isCompact ? 25.0 : 30.0);
    final titleSize = isTablet ? 26.0 : (isCompact ? 20.0 : 23.0);
    final subtitleSize = isTablet ? 15.0 : (isCompact ? 12.0 : 13.5);

    return Column(
      children: [
        // Logo + Title in compact layout
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Compact logo
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(logoSize * 0.28),
                boxShadow: [
                  BoxShadow(
                    color: (_isDark ? AppColors.primaryLight : cs.primary)
                        .withOpacity(_isDark ? 0.2 : 0.25),
                    blurRadius: logoSize * 0.2,
                    offset: Offset(0, logoSize * 0.08),
                  ),
                ],
              ),
              child: Icon(
                Icons.school_rounded,
                size: iconSize,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            // Welcome text next to logo
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'مرحباً بك 👋',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'أدخل رقم هاتفك للتسجيل أو الدخول',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: subtitleSize,
              color: textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(ColorScheme cs, bool isTablet, bool isCompact) {
    final primary = _isDark ? AppColors.primaryLight : cs.primary;
    final size = isTablet ? 100.0 : (isCompact ? 70.0 : 85.0);
    final iconSize = isTablet ? 50.0 : (isCompact ? 35.0 : 42.0);
    final borderRadius = size * 0.28;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(_isDark ? 0.22 : 0.30),
              blurRadius: size * 0.24,
              offset: Offset(0, size * 0.11),
            ),
          ],
        ),
        child: Icon(
          Icons.school_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
    ThemeData theme,
    Color textPrimary,
    Color textSecondary,
    bool isTablet,
    bool isCompact,
  ) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'مرحباً بك 👋',
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: isTablet ? 32 : (isCompact ? 22 : 26),
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: isCompact ? 6 : 10),
        Text(
          'أدخل رقم هاتفك للتسجيل أو الدخول إلى حسابك',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: isTablet ? 18 : (isCompact ? 13 : 15),
            color: textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFeaturesPreview(
    BuildContext context,
    Color textPrimary,
    Color textSecondary,
    bool isTablet,
    bool isLandscape,
    bool isCompact,
  ) {
    final theme = Theme.of(context);
    // More compact design
    final padding = isTablet ? 14.0 : (isCompact ? 10.0 : 12.0);
    final iconPadding = isTablet ? 12.0 : (isCompact ? 8.0 : 9.0);
    final iconSize = isTablet ? 22.0 : (isCompact ? 18.0 : 20.0);
    final fontSize = isTablet ? 12.0 : (isCompact ? 10.0 : 10.5);
    final borderRadius = isTablet ? 18.0 : (isCompact ? 14.0 : 16.0);

    final features = [
      _FeatureItem(
        icon: Icons.quiz_rounded,
        label: 'اختبارات',
        color: AppColors.primary,
      ),
      _FeatureItem(
        icon: Icons.analytics_rounded,
        label: 'تتبع',
        color: AppColors.success,
      ),
      _FeatureItem(
        icon: Icons.workspace_premium_rounded,
        label: 'مميز',
        color: AppColors.warning,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _isDark
            ? AppColors.surfaceDark.withOpacity(0.5)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: _isDark
              ? AppColors.borderDark.withOpacity(0.5)
              : AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: features.map((feature) {
          return Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding),
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(_isDark ? 0.16 : 0.10),
                    borderRadius: BorderRadius.circular(iconPadding + 2),
                  ),
                  child: Icon(
                    feature.icon,
                    color: feature.color,
                    size: iconSize,
                  ),
                ),
                SizedBox(height: isCompact ? 4 : 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    feature.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhoneField(
    BuildContext context, {
    required ColorScheme cs,
    required Color textPrimary,
    required Color textSecondary,
    required bool isTablet,
  }) {
    final fontSize = isTablet ? 20.0 : 17.0;
    final iconSize = isTablet ? 24.0 : 20.0;
    final borderRadius = isTablet ? 16.0 : 13.0;

    return AutofillGroup(
      child: TextFormField(
        controller: _phoneController,
        focusNode: _phoneFocusNode,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        autofillHints: const [AutofillHints.telephoneNumber],
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _submit(context),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 1.1,
        ),
        decoration: InputDecoration(
          hintText: '07xxxxxxxxx',
          hintStyle: TextStyle(
            color: textSecondary.withOpacity(0.55),
            fontSize: fontSize,
            letterSpacing: 1.1,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 12, left: 8),
            padding: EdgeInsets.all(isTablet ? 14 : 11),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(_isDark ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(borderRadius - 2),
            ),
            child: Icon(
              Icons.phone_android_rounded,
              color: _isDark ? AppColors.primaryLight : cs.primary,
              size: iconSize,
            ),
          ),
          filled: true,
          fillColor: _isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 18 : 15,
            vertical: isTablet ? 20 : 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: _isDark ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: _isDark ? AppColors.primaryLight : cs.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        validator: (value) {
          final v = (value ?? '').trim();
          if (v.isEmpty) return 'يرجى إدخال رقم الهاتف';
          if (v.length < 10) return 'رقم الهاتف قصير جداً';
          if (!v.startsWith('07')) return 'ابدأ الرقم بـ 07';
          return null;
        },
      ),
    );
  }

  Widget _buildHelperText(Color textSecondary, bool isTablet, bool isCompact) {
    final fontSize = isTablet ? 14.0 : (isCompact ? 11.5 : 12.5);
    final iconSize = isTablet ? 20.0 : (isCompact ? 15.0 : 17.0);
    final padding = isTablet ? 14.0 : (isCompact ? 9.0 : 11.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding + 2,
        vertical: padding,
      ),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(_isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(isTablet ? 14 : 11),
        border: Border.all(
          color: AppColors.info.withOpacity(_isDark ? 0.25 : 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: iconSize,
            color: AppColors.info,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'سنرسل لك رمز التحقق عبر رسالة نصية',
              style: TextStyle(
                fontSize: fontSize,
                color: textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(Color textSecondary, bool isTablet, bool isCompact) {
    final fontSize = isTablet ? 14.0 : (isCompact ? 11.5 : 12.5);
    final iconSize = isTablet ? 20.0 : (isCompact ? 15.0 : 17.0);
    final lineWidth = isTablet ? 50.0 : (isCompact ? 30.0 : 40.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                width: lineWidth,
                height: 1,
                color: textSecondary.withOpacity(0.25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.security_rounded,
                size: iconSize,
                color: textSecondary,
              ),
            ),
            Flexible(
              child: Container(
                width: lineWidth,
                height: 1,
                color: textSecondary.withOpacity(0.25),
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 8 : 12),
        Text(
          'بياناتك محمية ولن يتم مشاركتها',
          style: TextStyle(
            fontSize: fontSize,
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Helper class for features
class _FeatureItem {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}